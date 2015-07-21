//
//  CKPropertyTextField.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-07-21.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKProperty.h"

/**
 */
@interface CKPropertyTextField : UITextField<UITextFieldDelegate>

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

/** Default value is a localized string as follow: _(@"propertyName_placeholder") that can be customized by setting a key/value in your localization file as follow:
 "propertyName_placeholder" = "My Placeholder";
 If the property is a number and the extended attribute placeholderValue property is set, valuePlaceholderLabel will have the specified value.
 Or simply set the valuePlaceholderLabel property programatically or in your stylesheet in the CKPropertyStringViewController scope.
 */
@property(nonatomic,retain) NSString* valuePlaceholderLabel;

/** By setting this block, you can customize the formatting of the text while the user is editing it. Some formatting helpers are provided in "NSString+Formating.h".
 Default value is NO. When initializing the controller with the property, textInputFormatter will be set accordingly to the textInputFormatterBlock set in the properties extended attributes.
 */
@property (nonatomic,copy) BOOL(^textInputFormatter)(id textInputView,NSRange range, NSString* replacementString);

/** Setting the text in the textFormat can be customized by setting a format. Default value is @"%@".
 */
@property(nonatomic,retain) NSString* textFormat;

/** Specifies the maximum length after what the user text entry is no more taken into account.
 Default value is 0 meaning their is no limits. When initializing the controller with the property, maximumLength will be set accordingly to the maximumLength value set in the properties extended attributes.
 */
@property(nonatomic,assign) BOOL maximumLength;

/** Specifies the minimum length after what the user text entry is no more taken into account.
 Default value is 0 meaning their is no limits. When initializing the controller with the property, minimumLength will be set accordingly to the minimumLength value set in the properties extended attributes.
 */
@property(nonatomic,assign) BOOL minimumLength;

/** This block will get called when the user hits the done button in the keyboard.
 If no block is set, the keyboard will get resigned automatically.
 */
@property (nonatomic,copy) void(^returnKeyHasBeenTapped)(CKPropertyTextField* textField);

/**
 */
@property (nonatomic,copy) void(^didResignFirstResponder)(CKPropertyTextField* textField);

/**
 */
@property (nonatomic,copy) void(^didBecomeFirstResponder)(CKPropertyTextField* textField);

@end
