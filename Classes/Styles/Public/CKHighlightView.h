//
//  CKHighlightView.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-29.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKStyleView.h"
#import "CKLightEffectView.h"

/** The highlight view simulates light on the border of the view talking care of the [CKLight sharedInstance] attributes.
 */
@interface CKHighlightView : CKLightEffectView

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
/// @name Customizing the highlight
///-----------------------------------

/** default value is whiteColor
 */
@property (nonatomic, retain) UIColor *highlightColor;

/** default value is whiteColor with alpha 0
 */
@property (nonatomic, retain) UIColor *highlightEndColor;

/** default value is 0 meaning that highlight is not activated
 */
@property (nonatomic, assign) CGFloat highlightWidth;

/** Default value is 200
 */
@property (nonatomic, assign) CGFloat highlightRadius;

/** highlightCenter will be computed dynamically if specifying light source
 */
@property (nonatomic, assign) CGPoint highlightCenter;

@end




/**
 */
@interface UIView(CKHighlightView)

- (CKHighlightView*)highlightView;

@end