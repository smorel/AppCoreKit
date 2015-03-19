//
//  CKTableViewController.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-18.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKSectionedViewController.h"

@class CKTableViewCell;

/**
 */
@interface CKCollectionCellContentViewController(CKTableViewController)

/**
 */
@property(nonatomic,readonly) CKTableViewCell* tableViewCell;

@end




/**
 */
@interface CKTableViewController : CKSectionedViewController

/** default id grouped
 */
@property(nonatomic,assign) UITableViewStyle style;

/**
 */
@property(nonatomic,readonly) UITableView* tableView;

/** Default is YES
 */
@property(nonatomic,assign) BOOL endEditingViewWhenScrolling;

/** Default is YES
 */
@property(nonatomic,assign) BOOL adjustInsetsOnKeyboardNotification;

/**
 */
- (Class)tableViewClass;

/**
 */
- (void)scrollToControllerAtIndexPath:(NSIndexPath*)indexpath animated:(BOOL)animated;

@end
