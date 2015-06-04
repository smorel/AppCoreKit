//
//  CKPropertyStringViewController.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-04.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKPropertyViewController.h"


/** CKPropertyStringViewController provides the logic to edit and synchronize changes to/from a NSString property with the desired degree of customization.
 
 #LAYOUT
 
 If multiline is not enabled:
 
 - default view padding is 10 10 10 10, flexibleSize is NO so that it fits the height of the content
 - default marginRight on *PropertyNameLabel*: 10
 - *ValueTextField* is flexible, minimumWidth 100, system font 14, back color, textAlignmentRight,clearButton mode is UITextFieldViewModeWhileEditing, keyboard type is UIKeyboardTypeDecimalPad and autocorrectionType is No if property is native type or NSNumber
 - default appearance for PropertyNameLabel is bold system font of size 17, black color, numberOfLines 1
 
 
 <pre>
 ****************************************************
 |                                                  |
 | [PropertyNameLabel]  [          ValueTextField ] |
 |                                                  |
 ****************************************************
 </pre>
 
 
 If multiline is enabled:
 
 - default view padding: 10 10 10 10, flexibleSize is NO so that it fits the height of the content
 - default marginTop on *ValueTextView*: 10
 - *ValueTextView* is flexible in width but fits to the content height, system font 14, back color,clearButton mode is UITextFieldViewModeWhileEditing, keyboard type is UIKeyboardTypeDecimalPad and autocorrectionType is No if property is native type or NSNumber
 - default appearance for PropertyNameLabel is bold system font of size 17, black color, numberOfLines 1
 
 
 <pre>
 ****************************************************
 |                                                  |
 | [PropertyNameLabel]                              |
 |                                                  |
 | [ValueTextView                                 ] |
 | [                                              ] |
 | [                                              ] |
 | [                                              ] |
 |                                                  |
 ****************************************************
 </pre>
 
 
 #CUSTOMIZING THE APPEARANCE
 
 *Stylesheets*

 In the stylesheet of the view controller embedding the CKPropertyStringViewController, you can customize the appearance of this view controller as follow:
 
 <pre>
 {
     //Target your controller by type and the property path that you set when initializing your property
 
     "CKPropertyStringViewController[property.keypath=propertyPath]" : {
 
         //You can customize your CKPropertyStringViewController properties here. For example:
         "maximumLength" : 10,
         "multiline" : 1,
 
         "view" : {
            //customize the view containing the labels and text input views here
         },
 
         "UILabel[name=PropertyNameLabel]" : {
            "hidden" : 0, //or 1
            "maximumWidth" : 100,
            "numberOfLines" : 0
            //customize any appearance or layout properties of UILabel  
               (font, textColor, margins, ...)
         },
 
         "UITextField[name=ValueTextField]" : {
            //customize any appearance or layout properties of UITextField and UITextInputTraits
               (font, textColor, margins, returnKeyType, keyboardAppearance, keyboardType ...)
         },
 
         "CKTextView[name=ValueTextView]" : {
            //customize any appearance or layout properties of UITextField and UITextInputTraits
               (font, textColor, margins, returnKeyType, keyboardAppearance, keyboardType ...)
         }
     }
 }
 </pre>
 
 */
@interface CKPropertyStringViewController : CKPropertyViewController

/** Default value is a localized string as follow: _(@"propertyName_placeholder") that can be customized by setting a key/value in your localization file as follow:
 "propertyName_placeholder" = "My Placeholder";
 If the property is a number and the extended attribute placeholderValue property is set, valuePlaceholderLabel will have the specified value.
 Or simply set the valuePlaceholderLabel property programatically or in your stylesheet in the CKPropertyStringViewController scope.
 */
@property(nonatomic,retain) NSString* valuePlaceholderLabel;

/** Specifies the maximum length after what the user text entry is no more taken into account.
 Default value is 0 meaning their is no limits. When initializing the controller with the property, maximumLength will be set accordingly to the maximumLength value set in the properties extended attributes.
 */
@property(nonatomic,assign) BOOL maximumLength;

/** Specifies the minimum length after what the user text entry is no more taken into account.
 Default value is 0 meaning their is no limits. When initializing the controller with the property, minimumLength will be set accordingly to the minimumLength value set in the properties extended attributes.
 */
@property(nonatomic,assign) BOOL minimumLength;

/** Specifies if the entry view should allow multiline text or single line.
 Default value is NO. When initializing the controller with the property, multiline will be set accordingly to the multiLineEnabled flag set in the properties extended attributes.
 */
@property(nonatomic,assign) BOOL multiline;

/** By setting this block, you can customize the formatting of the text while the user is editing it. Some formatting helpers are provided in "NSString+Formating.h".
 Default value is NO. When initializing the controller with the property, textInputFormatter will be set accordingly to the textInputFormatterBlock set in the properties extended attributes.
 */
@property (nonatomic,copy) BOOL(^textInputFormatter)(id textInputView,NSRange range, NSString* replacementString);

/** Setting the text in the textFormat can be customized by setting a format. Default value is @"%@".
 */
@property(nonatomic,retain) NSString* textFormat;


/** This block will get called when the user hits the done button in the keyboard.
 If no block is set, the keyboard will get resigned automatically.
 If a block is set, this is your responsability to resign the keyboard as follow : [cellController resignFirstResponder];
 */
@property (nonatomic,copy) void(^returnKeyHasBeenTapped)(CKPropertyStringViewController* cellController);

@end






/** Property extended attributes that operates with CKPropertyStringViewController
 */
@interface CKPropertyExtendedAttributes (CKPropertyStringViewController)

///-----------------------------------
/// @name Extended attributes
///-----------------------------------

/**
 */
@property (nonatomic, copy) BOOL(^textInputFormatterBlock)(id textInputView,NSRange range, NSString* replacementString);

/**
 */
@property (nonatomic, assign) NSInteger minimumLength;

/**
 */
@property (nonatomic, assign) NSInteger maximumLength;

@end


