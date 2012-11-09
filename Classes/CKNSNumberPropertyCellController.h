//
//  CKNSNumberPropertyCellController.h
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
@interface CKNSNumberPropertyCellController : CKPropertyTableViewCellController<UITextFieldDelegate>

///-----------------------------------
/// @name Getting the Controls
///-----------------------------------

/** textField is a weak reference to the view currently associated to this controller if the property represents a number.
 As tableViewCell are reused, this property will be null when the controller is not displayed on screen.
 Do not keep any other reference between the textField and the controller to avoid problem with the reuse system.
 */
@property (nonatomic,retain,readonly) UITextField* textField;

/** toggleSwitch is a weak reference to the view currently associated to this controller if the property represents a 'char'.
 As tableViewCell are reused, this property will be null when the controller is not displayed on screen.
 Do not keep any other reference between the toggleSwitch and the controller to avoid problem with the reuse system.
 */
@property (nonatomic,retain,readonly) UISwitch* toggleSwitch;

/**
 */
@property (nonatomic,copy) CKInputTextFormatterBlock textInputFormatterBlock;

@end
