//
//  CKWebRequestManager.h
//  CloudKit
//
//  Created by Guillaume Campagna on 12-05-18.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CKWebRequest;

@interface CKWebRequestManager : NSObject

+ (CKWebRequestManager*)sharedManager;

@property (nonatomic, assign) NSUInteger maxCurrentRequest; //Default 10
@property (nonatomic, readonly) NSUInteger numberOfRunningRequest;
@property (nonatomic, readonly) NSUInteger numberOfWaitingRequest;

@property (nonatomic, copy) void (^disconnectBlock)(void); //Called when there's no more Internet connectivity still with running request
                                                           //By default, pause all operation and show an alert with the option to retry all requests
                                                           //When handling of the disconnect is done, the block should call - (void)didHandleDisconnect (after an alert is dismissed for example)
- (void)didHandleDisconnect;

- (void)scheduleRequest:(CKWebRequest*)request;

- (void)cancelAllOperation; //Stop and remove all operations
- (void)cancelOperationsConformingToPredicate:(NSPredicate*)predicate;
- (void)pauseAllOperation; //Stop operations
- (void)retryAllOperation; //Retry stopped operations

@end
