//
//  CKTableViewCell.h
//  AppCoreKit
//
//  Created by Olivier Collet.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 */
@interface CKTableViewCell : UITableViewCell

///-----------------------------------
/// @name Customizing the Appearance
///-----------------------------------

/**
 */
@property(nonatomic,retain) UIImage*   disclosureIndicatorImage;

/**
 */
@property(nonatomic,retain) UIImage*   checkMarkImage;

/**
 */
@property(nonatomic,retain) UIImage*   highlightedDisclosureIndicatorImage;

/**
 */
@property(nonatomic,retain) UIImage*   highlightedCheckMarkImage;

/**
 */
@property(nonatomic,retain) UIButton*  disclosureButton;

@end
