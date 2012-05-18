//
//  CKWebRequestManager.m
//  CloudKit
//
//  Created by Guillaume Campagna on 12-05-18.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKWebRequestManager.h"
#import "CKWebRequest.h"

@interface CKWebRequestManager ()

@property (nonatomic, assign) dispatch_queue_t requestQueue;

@property (nonatomic, retain) NSMutableArray *runningRequests;
@property (nonatomic, retain) NSMutableArray *waitingRequests;

- (void)requestDidFinish:(CKWebRequest*)request;

@end

@implementation CKWebRequestManager

@synthesize requestQueue, maxCurrentRequest;
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
        
        self.maxCurrentRequest = 4;
        
        self.runningRequests = [NSMutableArray array];
        self.waitingRequests = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc {
    dispatch_release(self.requestQueue);
    self.runningRequests = nil;
    self.waitingRequests = nil;
    
    [super dealloc];
}

#pragma mark - Schedule Request

- (void)scheduleRequest:(CKWebRequest *)request {
    void (^oldCompletionBlock)(id, NSURLResponse *, NSError *) = request.completionBlock;
    request.completionBlock = ^(id object, NSURLResponse *response, NSError *error) {
        [self requestDidFinish:request];
        
        oldCompletionBlock(object, response, error);
    };
    
    if (self.runningRequests.count >= self.maxCurrentRequest) {
        dispatch_async(self.requestQueue, ^{
            [request start];
        });
    }
    else 
        [self.waitingRequests addObject:request];
}

- (void)requestDidFinish:(CKWebRequest*)request {//Start a new one if some are waiting
    [self.runningRequests removeObject:request];
    
    if (self.waitingRequests.count != 0) {
        CKWebRequest *newRequest = [self.waitingRequests objectAtIndex:0];
        [self.waitingRequests removeObjectAtIndex:0];
        [self.runningRequests addObject:newRequest];
        
        dispatch_async(self.requestQueue, ^{
            [newRequest start];
        });
    }
}

#pragma mark - Cancel Request

- (void)cancelAllOperation {
    [self.runningRequests makeObjectsPerformSelector:@selector(cancel)];
    [self.runningRequests removeAllObjects];
    [self.waitingRequests removeAllObjects];
}

- (void)cancelOperationsConformingToPredicate:(NSPredicate *)predicate {
    [[self.runningRequests filteredArrayUsingPredicate:predicate] makeObjectsPerformSelector:@selector(cancel)];
    
    NSPredicate *notPredicate = [NSCompoundPredicate notPredicateWithSubpredicate:predicate];
    [self.runningRequests filterUsingPredicate:notPredicate];
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
