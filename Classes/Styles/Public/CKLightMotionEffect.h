//
//  CKLightMotionEffect.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-30.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKLight.h"

@interface CKLightMotionEffect : UIMotionEffect

@property(nonatomic,retain, readonly) CKLight* light;
@property(nonatomic,assign) CGPoint scale;

@end