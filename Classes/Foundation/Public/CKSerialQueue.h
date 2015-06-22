//
//  CKSerialQueue.h
//  mightycast-ios.nex
//
//  Created by Sebastien Morel on 2015-04-20.
//  Copyright (c) 2015 Sebastien Morel. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 */
@interface CKJob : NSObject

/**
 */
@property(nonatomic,copy,readonly) void(^execute)(CKJob* job);

/**
 */
@property(nonatomic,copy,readonly) void(^completion)(BOOL cancelled);

/**
 */
+ (CKJob*)job:(void(^)(CKJob* job))execute withCompletion:(void(^)(BOOL cancelled))completion;

/**
 */
- (instancetype)initWithJob:(void(^)(CKJob* job))execute withCompletion:(void(^)(BOOL cancelled))completion;

/** You must call complete when your job has finished so that the serial queue can process the next jobs
 */
- (void)complete;

@end



/**
 */
@interface CKSerialQueue : NSObject

/** By setting this flag, only the last job in queue will be prossed and the one enqueued before will be cancelled
 Default value is NO.
 */
@property(nonatomic,assign) BOOL executeLastJobByCancellingEnqueuedJobs;

/** Default value is NO.
 */
@property(nonatomic,assign) BOOL executeJobsOnMainThread;

/**
 */
@property(nonatomic,retain,readonly) CKJob* currentJob;

/**
 */
@property(nonatomic,retain,readonly) NSArray* jobQueue;

/**
 */
- (void)enqueueJob:(CKJob*)job;

/**
 */
- (void)enqueueJob:(void(^)(CKJob* job))execute withCompletion:(void(^)(BOOL cancelled))completion;

/**
 */
- (void)cancelAllJobs;


/**
 */
@property(nonatomic,assign,readonly) BOOL paused;

/**
 */
- (void)pause;

/**
 */
- (void)resume;

@end
