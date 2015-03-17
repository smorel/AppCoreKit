//
//  CKNSDatePropertyCellController.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKPropertyTableViewCellController.h"
#include "CKSheetController.h"

#import "CKDatePickerViewController.h"



/**
 */
@interface CKNSDatePropertyCellController : CKPropertyTableViewCellController<CKSheetControllerDelegate>

///-----------------------------------
/// @name Editing
///-----------------------------------

/** the value of the callback is the CKNSDateViewController with the picker
 */
@property(nonatomic,retain)CKCallback* onBeginEditingCallback;

/** the value of the callback is CKNSDatePropertyCellController
 */
@property(nonatomic,retain)CKCallback* onEndEditingCallback;

/**
 */
- (void)onBeginEditingUsingViewController:(CKDatePickerViewController*)dateViewController;

/**
 */
- (void)onEndEditing;

/**
 */
- (void)resignFirstResponder;

///-----------------------------------
/// @name Customizing the appearance
///-----------------------------------

/** 
 */
@property(nonatomic,assign)CKDatePickerMode datePickerMode;


@end
