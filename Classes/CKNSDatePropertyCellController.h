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

typedef enum CKDatePickerMode{
    CKDatePickerModeTime = UIDatePickerModeTime,   
    CKDatePickerModeDate = UIDatePickerModeDate,
    CKDatePickerModeDateAndTime = UIDatePickerModeDateAndTime,   
    CKDatePickerModeCountDownTime = UIDatePickerModeCountDownTimer,
    CKDatePickerModeCreditCardExpirationDate
} CKDatePickerMode;

@interface CKNSDateViewController : CKViewController<UIPickerViewDataSource,UIPickerViewDelegate>{
    CKProperty* _property;
    UIDatePicker* _datePicker;
    UIPickerView* _pickerView;
    CKDatePickerMode _datePickerMode;
    id _delegate;
}

@property(nonatomic,assign)CKProperty* property;
@property(nonatomic,retain)UIDatePicker* datePicker;
@property(nonatomic,retain)UIPickerView* pickerView;//if mode == CKDatePickerModeCreditCardExpirationDate
@property(nonatomic,assign)id delegate;
@property(nonatomic,assign)CKDatePickerMode datePickerMode;

- (id)initWithProperty:(CKProperty*)property mode:(CKDatePickerMode)mode;

@end

/** TODO
 */
@interface CKNSDatePropertyCellController : CKPropertyGridCellController<CKSheetControllerDelegate> {
    CKCallback* _onBeginEditingCallback;
    CKCallback* _onEndEditingCallback;
    BOOL _enableAccessoryView;
    CKDatePickerMode _datePickerMode;
}

//the value of the callback is the CKNSDateViewController with the picker
@property(nonatomic,retain)CKCallback* onBeginEditingCallback;
//the value of the callback is CKNSDatePropertyCellController
@property(nonatomic,retain)CKCallback* onEndEditingCallback;
@property(nonatomic,assign)BOOL enableAccessoryView;
@property(nonatomic,assign)CKDatePickerMode datePickerMode;

//private
- (void)onBeginEditingUsingViewController:(CKNSDateViewController*)dateViewController;
- (void)onEndEditing;

@end
