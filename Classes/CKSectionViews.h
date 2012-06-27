//
//  CKSectionViews.h
//  CloudKit
//
//  Created by Sebastien Morel on 12-05-31.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKStyleView.h"
#import "CKTableViewController.h"

/**
 */
@interface CKSectionHeaderView : CKStyleView

///-----------------------------------
/// @name Customizing the view
///-----------------------------------

/**
 */
@property(nonatomic,copy) NSString* text;

/**
 */
@property(nonatomic,retain,readonly) UILabel* label;

/**
 */
@property(nonatomic,assign) UIEdgeInsets contentInsets;

///-----------------------------------
/// @name Getting the parent table view controller
///-----------------------------------

/**
 */
@property(nonatomic,assign,readonly) CKTableViewController* tableViewController;

@end


/**
 */
@interface CKSectionFooterView : CKSectionHeaderView
@end
