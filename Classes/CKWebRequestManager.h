//
//  CKWebRequestManager.h
//  AppCoreKit
//
//  Created by Guillaume Campagna.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CKWebRequest;

/**
 */
@interface CKWebRequestManager : NSObject

///-----------------------------------
/// @name Singleton
///-----------------------------------

/**
 */
+ (CKWebRequestManager*)sharedManager;

///-----------------------------------
/// @name Configuring the WebRequest Manager
///-----------------------------------

/** Default is 10
 */
@property (nonatomic, assign) NSUInteger maxCurrentRequest;

/**
 */
@property (nonatomic, readonly) NSUInteger numberOfRunningRequest;

/**
 */
@property (nonatomic, readonly) NSUInteger numberOfWaitingRequest;


///-----------------------------------
/// @name Handling Network Connection Accessibility
///-----------------------------------

/** Called when there's no more Internet connectivity still with running request
    By default, pause all operation and show an alert with the option to retry all requests
    When handling of the disconnect is done, the block must call - (void)didHandleDisconnect (after an alert is dismissed for example)
 */
@property (nonatomic, copy) void (^disconnectBlock)(void); 

/**
 */
- (void)didHandleDisconnect;


///-----------------------------------
/// @name Executing WebRequests
///-----------------------------------

/**
 */
- (void)scheduleRequest:(CKWebRequest*)request;

/** Retry paused requests
 */
- (void)retryAllRequests;

///-----------------------------------
/// @name Cancelling/Pausing WebRequests
///-----------------------------------

/** Stop and remove all requests
 */
- (void)cancelAllRequests; 

/**
 */
- (void)cancelRequestsMatchingToPredicate:(NSPredicate*)predicate;

/**
 */
- (void)pauseAllRequests; 

@end
