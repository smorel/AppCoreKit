//
//  CKNSStringPropertyCellController.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKPropertyGridCellController.h"


/**
 */
@interface CKNSStringPropertyCellController : CKPropertyGridCellController<UITextFieldDelegate> 

///-----------------------------------
/// @name Getting the Controls
///-----------------------------------

/** textField is a weak reference to the view currently associated to this controller.
 As tableViewCell are reused, this property will be null when the controller is not displayed on screen.
 Do not keep any other reference between the textField and the controller to avoid problem with the reuse system.
 */
@property (nonatomic,retain,readonly) UITextField* textField;

@end
