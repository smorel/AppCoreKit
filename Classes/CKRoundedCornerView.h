//
//  CKRoundedCornerView.h
//  AppCoreKit
//
//  Created by Olivier Collet.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 */
typedef enum {
	CKRoundedCornerViewTypeNone = 0,
	CKRoundedCornerViewTypeTop,
	CKRoundedCornerViewTypeBottom,
	CKRoundedCornerViewTypeAll
} CKRoundedCornerViewType;


/**
 */
@interface CKRoundedCornerView : UIView

///-----------------------------------
/// @name Customizing the appearance
///-----------------------------------

/**
 */
@property (nonatomic,assign) CKRoundedCornerViewType corners;

/**
 */
@property (nonatomic,assign) CGFloat roundedCornerSize;

@end
