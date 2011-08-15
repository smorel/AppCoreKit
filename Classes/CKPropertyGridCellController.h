//
//  CKPropertyGridCellController.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-08.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKTableViewCellController.h"
#import "CKObjectProperty.h"

/** 
 CKPropertyGridCellController is a base class for cell controllers working with a CKObjectProperty value.
 This provides the base value for the mecanisms that should be implemented in subclasses like readonly, or value validation.
 */
@interface CKPropertyGridCellController : CKTableViewCellController {
    UIButton* _validationButton;
    UIImageView* _validationImageView;
    UIView* _oldAccessoryView;
    UITableViewCellAccessoryType _oldAccessoryType;
    BOOL _validationDisplayed;
}
/** 
 Specify whether the cell should be editable or readonly. Depending on this value, the detail ui view should change.
 */
@property(nonatomic,assign)BOOL readOnly;

///-----------------------------------
/// @name Accessing Object Property
///-----------------------------------
/** 
 This method checks if the controller's value is a CKObjectProperty and will assert if not valid.
 @return the object property.
 */
- (CKObjectProperty*)objectProperty;

///-----------------------------------
/// @name Validating Value for Object Property
///-----------------------------------
/** 
 This method will use the predicate defined in the object property metaData to validate the value that is edited by the user.
 @param id value : the value that should be validated
 @return A boolean indicating if the value is valid.
 */
- (BOOL)isValidValue:(id)value;

/** 
 This method will validate the value using the property predicate, set the value in the property and update the display to reflect validation status.
 @param id value : the value that should be validated
 */
- (void)setValueInObjectProperty:(id)value;


//Private
- (void)setInvalidButtonVisible:(BOOL)visible;
- (void)performValidationLayout:(CKPropertyGridCellController*)controller;

@end
