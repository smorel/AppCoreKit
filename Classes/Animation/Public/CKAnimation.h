//
//  CKAnimation.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 12-03-28.
//  Copyright (c) 2012 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum CKAnimationOptions{
    CKAnimationOptionNone         = 0,
    CKAnimationOptionForwards     = 1 << 1,
    CKAnimationOptionBackwards    = 1 << 2,
    CKAnimationOptionAutoReverse  = 1 << 3,
    CKAnimationOptionLoop         = 1 << 4
}CKAnimationOptions;

typedef enum CKAnimationEvents{
    CKAnimationEventStart,
    CKAnimationEventEnd,
    CKAnimationEventLoop,
    CKAnimationEventCancelled
}CKAnimationEvents;

@class CKAnimation;
typedef void(^CKAnimationUpdateBlock)(CKAnimation* animation,id value);
typedef void(^CKAnimationEventBlock)(CKAnimation* animation,CKAnimationEvents event);

@class CKAnimationManager;


/** CKAnimation  is an abstract animation class. It manages playback using specified duration and options. Animations can be started and stopped manually. When starting, the animation is registered in a specified or the main animation manager for updates.
 
 <b>Memory Management</b>
 
 Retaining animations is not mandatory as the animation manager will do it for you. Knowing that if an animation is manually stopped or finishes, it will automatically be unregistered from the associated manager and potentially be deallocated if not retained by some tierce object.
 
 See Also: CKAnimationManager
 */
@interface CKAnimation : NSObject


///-----------------------------------
/// @name Initializing an Animation Object
///-----------------------------------

/** Initializes and returns an autoreleased animation object.
 
 @return An initialized autoreleased Animation object.
*/
+ (CKAnimation*)animation;


///-----------------------------------
/// @name Configuring the animation
///-----------------------------------

/** Specifies the basic duration of the animation, in seconds. (required)
 
 In combination with CKAnimationOptionAutoReverse option, the duration is doubled internally.
 */
@property(nonatomic,assign) NSTimeInterval duration;

/** A bitmask of options indicating how you want to perform the animations.
 
 The values that can be used are the following:
 * CKAnimationOptionNone         = 0,
 * CKAnimationOptionForwards     = 1 << 1,
 * CKAnimationOptionBackwards    = 1 << 2,
 * CKAnimationOptionAutoReverse  = 1 << 3,
 * CKAnimationOptionLoop         = 1 << 4
 
 The default value is CKAnimationOptionForwards.
 */
@property(nonatomic,assign) NSInteger options;

///-----------------------------------
/// @name Managing playback
///-----------------------------------

/** The animation manager associated to this animation.
 
 If playing the animation using the start method, the mainManager will get used. You can specify explicitly wich instance of manager should manage this animation using the startInManager: method.
 
 See Also: start, startInManager:
 */
@property(nonatomic,assign,readonly) CKAnimationManager* animationManager;

/** Start the animation in a specified manager.
 
 Starting the animation computes the value at time 0 instantaneously and gets updated by the associated manager until it has finished. When an animtion finish, it gets unregistered from the manager automatically to stop being updated.
 
 @param manager The animation manager in which the animation will get registered for updates.
 */
- (void)startInManager:(CKAnimationManager*)manager;

/** Unregister the animation from the associated manager.
 */
- (void)stop;

///-----------------------------------
/// @name Registering on Callbacks
///-----------------------------------

/** A block that will get called with the computed value when animation starts and gets updated by the manager.
 */
@property(nonatomic,copy)   CKAnimationUpdateBlock updateBlock;

/** A block that will get called at specific time during the animation playback.
 
 This block is usefull to handle animation events such as:
 * CKAnimationEventStart
 * CKAnimationEventEnd
 * CKAnimationEventLoop
 * CKAnimationEventCancelled
 */
@property(nonatomic,copy)   CKAnimationEventBlock eventBlock;

@end
