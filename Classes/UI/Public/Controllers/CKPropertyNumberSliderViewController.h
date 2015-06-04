//
//  CKPropertyNumberSliderViewController.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-06-03.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKPropertyViewController.h"

/** CKPropertyNumberSliderViewController provides the logic to edit and synchronize changes to/from a NSNumber or native type property with the desired degree of customization.
 
 #LAYOUT

 - default view padding is 10 10 10 10, flexibleSize is NO so that it fits the height of the content
 - default appearance for PropertyNameLabel is bold system font of size 17, black color, numberOfLines 1, marginBottom is 10
 - default appearance for ValueLabel is system font of size 14, black color, numberOfLines 0, marginLeft is 10
 
 <pre>
 ****************************************************
 |                                                  |
 | [PropertyNameLabel]                              |
 |                                                  |
 | [ValueSlider                      ] [ValueLabel] |
 |                                                  |
 ****************************************************
 </pre>
 
 
 #CUSTOMIZING THE APPEARANCE
 
 *Stylesheets*
 
 In the stylesheet of the view controller embedding the CKPropertyNumberSliderViewController, you can customize the appearance of this view controller as follow:

<pre>
{
    //Target your controller by type and the property path that you set when initializing your property
    
    "CKPropertyNumberSliderViewController[property.keypath=propertyPath]" : {
        
        //You can customize your CKPropertyStringViewController properties here. For example:
        "maximumValue" : 10,      
        "minimumValue" : 0,
        
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
            "hidden" : 0, //or 1
            //customize any appearance or layout properties of UILabel
                (font, textColor, margins, ...)
        },
 
        "UISlider[name=ValueSlider]" : {
            //customize any appearance or layout properties of UISlider
        }
    }
}
</pre>
 */
@interface CKPropertyNumberSliderViewController : CKPropertyViewController


/** Specifies the minimum value to set in the slider. Default is -1 meaning that it will not be set programatically. You can customize it in your stylesheet or by setting this property.
 */
@property(nonatomic,assign) CGFloat minimumValue;

/** Specifies the maximum value to set in the slider. Default is -1 meaning that it will not be set programatically. You can customize it in your stylesheet or by setting this property.
 */
@property(nonatomic,assign) CGFloat maximumValue;

/** Setting the text in the textFormat can be customized by setting a format. Default value is @"%g".
 */
@property(nonatomic,retain) NSString* textFormat;

@end
