//
//  UILabel+CKHighlight.h
//  YellowPages
//
//  Created by Sebastien Morel on 11-12-12.
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
