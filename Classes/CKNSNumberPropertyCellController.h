//
//  CKNSNumberPropertyCellController.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-01.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKPropertyGridCellController.h"


/** TODO
 */
@interface CKNSNumberPropertyCellController : CKPropertyGridCellController<UITextFieldDelegate>

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

@end
