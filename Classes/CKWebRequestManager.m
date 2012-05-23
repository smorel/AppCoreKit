//
//  CKWebRequestManager.m
//  CloudKit
//
//  Created by Guillaume Campagna on 12-05-18.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKWebRequestManager.h"
#import "CKWebRequest.h"
#import "CKNetworkActivityManager.h"

@interface CKWebRequestManager ()

@property (nonatomic, assign) dispatch_queue_t requestQueue;
@property (nonatomic, retain) NSRunLoop *runLoop;

@property (nonatomic, retain) NSMutableArray *runningRequests;
@property (nonatomic, retain) NSMutableArray *waitingRequests;

- (void)requestDidFinish:(CKWebRequest*)request;

@end

@implementation CKWebRequestManager

@synthesize requestQueue, runLoop, maxCurrentRequest;
@synthesize runningRequests, waitingRequests;

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
        
        self.maxCurrentRequest = 10;
        
        self.runningRequests = [NSMutableArray array];
        self.waitingRequests = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc {
    dispatch_release(self.requestQueue);
    self.runningRequests = nil;
    self.waitingRequests = nil;
    self.runLoop = nil;
    
    [super dealloc];
}

#pragma mark - Schedule Request

- (void)scheduleRequest:(CKWebRequest *)request {
    void (^oldCompletionBlock)(id, NSHTTPURLResponse *, NSError *) = request.completionBlock;
    request.completionBlock = ^(id object, NSHTTPURLResponse *response, NSError *error) {
        [self requestDidFinish:request];
        
        oldCompletionBlock(object, response, error);
    };
    
    if (self.runningRequests.count < self.maxCurrentRequest) {
        NSRunLoop *loop = self.runLoop;
        [request startOnRunLoop:loop];
        [self.runningRequests addObject:request];
        
        [[CKNetworkActivityManager defaultManager] addNetworkActivityForObject:request];
    }
    else 
        [self.waitingRequests addObject:request];
}

- (void)requestDidFinish:(CKWebRequest*)request {//Start a new one if some are waiting
    [self.runningRequests removeObject:request];
    [[CKNetworkActivityManager defaultManager] removeNetworkActivityForObject:request];
    
    if (self.waitingRequests.count != 0) {
        CKWebRequest *newRequest = [self.waitingRequests objectAtIndex:0];
        [self.waitingRequests removeObjectAtIndex:0];
        [self.runningRequests addObject:newRequest];
        
        [newRequest startOnRunLoop:self.runLoop];
    }
}

#pragma mark - Cancel Request

- (void)cancelAllOperation {
    [self.runningRequests makeObjectsPerformSelector:@selector(cancel)];
    [self.waitingRequests removeAllObjects];
}

- (void)cancelOperationsConformingToPredicate:(NSPredicate *)predicate {
    [[self.runningRequests filteredArrayUsingPredicate:predicate] makeObjectsPerformSelector:@selector(cancel)];
    
    NSPredicate *notPredicate = [NSCompoundPredicate notPredicateWithSubpredicate:predicate];
    [self.waitingRequests filterUsingPredicate:notPredicate];
}

#pragma mark - Getter

- (NSUInteger)numberOfRunningRequest {
    return self.runningRequests.count;
}

- (NSUInteger)numberOfWaitingRequest {
    return self.waitingRequests.count;
}

@end
