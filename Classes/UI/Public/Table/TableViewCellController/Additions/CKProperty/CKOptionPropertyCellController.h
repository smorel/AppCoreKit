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

/** by specifying optionCellControllerCreationBlock, the optionCellStyle will not be taken into account as you have full control on how to represent the
    row. The accessory type Checkmark will therefore be set for you if the selected values is your row.
 */
@property (nonatomic, copy) CKTableViewCellController*(^optionCellControllerCreationBlock)(NSString* label, id value);

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
