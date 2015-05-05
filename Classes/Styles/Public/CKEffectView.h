//
//  CKEffectView.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-05-01.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import <UIKit/UIKit.h>

/** CKEffectView is the base class for views who need to refresh drawing or views at each frame.
 */
@interface CKEffectView : UIView<NSCopying>

- (void)postInit;

/** didRegisterForUpdates is called after the view entered in a window
 */
- (void)didRegisterForUpdates;

/** didRegisterForUpdates is called after the view quit a window
 */
- (void)didUnregisterForUpdates;

/** Calling setNeedsEffectUpdate will force updateEffect to be called at the next screen update.
 */
- (void)setNeedsEffectUpdate;

/** Update effect is called when the frame of the effect view changes in the windows referential.
 Override this method to update the visual appearance of your effect view.
 rect is the frame of the effect view in the window.
 */
- (void)updateEffectWithRect:(CGRect)rect;

/** Updates the effect with the current frame in window.
 */
- (void)updateEffect;

/** Computes the frame of the effect view in its parent window using its presentation if available to support animations.
 */
- (CGRect)rectInWindow;

/** This method is called when the superview insert or adds subviews in its hierarchy.
 If the effect view needs to be in a specific location in the superview hierarchy, you can move it in the superview by overriding this method.
 */
- (void)superViewDidModifySubviewHierarchy;

@end
