//
//  CKTableViewContentCellController.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2/12/2014.
//  Copyright (c) 2014 Sebastien Morel. All rights reserved.
//

#import "CKTableViewCellController.h"
#import "CKReusableViewController.h"

//THIS SHOULD BE PART OF TE BASE MECHANISM FOR CKCollectionCellController !!!!
//CKTableViewCellController should only offer extra attributes for managing UITableViewCell specific stuff as well as CKMapAnnotationController
//cf. CKCollectionContentCellController

/** This allows to define a table view cell controller displaying a CKReusableViewController in tableViewCell's contentView with reuse capability.
 This is the equivalent of CKCollectionContentCellController for collection view layout controller.
 */
@interface CKTableViewContentCellController : CKTableViewCellController

/**
 */
@property(nonatomic,retain,readonly) CKReusableViewController* contentViewController;

/**
 */
- (id)initWithContentViewController:(CKReusableViewController*)contentViewController;

/**
 */
- (CGSize)preferredSizeConstraintToSize:(CGSize)size;

@end




@interface CKReusableViewController(CKTableViewContentCellController)

- (CKTableViewContentCellController*)createTableViewCellController;

@end