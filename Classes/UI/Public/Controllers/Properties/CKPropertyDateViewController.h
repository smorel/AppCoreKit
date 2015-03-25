//
//  CKPropertyDateViewController.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-18.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKPropertyViewController.h"
#import "CKDatePickerViewController.h"

/** CKPropertyDateViewController provides the logic to edit and synchronize changes to/from a NSDate property with the desired degree of customization.
 
 #LAYOUT
 
 - default view padding is 10 10 10 10, flexibleSize is NO so that it fits the height of the content
 - default marginRight on *PropertyNameLabel*: 10
 - default appearance for PropertyNameLabel is bold system font of size 17, black color, numberOfLines 1
 - *ValueLabel* is separated by a flexi space so that it aligns on the right, system font of size 14, black color, numberOfLines 1
 
 
 <pre>
 ****************************************************
 |                                                  |
 | [PropertyNameLabel] --------------[ ValueLabel ] |
 |                                                  |
 ****************************************************
 </pre>
 
 
 #CUSTOMIZING THE APPEARANCE
 
 *Stylesheets*
 
 In the stylesheet of the view controller embedding the CKPropertyDateViewController, you can customize the appearance of this view controller as follow:
 
 <pre>
 {
     //Target your controller by type and the property path that you set when initializing your property
 
     "CKPropertyDateViewController[property.keypath=propertyPath]" : {
 
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
 
          "UILabel[name=ValueLabel]" : {
             //customize any appearance or layout properties of UILabel
               (font, textColor, margins, ...)
          }
      }
 }
 </pre>
 
 */
@interface CKPropertyDateViewController : CKPropertyViewController

/** Default value is a localized string as follow: _(@"propertyName_placeholder") that can be customized by setting a key/value in your localization file as follow:
 "propertyName_placeholder" = "My Placeholder";
 Or simply set the valuePlaceholderLabel property programatically or in your stylesheet in the CKPropertyDateViewController scope.
 */
@property(nonatomic,retain) NSString* valuePlaceholderLabel;

/**
 */
@property(nonatomic,retain) NSDateFormatter* dateFormatter;


/** default value is CKDatePickerModeDate
 */
@property(nonatomic,assign) CKDatePickerMode editionControllerPickerMode;

/**
 */
@property (nonatomic, retain) NSDate *editionControllerPickerMinimumDate;

/**
 */
@property (nonatomic, retain) NSDate *editionControllerPickerMaximumDate;

/** default value is NSNotFound (not taken into account)
 */
@property (nonatomic, assign) NSInteger editionControllerPickerMinuteInterval;

/** Defines how we should present the edition controller. Default value is CKPropertyEditionPresentationStyleInline.
 */
@property(nonatomic,assign) CKPropertyEditionPresentationStyle editionControllerPresentationStyle;

@end
