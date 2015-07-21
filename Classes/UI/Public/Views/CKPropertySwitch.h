//
//  CKPropertySwitch.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-07-21.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKProperty.h"

/**
 */
@interface CKPropertySwitch : UISwitch

/**
 */
- (id)initWithProperty:(CKProperty*)property readOnly:(BOOL)readOnly;

/** The property to be synched and displayed in the current property textfield
 */
@property(nonatomic,retain) CKProperty* property;

/**
 Specify whether the cell should be editable or readonly. default value is NO if the property itself is not readonly.
 Setting it to NO when the property is readonly in the class definition will have no effect and will be reset to YES.
 Setting this property to YES while the view is displayed will resign responder if the property was currently edited.
 */
@property(nonatomic,assign)BOOL readOnly;

@end
