//
//  CKCreditsFooterView.h
//  AppCoreKit
//
//  Created by Olivier Collet.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/** 
 */
typedef enum {
	CKCreditsViewStyleLight = 0,
	CKCreditsViewStyleDark
} CKCreditsViewStyle;

/** 
 */
@interface CKCreditsFooterView : UIView 

///-----------------------------------
/// @name Creating Credits Footer View
///-----------------------------------

/**
 */
+ (id)creditsViewWithStyle:(CKCreditsViewStyle)style;

@end
