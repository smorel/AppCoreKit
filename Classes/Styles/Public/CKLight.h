//
//  UIWindow+Light.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-30.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSObject+Singleton.h"



extern NSString* CKLightDidChangeNotification;



/** The light should be accessed using [CKLight sharedInstance] cause this is the one that is used by the CKLightEffectView instances.
 */
@interface CKLight : NSObject

///-----------------------------------
/// @name Customizing the light source
///-----------------------------------

/** anchor point of light in window. values between 0 and 1.
 */
@property (nonatomic, assign) CGPoint origin;

/** anchor point of light in views bounds. values between 0 and 1.
 */
@property (nonatomic, assign) CGPoint anchorPoint;

/**
 */
@property (nonatomic, assign) CGFloat intensity;

/** By enabling this flag the light will be affected by the gyroscope orientation.
 */
@property (nonatomic,assign) BOOL motionEffectEnabled;

/** Set the x/y scale to accentuate or reduce the motion effect
 */
@property (nonatomic,assign) CGPoint motionEffectScale;

@end