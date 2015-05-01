//
//  CKShadowView.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-05-01.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKStyleView.h"
#import "CKLightEffectView.h"

@interface CKShadowView : CKLightEffectView

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
/// @name Customizing the border
///-----------------------------------

/**
 */
@property (nonatomic, assign) NSInteger borderLocation;

///-----------------------------------
/// @name Customizing the shadow
///-----------------------------------

/**
 */
@property (nonatomic, retain) UIColor *borderShadowColor;

/**
 */
@property (nonatomic, assign) CGFloat borderShadowRadius;

/** borderShadowOffset will be computed dynamically if specifying light source
 */
@property (nonatomic, assign) CGSize borderShadowOffset;


@end


/**
 */
@interface UIView(CKShadowView)

- (CKShadowView*)shadowView;

@end