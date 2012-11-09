//
//  UILabel+Highlight.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 WhereCloud Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 */
@interface UILabel (CKHighlight)

///-----------------------------------
/// @name Managing Highlight Values
///-----------------------------------

/**
 */
@property(nonatomic,retain) UIColor* highlightedShadowColor;

/**
 */
@property(nonatomic,retain) UIColor* highlightedBackgroundColor;

@end
