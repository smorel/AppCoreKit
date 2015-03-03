//
//  CKAnimationInterpolator.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 12-03-28.
//  Copyright (c) 2012 WhereCloud Inc. All rights reserved.
//

#import "CKAnimation.h"


/**  The CKAnimationInterpolator class defines a 3-linear interpolation animation. 
 
 The value sent to the updateBlock is computed using the specified values. A floating ratio between 0 and 1 is computed each time an animation updates using the specified options and duration. This ratio is used to find the first lower and higher value in the values array and interpolates between these two values.
 
 CKAnimationInterpolator is able to interpolate NSNumber and NSValue with the following content:
 
 * CGAffineTransform
 * CGRect
 * CGPoint
 * CGSize
 
 <b>Creating and playing an interpolator animation in loop</b>
 
     CKAnimationInterpolator* interpolator = [CKAnimationInterpolator animation];
     interpolator.duration = 5.0;
     interpolator.options = CKAnimationOptionForwards | CKAnimationOptionLoop;
     interpolator.values = [NSArray arrayWithObjects:[NSNumber numberWithInt:3], [NSNumber numberWithInt:7],[NSNumber numberWithInt:2], nil];
     interpolator.updateBlock = ^(CKAnimation* animation, id value){
         NSInteger interpolatedValue = [value integerValue];
         //Do something with this value
     };
     interpolator.eventBlock = ^(CKAnimation* animation, CKAnimationEvents event){
         if(event == CKAnimationEventLoop){
             //Do something each time this animation reaches the end of its playback and loops.
         }
     };
     [interpolator start];
 
 See Also: CKAnimation, CKAnimationManager
 */
@interface CKAnimationInterpolator : CKAnimation

///-----------------------------------
/// @name Configuring the animation
///-----------------------------------

/** An array of objects that provide the keyframe values for the receiver.
   
 The objects in values must all be of the same type and values must contain at least 2 objects.
 */
@property(nonatomic,retain) NSArray* values;

@end


/**  The CKAnimationPropertyInterpolator class defines a 3-linear interpolation animation that automatically sets the computed value to a specified object's property using KVC.
 On the contrary to Core Animation, CKAnimationPropertyInterpolator do not apply exclusively to CAlayer objects and do not need any additional methods to be implemented. Any properties (of the supported type cf. CKAnimationInterpolator) on any object class can be animated using an instance of CKAnimationPropertyInterpolator.
 
 <b>Creating and playing an interpolator animation for the alpha property of a view</b>
 
     UIView* myView = ...;
     
     CKAnimationPropertyInterpolator* interpolator = [CKAnimationPropertyInterpolator animationWithObject:myView keyPath:@"alpha"];
     interpolator.duration = 5.0;
     interpolator.options = CKAnimationOptionForwards | CKAnimationOptionLoop;
     interpolator.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0], [NSNumber numberWithFloat:0.5], nil];
     [interpolator start];
 
 See Also: CKAnimationInterpolator
 */
@interface CKAnimationPropertyInterpolator : CKAnimationInterpolator
@property(nonatomic,copy,readonly)  CKAnimationUpdateBlock updateBlock;

///-----------------------------------
/// @name Initializing an Animation Property Interpolator Object
///-----------------------------------

/** Returns an autoreleased Animation Property Interpolator object.
 
 @param object Specifies the object who's property at keyPath is animated.
 @param keyPath Specifies the key path the receiver animates.
 
 @return An autoreleased Animation Manager object.
 */
+ (CKAnimationPropertyInterpolator*)animationWithObject:(id)object keyPath:(NSString*)keyPath;

/** Initialize and return a newly allocated instance of Property Interpolator object.
 
 @param object Specifies the object who's property at keyPath is animated.
 @param keyPath Specifies the key path the receiver animates.
 
 @return An initialized Animation Property Interpolator object.
 */
- (id)initWithObject:(id)object keyPath:(NSString*)keyPath;

@end
