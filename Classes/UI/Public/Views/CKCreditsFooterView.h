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
typedef NS_ENUM(NSInteger, CKCreditsViewStyle) {
	CKCreditsViewStyleLight = 0,
	CKCreditsViewStyleDark
} ;

/** 
 */
@interface CKCreditsFooterView : UIView 

///-----------------------------------
/// @name Creating Credits Footer View
///-----------------------------------

/**
 */
+ (id)creditsViewWithStyle:(CKCreditsViewStyle)style;


/**
 */
@property (nonatomic, retain, readonly) UIImageView *titleView;

/**
 */
@property (nonatomic, retain, readonly) UIImageView *plateView;

/**
 */
@property (nonatomic, retain, readonly) UIImageView *plateBackView;

/**
 */
@property (nonatomic, retain, readonly) UILabel *versionLabel;

/**
 */
@property (nonatomic, retain, readonly) UIButton *versionLabelSwitchButton;

@end
