//
//  NSTimer+BlockBaseInterface.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>


/** 
 */
@interface NSTimer (CKBlockBaseInterface)

///-----------------------------------
/// @name Creating a Timer
///-----------------------------------

/** 
 */
+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)ti repeats:(BOOL)yesOrNo block:(void(^)(NSTimer* timer))block;

/** 
 */
+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti repeats:(BOOL)yesOrNo block:(void(^)(NSTimer* timer))block;

@end
