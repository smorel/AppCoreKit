//
//  CKDatePickerViewController.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-17.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKViewController.h"
#import "CKProperty.h"


//TODO: refactor to make it clean! copied from CKNSDatePropertyCellController

/**
 */
typedef NS_ENUM(NSInteger, CKDatePickerMode){
    CKDatePickerModeTime = UIDatePickerModeTime,
    CKDatePickerModeDate = UIDatePickerModeDate,
    CKDatePickerModeDateAndTime = UIDatePickerModeDateAndTime,
    CKDatePickerModeCountDownTime = UIDatePickerModeCountDownTimer,
    CKDatePickerModeCreditCardExpirationDate
} ;


/**
 */
@interface CKDatePickerViewController : CKViewController

///-----------------------------------
/// @name Initializing a CKDatePickerViewController Object
///-----------------------------------

/**
 */
- (id)initWithProperty:(CKProperty*)property mode:(CKDatePickerMode)mode;

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


@end
