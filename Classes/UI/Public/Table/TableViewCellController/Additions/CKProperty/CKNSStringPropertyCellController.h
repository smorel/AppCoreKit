//
//  CKNSStringPropertyCellController.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKPropertyTableViewCellController.h"
#import "CKPropertyExtendedAttributes+Attributes.h"


/**
 */
@interface CKNSStringPropertyCellController : CKPropertyTableViewCellController<UITextFieldDelegate> 

///-----------------------------------
/// @name Getting the Controls
///-----------------------------------

/** textField is a weak reference to the view currently associated to this controller.
 As tableViewCell are reused, this property will be null when the controller is not displayed on screen.
 Do not keep any other reference between the textField and the controller to avoid problem with the reuse system.
 */
@property (nonatomic,retain,readonly) UITextField* textField;

/** This block will get called when the user hits the done button in the keyboard.
    If no block is set, the keyboard will get resigned automatically.
    If a block is set, this is your responsability to resign the keyboard as follow : [cellController.textField resignFirstResponder];
 */
@property (nonatomic,copy) void(^returnKeyBlock)(CKNSStringPropertyCellController* cellController);

/**
 */
@property (nonatomic,copy) CKInputTextFormatterBlock textInputFormatterBlock;

@end
