//
//  CKViewControllerCellController.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 WhereCloud Inc. All rights reserved.
//

#import "CKTableViewCellController.h"

/**
 */
@interface CKViewControllerCellController : CKTableViewCellController

///-----------------------------------
/// @name Customizing the Appearance
///-----------------------------------

/**
 */
@property(nonatomic,retain) UIViewController* viewController;

/** If you inherits CKViewControllerCellController, you can overload this method to execute cutom code when the viewController's view is inserted in the tebleViewCell contentView.
 */
- (void)setupViewControllerView:(UIView*)view;

@end
