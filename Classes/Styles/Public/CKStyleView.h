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

/**
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


///-----------------------------------
/// @name Customizing the light source
///-----------------------------------

/**
 */
@property (nonatomic, assign) CGPoint lightPosition;

/**
 */
@property (nonatomic, assign) CGFloat lightIntensity;

/**
 */
@property (nonatomic, assign) CGPoint lightDirection;




@end


/**
 */
@interface UIView(CKStyleView)

- (CKStyleView*)styleView;

@end
