//
//  CKStyleView.h
//  AppCoreKit
//
//  Created by Olivier Collet.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 */
typedef NS_ENUM(NSUInteger, CKStyleViewCornerType) {
	CKStyleViewCornerTypeNone = 0,
	CKStyleViewCornerTypeTop,
	CKStyleViewCornerTypeBottom,
	CKStyleViewCornerTypeAll
} ;

/**
 */
typedef NS_ENUM(NSInteger, CKStyleViewBorderLocation){
	CKStyleViewBorderLocationNone = 0,
	CKStyleViewBorderLocationTop = 1 << 1,
	CKStyleViewBorderLocationBottom = 1 << 2,
	CKStyleViewBorderLocationRight = 1 << 3,
	CKStyleViewBorderLocationLeft = 1 << 4,
	CKStyleViewBorderLocationAll = CKStyleViewBorderLocationTop | CKStyleViewBorderLocationBottom | CKStyleViewBorderLocationRight | CKStyleViewBorderLocationLeft
} ;

/**
 */
typedef NS_ENUM(NSInteger, CKStyleViewSeparatorLocation) {
	CKStyleViewSeparatorLocationNone = CKStyleViewBorderLocationNone,
	CKStyleViewSeparatorLocationTop = CKStyleViewBorderLocationTop,
	CKStyleViewSeparatorLocationBottom = CKStyleViewBorderLocationBottom,
	CKStyleViewSeparatorLocationRight = CKStyleViewBorderLocationRight,
	CKStyleViewSeparatorLocationLeft = CKStyleViewBorderLocationLeft,
	CKStyleViewSeparatorLocationAll = CKStyleViewBorderLocationAll
} ;


/**
 */
typedef NS_ENUM(NSInteger, CKStyleViewGradientStyle){
	CKStyleViewGradientStyleVertical,
    CKStyleViewGradientStyleHorizontal
} ;

/** CKStyleView can draw several different decorators as a background for a view:
     - rounded corners with specific locations
     - background color
     - background gradient
     - background image
     - borders with specific locations
     - separator with specific locations and line attributes
     - emboss top and bottom
 */
@interface CKStyleView : UIView 

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
/// @name Customizing the background gradient
///-----------------------------------

/**
 */
@property (nonatomic,assign) CKStyleViewGradientStyle gradientStyle;

/**
 */
@property (nonatomic, retain) NSArray *gradientColors;

/**
 */
@property (nonatomic, retain) NSArray *gradientColorLocations;

///-----------------------------------
/// @name Customizing the background image
///-----------------------------------

/**
 */
@property (nonatomic, retain) UIImage *image;

/**
 */
@property (nonatomic, assign) UIViewContentMode imageContentMode;

///-----------------------------------
/// @name Adding motion effect on background image
///-----------------------------------

/** default is 0 meaning no motion effect should be applied. if a value is set, a motion effect will affect the image center between -imageMotionEffectOffset and +imageMotionEffectOffset and insets the frame of the image by twice the absolute value of imageMotionEffectOffset.
 */
@property(nonatomic,assign) CGFloat imageMotionEffectOffset;


///-----------------------------------
/// @name Customizing the border
///-----------------------------------

/**
 */
@property (nonatomic, retain) UIColor *borderColor;

/**
 */
@property (nonatomic, assign) CGFloat borderWidth;

/**
 */
@property (nonatomic, assign) NSInteger borderLocation;


///-----------------------------------
/// @name Customizing the separator
///-----------------------------------

/**
 */
@property (nonatomic, retain) UIColor *separatorColor;

/**
 */
@property (nonatomic, assign) CGFloat separatorWidth;

/** see. CGContextSetLineDash
 */
@property (nonatomic, retain) NSArray* separatorDashLengths;

/** see. CGContextSetLineDash
 */
@property (nonatomic, assign) CGFloat separatorDashPhase;

/** see. CGContextSetLineCap
 */
@property (nonatomic, assign) CGLineCap separatorLineCap;

/** see. CGContextSetLineJoin
 */
@property (nonatomic, assign) CGLineCap separatorLineJoin;

/**
 */
@property (nonatomic, assign) UIEdgeInsets separatorInsets;

/**
 */
@property (nonatomic, assign) NSInteger separatorLocation;


///-----------------------------------
/// @name Customizing the emboss
///-----------------------------------

/**
 */
@property (nonatomic, retain) UIColor *embossTopColor;

/**
 */
@property (nonatomic, retain) UIColor *embossBottomColor;


@end


/**
 */
@interface UIView(CKStyleView)

- (CKStyleView*)styleView;

@end
