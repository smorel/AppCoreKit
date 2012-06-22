//
//  CKPropertyGridCellController.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-08.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKTableViewCellController.h"
#import "CKProperty.h"
#import "CKPropertyExtendedAttributes+CKAttributes.h"

#define CLICKABLE_VALIDATION_INFO 0

/** 
 CKPropertyGridCellController is a base class for cell controllers working with a CKProperty value.
 This provides the base value for the mecanisms that should be implemented in subclasses like readonly, or value validation.
 */
@interface CKPropertyGridCellController : CKTableViewCellController 

///-----------------------------------
/// @name Customizing the appearance
///-----------------------------------

/** 
 Specify whether the cell should be editable or readonly. Depending on this value, the detail ui view should change.
 */
@property(nonatomic,assign)BOOL readOnly;

/** this will avoid to call begin/endUpdates on tableView when the validity state change
 */
@property(nonatomic,assign)BOOL fixedSize;

///-----------------------------------
/// @name Customizing the Toolbar for editing
///-----------------------------------

/**
 */
@property(nonatomic,assign)BOOL enableNavigationToolbar;

/**
 */
@property(nonatomic,retain)UIToolbar* navigationToolbar;


///-----------------------------------
/// @name Accessing Object Property
///-----------------------------------
/** 
 This method checks if the controller's value is a CKProperty and will assert if not valid.
 @return the object property.
 */
- (CKProperty*)objectProperty;

///-----------------------------------
/// @name Validating Value for Object Property
///-----------------------------------
/** 
 This method will use the predicate defined in the object property attributes to validate the value that is edited by the user.
 @param id value : the value that should be validated
 @return A boolean indicating if the value is valid.
 */
- (BOOL)isValidValue:(id)value;

/** 
 This method will validate the value using the property predicate, set the value in the property and update the display to reflect validation status.
 @param id value : the value that should be validated
 */
- (void)setValueInObjectProperty:(id)value;


@end
