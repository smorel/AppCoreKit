//
//  CKTableViewController.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-18.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKSectionedViewController.h"

/**
 */
@interface CKTableViewController : CKSectionedViewController

/** default id grouped
 */
@property(nonatomic,assign) UITableViewStyle style;

/**
 */
@property(nonatomic,readonly) UITableView* tableView;

/**
 */
- (Class)tableViewClass;

/**
 */
- (void)scrollToControllerAtIndexPath:(NSIndexPath*)indexpath animated:(BOOL)animated;

@end
