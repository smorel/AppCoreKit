//
//  CKOptionPropertyCellController.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKPropertyTableViewCellController.h"
#import "CKOptionTableViewController.h"

/**
 */
@interface CKOptionPropertyCellController : CKPropertyTableViewCellController 

///-----------------------------------
/// @name Customizing the appearance
///-----------------------------------

/**
 */
@property (nonatomic,assign) CKTableViewCellStyle optionCellStyle;

/**
 */
@property (nonatomic,assign) CKOptionPropertyCellControllerPresentationStyle presentationStyle;

///-----------------------------------
/// @name Getting the optionsViewController representing the options on selection
///-----------------------------------

/**
 */
@property (nonatomic,retain,readonly) CKOptionTableViewController* optionsViewController;

@end
