//
//  CKAnimationManager.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 12-03-28.
//  Copyright (c) 2012 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class CKAnimation;
@class CKAnimationManager;

typedef void(^CKAnimationManagerUpdateBlock)(CKAnimationManager* manager,NSTimeInterval timestamp,NSTimeInterval duration);

/** 
 The CKAnimationManager manage a set of animations that are associated to it when playing.
 
 The animation manager register itself to the screen display link to get updated at each frame. It will update all its registered animations and call the pre-update and post-pdate blocks that can be usefull to refresh the content of a scene at a particular moment of the update process.
 
 See Also: CKAnimation
 */
@interface CKAnimationManager : NSObject

///-----------------------------------
/// @name Initializing an Animation Manager Object
///-----------------------------------

/** Associates an Animation Manager object to the specified screen fro fram by frame updates.
 
 @param screen The screen used to register on its display link.
 */
- (void)registerInScreen:(UIScreen*)screen;

/** De-associates an Animation Manager object to the specified screen fro fram by frame updates.
 */
- (void)unregisterFromScreen;


///-----------------------------------
/// @name Managing animations
///-----------------------------------

/** An array containing the currently playing animations.
 */
@property(nonatomic,retain,readonly) NSArray* animations;

/** Registers an animation for updates.
 
 @param animation The animation to update.
 */
- (void)registerAnimation:(CKAnimation*)animation;

/** Unregister an animation from updates.
 
 @param animation The animation to unregister.
 */
- (void)unregisterAnimation:(CKAnimation*)animation;

/** Unregisters all the currently playing animations.
 */
- (void)stopAllAnimations;


///-----------------------------------
/// @name Registering on update Callbacks
///-----------------------------------

/** A block that gets called at each frame before updating the animations.
 */
@property(nonatomic,copy) CKAnimationManagerUpdateBlock preUpdateBlock;

/** A block that gets called at each frame after updating the animations.
 */
@property(nonatomic,copy) CKAnimationManagerUpdateBlock postUpdateBlock;

@end
