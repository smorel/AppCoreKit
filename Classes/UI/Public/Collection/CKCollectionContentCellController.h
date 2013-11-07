//
//  CKCollectionContentCellController.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-10-23.
//  Copyright (c) 2013 Sebastien Morel. All rights reserved.
//

#import "CKCallback.h"
#import "CKCollectionCellController.h"
#import "CKCollectionCellContentViewController.h"

//THIS SHOULD BE PART OF TE BASE MECHANISM FOR CKCollectionCellController !!!!
//CKTableViewCellController should only offer extra attributes for managing UITableViewCell specific stuff as well as CKMapAnnotationController

@interface CKCollectionContentCellController : CKCollectionCellController

/**
 */
@property(nonatomic,retain,readonly) CKCollectionCellContentViewController* contentViewController;

/**
 */
- (id)initWithContentViewController:(CKCollectionCellContentViewController*)contentViewController;

/**
 */
@property (nonatomic, retain) CKCallback* deselectionCallback;

/**
 */
- (void)didDeselect;


@end
