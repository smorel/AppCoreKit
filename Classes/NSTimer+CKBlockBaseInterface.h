//
//  NSTimer+CKBlockBaseInterface.h
//  CloudKit
//
//  Created by Martin Dufort on 12-06-20.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (CKBlockBaseInterface)

+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)ti repeats:(BOOL)yesOrNo block:(void(^)(NSTimer* timer))block;
+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti repeats:(BOOL)yesOrNo block:(void(^)(NSTimer* timer))block;

@end
