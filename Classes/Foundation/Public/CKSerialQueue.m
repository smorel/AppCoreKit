//
//  CKSerialQueue.m
//  mightycast-ios.nex
//
//  Created by Sebastien Morel on 2015-04-20.
//  Copyright (c) 2015 Sebastien Morel. All rights reserved.
//

#import "CKSerialQueue.h"


@interface CKJob()
@property(nonatomic,copy,readwrite) void(^execute)(CKJob* job);
@property(nonatomic,copy,readwrite) void(^completion)(BOOL cancelled);
@property(nonatomic,copy,readwrite) void(^didComplete)();
@end


@interface CKSerialQueue()
@property(nonatomic,retain,readwrite) CKJob* currentJob;
@property(nonatomic,retain,readwrite) NSArray* jobQueue;
@property(nonatomic,assign,readwrite) BOOL paused;

@end

@implementation CKSerialQueue{
    dispatch_queue_t _queue;
}

- (id)init{
    self = [super init];
    self.paused = NO;
    self.executeLastJobByCancellingEnqueuedJobs = NO;
    self.executeJobsOnMainThread = NO;
    self.jobQueue = [NSMutableArray array];
    _queue = dispatch_queue_create("CKSerialQueue", 0);
    return self;
}

- (void)dealloc{
    [_currentJob release];
    [_jobQueue release];
    dispatch_release(_queue);
    [super dealloc];
}

- (dispatch_queue_t)queue{
    return self.executeJobsOnMainThread ? dispatch_get_main_queue() : _queue;
}

- (void)enqueueJob:(CKJob*)job{
    dispatch_async([self queue], ^{
        [(NSMutableArray*)self.jobQueue addObject:job];
        [self dequeueJob];
    });
}

- (void)enqueueJob:(void(^)(CKJob* job))execute withCompletion:(void(^)(BOOL cancelled))completion{
    CKJob* job = [CKJob job:execute withCompletion:completion];
    [self enqueueJob:job];
}

- (void)pause{
    self.paused = YES;
}

- (void)resume{
    self.paused = NO;
    [self dequeueJob];
}

- (void)dequeueJob{
    if(self.currentJob || self.jobQueue.count <= 0 || self.paused)
        return;
    
    dispatch_async([self queue], ^{
        if(self.executeLastJobByCancellingEnqueuedJobs){
            NSInteger count = self.jobQueue.count;
            for(NSInteger i = count - 1; i > 0; --i){
                CKJob* job = [self.jobQueue objectAtIndex:i];
                if(job.completion){
                    job.completion(YES);
                }
                [(NSMutableArray*)self.jobQueue removeObjectAtIndex:i];
            }
        }
        
        self.currentJob = [self.jobQueue objectAtIndex:0];
        
        CKJob* job = self.currentJob;
        job.didComplete = ^(){
            [(NSMutableArray*)self.jobQueue removeObjectAtIndex:0];
            self.currentJob = nil;
            [self dequeueJob];
        };
        
        job.execute(job);
    });
}

- (void)cancelAllJobs{
    dispatch_async([self queue], ^{
        for(CKJob* job in self.jobQueue){
            if(job.completion){
                job.completion(YES);
            }
        }
        [(NSMutableArray*)self.jobQueue removeAllObjects];
        self.currentJob = nil;
    });
}

@end


@implementation CKJob

+ (CKJob*)job:(void(^)(CKJob* job))execute withCompletion:(void(^)(BOOL cancelled))completion{
    return [[[CKJob alloc]initWithJob:execute withCompletion:completion]autorelease];
}

- (instancetype)initWithJob:(void(^)(CKJob* job))execute withCompletion:(void(^)(BOOL cancelled))completion{
    self = [super init];
    self.execute = execute;
    self.completion = completion;
    return self;
}

- (void)dealloc{
    [_execute release];
    [_completion release];
    [_didComplete release];
    [super dealloc];
}

- (void)complete{
    if(self.didComplete){
        self.didComplete();
    }
    if(self.completion){
        self.completion(NO);
    }
}

@end