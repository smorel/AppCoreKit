//
//  UIGestureRecognizer+BlockBasedInterface.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 */
@interface UIGestureRecognizer (CKBlockBasedInterface) <UIGestureRecognizerDelegate>

///-----------------------------------
/// @name Configuring UIGestureRecognizer concurrency
///-----------------------------------

/**
 */
@property(nonatomic,retain) NSArray* allowedSimultaneousRecognizers;

///-----------------------------------
/// @name Initializing UIGestureRecognizer Object
///-----------------------------------

/**
 */
- (id)initWithBlock:(void(^)(UIGestureRecognizer* gestureRecognizer))block;

/**
 */
- (id)initWithBlock:(void(^)(UIGestureRecognizer* gestureRecognizer))block shouldBeginBlock:(BOOL(^)(UIGestureRecognizer* gestureRecognizer))shouldBeginBlock;

///-----------------------------------
/// @name Cancelling Gesture recognizers
///-----------------------------------

/**
 */
- (void)cancel;

@end
