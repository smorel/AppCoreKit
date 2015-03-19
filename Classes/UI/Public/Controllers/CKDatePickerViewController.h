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

/**
 */
@property (nonatomic, retain) NSLocale   *locale;   // default is [NSLocale currentLocale]. setting nil returns to default

/**
 */
@property (nonatomic, retain) NSCalendar *calendar; // default is [NSCalendar currentCalendar]. setting nil returns to default

/**
 */
@property (nonatomic, retain) NSTimeZone *timeZone;


/**
 */
@property (nonatomic, retain) NSDate *minimumDate;

/**
 */
@property (nonatomic, retain) NSDate *maximumDate;

/** default value is NSNotFound (not taken into account)
 */
@property (nonatomic, assign) NSInteger minuteInterval;

@end
