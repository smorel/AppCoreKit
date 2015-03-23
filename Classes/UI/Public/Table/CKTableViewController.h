//
//  CKTableViewController.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-18.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKSectionedViewController.h"

//commented until the layout loop is solved
//#define USING_UITableViewHeaderFooterView

@class CKTableViewCell;
@class CKTableView;

/**
 */
@interface CKResusableViewController(CKTableViewController)

/**
 */
@property(nonatomic,readonly) CKTableViewCell* tableViewCell;

#ifdef USING_UITableViewHeaderFooterView
/**
 */
@property(nonatomic,readonly) UITableViewHeaderFooterView* headerFooterView;
#endif

@end




/**
 */
@interface CKTableViewController : CKSectionedViewController

/** default id grouped
 */
@property(nonatomic,assign) UITableViewStyle style;

/**
 */
@property(nonatomic,readonly) CKTableView* tableView;

/**
 */
@property(nonatomic,retain) CKResusableViewController* tableHeaderViewController;

/**
 */
@property(nonatomic,retain) CKResusableViewController* tableFooterViewController;

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
