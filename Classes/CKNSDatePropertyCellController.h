//
//  CKNSDatePropertyCellController.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-06-09.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKPropertyGridCellController.h"
#include "CKSheetController.h"

/** TODO
 */
typedef enum CKDatePickerMode{
    CKDatePickerModeTime = UIDatePickerModeTime,   
    CKDatePickerModeDate = UIDatePickerModeDate,
    CKDatePickerModeDateAndTime = UIDatePickerModeDateAndTime,   
    CKDatePickerModeCountDownTime = UIDatePickerModeCountDownTimer,
    CKDatePickerModeCreditCardExpirationDate
} CKDatePickerMode;


/** TODO
 */
@interface CKNSDateViewController : CKViewController<UIPickerViewDataSource,UIPickerViewDelegate>

///-----------------------------------
/// @name Initializing a CKNSDateViewController Object
///-----------------------------------

/**
 */
- (id)initWithProperty:(CKProperty*)property mode:(CKDatePickerMode)mode;

///-----------------------------------
/// @name Customizing the appearance
///-----------------------------------

/** 
 */
@property(nonatomic,assign)CKDatePickerMode datePickerMode;

///-----------------------------------
/// @name Getting the picker view
///-----------------------------------

/** 
 */
@property(nonatomic,retain)UIDatePicker* datePicker;

/** if mode == CKDatePickerModeCreditCardExpirationDate
 */
@property(nonatomic,retain)UIPickerView* pickerView;

///-----------------------------------
/// @name Managing the delegate
///-----------------------------------

/** 
 */
@property(nonatomic,assign)id delegate;

///-----------------------------------
/// @name Managing the property
///-----------------------------------

/**
 */
@property(nonatomic,assign)CKProperty* property;

@end




/** TODO
 */
@interface CKNSDatePropertyCellController : CKPropertyGridCellController<CKSheetControllerDelegate>

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
- (void)onBeginEditingUsingViewController:(CKNSDateViewController*)dateViewController;

/**
 */
- (void)onEndEditing;

///-----------------------------------
/// @name Customizing the appearance
///-----------------------------------

/** 
 */
@property(nonatomic,assign)CKDatePickerMode datePickerMode;


@end
