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


@interface CKNSDateViewController : CKUIViewController{
    CKObjectProperty* _property;
    UIDatePicker* _datePicker;
    id _delegate;
}

@property(nonatomic,assign)CKObjectProperty* property;
@property(nonatomic,retain)UIDatePicker* datePicker;
@property(nonatomic,assign)id delegate;

- (id)initWithProperty:(CKObjectProperty*)property;

@end


/** TODO
 */
@interface CKNSDatePropertyCellController : CKPropertyGridCellController<CKSheetControllerDelegate> {
    CKCallback* _onBeginEditingCallback;
    CKCallback* _onEndEditingCallback;
    BOOL _enableAccessoryView;
}

//the value of the callback is the CKNSDateViewController with the picker
@property(nonatomic,retain)CKCallback* onBeginEditingCallback;
//the value of the callback is CKNSDatePropertyCellController
@property(nonatomic,retain)CKCallback* onEndEditingCallback;
@property(nonatomic,assign)BOOL enableAccessoryView;

//private
- (void)onBeginEditingUsingViewController:(CKNSDateViewController*)dateViewController;
- (void)onEndEditing;

@end
