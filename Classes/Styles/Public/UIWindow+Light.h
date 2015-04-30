//
//  UIWindow+Light.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-30.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString* CKLightDidChangeNotification;

/**
 */
@interface CKLight : NSObject

///-----------------------------------
/// @name Customizing the light source
///-----------------------------------

/** anchor point of light in window. values between 0 and 1.
 */
@property (nonatomic, assign) CGPoint origin;

/** anchor point of light in window. values between 0 and 1.
 */
@property (nonatomic, assign) CGPoint end;

/**
 */
@property (nonatomic, assign) CGFloat intensity;

@end


/**
 */
@interface UIWindow (Light)

/** Settings window's light from a view controller cannot be done in viewDidLoad as the controller's view is nil at this moment.
 You should do it from the stylesheets or in viewWillAppear:
 
 - (void)viewWillAppear:(BOOL)animated{
     [super viewWillAppear:animated];
 
     dispatch_async(dispatch_get_main_queue(), ^{
         CKLight* light = [[CKLight alloc]init];
         light.origin = CGPointMake(0, 0);
         light.end = CGPointMake(0.5, 0.5);
         light.intensity = 20;
         self.view.window.light = light;
     });
 }
 */
@property(nonatomic,retain) CKLight* light;

@end
