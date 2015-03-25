//
//  CKPropertyBoolViewController.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-13.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKPropertyViewController.h"

//TODO: Manages Readonly !


/** CKPropertyBoolViewController provides the logic to edit and synchronize changes to/from a BOOL property with the desired degree of customization.
 
 #LAYOUT
 
 - default view padding is 10 10 10 10, flexibleSize is NO so that it fits the height of the content
 - default marginRight on *PropertyNameLabel*: 10
 - default marginRight on *SubtitleLabel*: 10
 - default marginTop on *SubtitleLabel*: 10
 - *ValueSwitch* is separated by a flexi space so that it aligns on the right.
 - default appearance for PropertyNameLabel is bold system font of size 17, black color, numberOfLines 1
 - default appearance for SubtitleLabel is  system font of size 14, black color, numberOfLines 1
 
 
 <pre>
 ****************************************************
 |                                                  |
 | [PropertyNameLabel]              [             ] |
 |                      ------------[ ValueSwitch ] |
 | [SubtitleLabel]                  [             ] |
 |                                                  |
 ****************************************************
 </pre>
 
 
 #CUSTOMIZING THE APPEARANCE
 
 *Stylesheets*
 
 In the stylesheet of the view controller embedding the CKPropertyBoolViewController, you can customize the appearance of this view controller as follow:
 
 <pre>
 {
     //Target your controller by type and the property path that you set when initializing your property
 
     "CKPropertyBoolViewController[property.keypath=propertyPath]" : {
 
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
 
         "UILabel[name=SubtitleLabel]" : {
            "hidden" : 0, //or 1
            //customize any appearance or layout properties of UILabel
              (font, textColor, margins, ...)
         },
 
         "UISwitch[name=ValueSwitch]" : {
             //customize any appearance or layout properties of UISwitch
                 (font, textColor, margins, returnKeyType, keyboardAppearance, keyboardType ...)
          }
     }
 }
 </pre>
 
 */
@interface CKPropertyBoolViewController : CKPropertyViewController

/**
 */
@property(nonatomic,retain) NSString* onSubtitleLabel;

/**
 */
@property(nonatomic,retain) NSString* offSubtitleLabel;

@end
