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

- (void)scheduleRequest:(CKWebRequest*)request;

- (void)cancelAllOperation;
- (void)cancelOperationsConformingToPredicate:(NSPredicate*)predicate;

@end
