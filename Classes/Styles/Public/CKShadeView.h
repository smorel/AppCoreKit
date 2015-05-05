//
//  CKShadeView.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-05-04.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKEffectView.h"
#import "CKStyleView.h"

@interface CKShadeView : CKEffectView

///-----------------------------------
/// @name Customizing the rounded corners
///-----------------------------------

/**
 */
@property (nonatomic,assign) CKStyleViewCornerType corners;

/**
 */
@property (nonatomic,assign) CGFloat roundedCornerSize;

///-----------------------------------
/// @name Customizing the shade
///-----------------------------------

/**
 */
@property (nonatomic,retain) UIColor* shadeColor;

/**
 */
@property (nonatomic,assign) CGFloat fullShadeZ;

/**
 */
@property (nonatomic,assign) CGFloat noShadeZ;

@end
