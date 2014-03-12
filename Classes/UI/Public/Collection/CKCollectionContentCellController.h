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

/** This allows to define a collection view cell controller displaying a CKCollectionCellContentViewController in collectionViewCell's contentView with reuse capability.
 This is the equivalent of CKTableViewContentCellController for table view controller.
 */
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

/**
 */
- (CGSize)preferredSizeConstraintToSize:(CGSize)size;

@end
