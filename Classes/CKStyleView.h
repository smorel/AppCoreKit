//
//  CKStyleView.h
//  AppCoreKit
//
//  Created by Olivier Collet.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKRoundedCornerView.h"

/**
 */
typedef enum {
	CKStyleViewBorderLocationNone = 0,
	CKStyleViewBorderLocationTop = 1 << 1,
	CKStyleViewBorderLocationBottom = 1 << 2,
	CKStyleViewBorderLocationRight = 1 << 3,
	CKStyleViewBorderLocationLeft = 1 << 4,
	CKStyleViewBorderLocationAll = CKStyleViewBorderLocationTop | CKStyleViewBorderLocationBottom | CKStyleViewBorderLocationRight | CKStyleViewBorderLocationLeft
} CKStyleViewBorderLocation;

/**
 */
typedef enum {
	CKStyleViewSeparatorLocationNone = CKStyleViewBorderLocationNone,
	CKStyleViewSeparatorLocationTop = CKStyleViewBorderLocationTop,
	CKStyleViewSeparatorLocationBottom = CKStyleViewBorderLocationBottom,
	CKStyleViewSeparatorLocationRight = CKStyleViewBorderLocationRight,
	CKStyleViewSeparatorLocationLeft = CKStyleViewBorderLocationLeft,
	CKStyleViewSeparatorLocationAll = CKStyleViewBorderLocationAll
} CKStyleViewSeparatorLocation;



/**
 */
@interface CKStyleView : CKRoundedCornerView 

///-----------------------------------
/// @name Customizing the appearance
///-----------------------------------

/**
 */
@property (nonatomic, retain) NSArray *gradientColors;

/**
 */
@property (nonatomic, retain) NSArray *gradientColorLocations;

/**
 */
@property (nonatomic, retain) UIImage *image;

/**
 */
@property (nonatomic, assign) UIViewContentMode imageContentMode;

/**
 */
@property (nonatomic, retain) UIColor *borderColor;

/**
 */
@property (nonatomic, assign) CGFloat borderWidth;

/**
 */
@property (nonatomic, assign) NSInteger borderLocation;

/**
 */
@property (nonatomic, retain) UIColor *separatorColor;

/**
 */
@property (nonatomic, assign) CGFloat separatorWidth;

/**
 */
@property (nonatomic, assign) NSInteger separatorLocation;

/**
 */
@property (nonatomic, retain) UIColor *embossTopColor;

/**
 */
@property (nonatomic, retain) UIColor *embossBottomColor;

@end
