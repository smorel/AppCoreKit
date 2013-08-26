//
//  CKWebRequestManager.m
//  AppCoreKit
//
//  Created by Guillaume Campagna.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKWebRequestManager.h"
#import "CKLocalization.h"
#import "CKWebRequest.h"
#import "CKAlertView.h"
#import "JSONKit.h"
#import "Reachability.h"
#import "CKNetworkActivityManager.h"

@interface CKWebRequestManager ()

@property (nonatomic, assign) dispatch_queue_t requestQueue;
@property (nonatomic, retain) NSRunLoop *runLoop;

@property (retain) NSMutableArray *runningRequests;
@property (retain) NSMutableArray *waitingRequests;

@property (nonatomic, retain) Reachability *reachability;
@property (nonatomic, assign) BOOL handelingDisconnect;

- (void)requestDidFinish:(CKWebRequest*)request;

@end

@implementation CKWebRequestManager

@synthesize requestQueue, runLoop, maxCurrentRequest;
@synthesize runningRequests, waitingRequests;
@synthesize disconnectBlock, reachability, handelingDisconnect;

#pragma mark - Lifecycle

+ (CKWebRequestManager*)sharedManager {
    static CKWebRequestManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[CKWebRequestManager alloc] init];
    });
    return manager;
}

- (id)init {
    if (self = [super init]) {
        dispatch_queue_t queue = dispatch_queue_create("com.cloudkit.CKWebRequestManager", DISPATCH_QUEUE_SERIAL);
        self.requestQueue = queue;
        
        dispatch_group_t group = dispatch_group_create();
        dispatch_group_async(group, self.requestQueue, ^{
            NSPort* port = [NSPort port];
            NSRunLoop *currentRunLoop = [NSRunLoop currentRunLoop];
            self.runLoop = currentRunLoop;
            dispatch_async(self.requestQueue, ^{
                [currentRunLoop addPort:port forMode:NSDefaultRunLoopMode];
                [currentRunLoop run];
            });
        });
        
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        dispatch_release(group);
        
        self.maxCurrentRequest = 10;
        self.handelingDisconnect = NO;
        
        self.runningRequests = [NSMutableArray array];
        self.waitingRequests = [NSMutableArray array];
        
        __block BOOL alertDisplayed = NO;
        __block CKWebRequestManager *bself = self;
        self.disconnectBlock = ^{
            [bself pauseAllRequests];
            
            if(!alertDisplayed){
                CKAlertView *alertView = [[[CKAlertView alloc] initWithTitle:_(@"No Internet Connection") message:_(@"You don't seems to have Internet access right now, do you want to try again?")] autorelease];
                [alertView addButtonWithTitle:_(@"Dismiss") action:^{
                    alertDisplayed = NO;
                    [bself didHandleDisconnect];
                }];
                [alertView addButtonWithTitle:_(@"Retry") action:^{
                    alertDisplayed = NO;
                    [bself didHandleDisconnect];
                    [bself retryAllRequests];
                }];
                alertDisplayed = YES;
                [alertView show];
            }
        };
        
        self.reachability = [Reachability reachabilityForInternetConnection];
        [self.reachability startNotifer];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidChange) name:kReachabilityChangedNotification object:self.reachability];
    }
    return self;
}

- (void)dealloc {
    [self.reachability stopNotifer];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:self.reachability];
    
    dispatch_release(self.requestQueue);
    self.runningRequests = nil;
    self.waitingRequests = nil;
    self.runLoop = nil;
    self.reachability = nil;
    self.disconnectBlock = nil;
    
    [super dealloc];
}

#pragma mark - Schedule Request

- (void)scheduleRequest:(CKWebRequest *)request {
    __block CKWebRequest *bRequest = request;
    void (^oldCompletionBlock)(id, NSHTTPURLResponse *, NSError *) = request.completionBlock;
    request.completionBlock = ^(id object, NSHTTPURLResponse *response, NSError *error) {
        [self requestDidFinish:bRequest];
        
        if (oldCompletionBlock)
            oldCompletionBlock(object, response, error);
    };
    
    void (^oldCancelBlock)(void) = request.cancelBlock;
    request.cancelBlock = ^{
        [self requestDidFinish:bRequest];
        
        if (oldCancelBlock)
            oldCancelBlock();
    };
    
    if (self.runningRequests.count < self.maxCurrentRequest) {
        NSRunLoop *loop = self.runLoop;
        [request startOnRunLoop:loop];
        [self.runningRequests addObject:request];
    }
    else
        [self.waitingRequests addObject:request];
    
    [self reachabilityDidChange];
}

- (void)requestDidFinish:(CKWebRequest*)request {//Start a new one if some are waiting
    [self.runningRequests removeObject:request];
    
    if (self.waitingRequests.count != 0) {
        CKWebRequest *newRequest = [[self.waitingRequests objectAtIndex:0]retain];
        [self.waitingRequests removeObjectAtIndex:0];
        if(newRequest){
            [self.runningRequests addObject:newRequest];
            
            [newRequest startOnRunLoop:self.runLoop];
            [newRequest autorelease];
        }
    }
}

#pragma mark - Cancel Request

- (void)cancelAllRequests {
    [self.waitingRequests removeAllObjects];
    [self.runningRequests makeObjectsPerformSelector:@selector(cancel)];
}

- (void)cancelRequestsMatchingToPredicate:(NSPredicate *)predicate {
    [[self.runningRequests filteredArrayUsingPredicate:predicate] makeObjectsPerformSelector:@selector(cancel)];
    
    NSPredicate *notPredicate = [NSCompoundPredicate notPredicateWithSubpredicate:predicate];
    [self.waitingRequests filterUsingPredicate:notPredicate];
}

- (void)pauseAllRequests {
    for (CKWebRequest *request in self.runningRequests) {
        __block CKWebRequest *bRequest = request;
        void (^oldCancelBlock)() = request.cancelBlock;
        request.cancelBlock = ^{
            [[CKNetworkActivityManager defaultManager] removeNetworkActivityForObject:request];
            bRequest.cancelBlock = oldCancelBlock;
        };
        [request cancel];
    }
}

- (void)retryAllRequests {
    [self.runningRequests makeObjectsPerformSelector:@selector(startOnRunLoop:) withObject:self.runLoop];
    [self reachabilityDidChange];
}

#pragma mark - Getter

- (NSUInteger)numberOfRunningRequest {
    return self.runningRequests.count;
}

- (NSUInteger)numberOfWaitingRequest {
    return self.waitingRequests.count;
}

#pragma mark - Reachability

- (void)reachabilityDidChange {
    NetworkStatus networkStatus = [self.reachability currentReachabilityStatus];
    if (!self.handelingDisconnect && networkStatus == NotReachable && self.runningRequests.count != 0) {
        if (self.disconnectBlock)
            self.disconnectBlock();
    }
}

- (void)didHandleDisconnect {
    self.handelingDisconnect = NO;
}

@end
