//
//  CKPropertySelectionViewController.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-13.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKPropertyViewController.h"
#import "CKReusableViewControllerFactory.h"
#import "CKStandardContentViewController.h"

/** CKPropertySelectionValue represents an enum or bitfield value and label.
 */
@interface CKPropertySelectionValue : NSObject

/**
 */
@property(nonatomic,retain) CKProperty* property;

/**
 */
@property(nonatomic,retain) NSString* label;

/**
 */
@property(nonatomic,retain) id value;

@end

/**
 * Controls the presentation mode for the selection choices
 * CKPropertyEditionAppearanceStyleList : Displays the possible selection choices in a table view
 * CKPropertyEditionAppearanceStylePicker : Displays the selection choices as a picker
 *
 */
typedef NS_ENUM(NSInteger, CKPropertyEditionAppearanceStyle){
    CKPropertyEditionAppearanceStyleDefault,
    CKPropertyEditionAppearanceStyleList,
    CKPropertyEditionAppearanceStylePicker
};


/** CKPropertySelectionViewController provides the logic to edit and synchronize changes to/from an Enum, Bitfield, array, collection or object property by providing single or multiselection mechanism with the desired degree of customization. MultiSelection is enabled by default in case the property is an array or a bit mask.
 
 The values and labels can be specified by using some of the init method provided in CKPropertySelectionViewController or by using the CKEnumDescriptor or valuesAndLabels set to your property extended attributes. Implements this in the class owning your property:
 
 - (void)myPropertyExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
     attributes.enumDescriptor = CKEnumDefinition(@"MyEnum",
         MyEnumValue0,
         MyEnumValue1
     );
 
 //or
 
     attributes.valuesAndLabels = @{ 
         @"MyLabel0" : @(123),
         @"MyLabel0" : @(342)
     };
 }
 
 By tapping on the controller, a table view or a picker view controller will be presented with the associated labels and values using the specified presentationStyle.
 By default, the labels representing each values is a localized version of the string matches the actual enum or label strings in your code. You can customize the label of each individual enum values by adding key/values in your localization string as follow:
     "MyEnumValue0" = "My Enum Value 0";
 
 The images representing each value are loaded using [UIImage imageNamed:@"icon_EnumValue"]. In the example above, the image name would have been "icon_MyEnumValue0". If we do not find any image with this name, or if multiselection is enabled, the cell will display a disclosure indicator instead.
 
 You can also sort and customize the appearance of the cells for each enum value by leveraging the following properties: itemCellControllerFactory, sortItemBlock.
 
 If the property is a bit mask (enumDescriptor declared using CKBitMaskDefinition), multiselection will be enabled and the value in the ValueLabel will be a concatenation of all the bit mask values that matches separated by a customizable string: multiSelectionSeparatorString.
 
 
 #LAYOUT
 
 - default view padding is 10 10 10 10, flexibleSize is NO so that it fits the height of the content
 - default marginRight on *PropertyNameLabel*: 10
 - *ValueLabel* is flexible in width
 - If presented in a tableView, the accessoryType of the contentViewCell (UITableViewCell) will be set to UITableViewCellAccessoryDisclosureIndicator
 - default appearance for PropertyNameLabel is bold system font of size 17, black color, numberOfLines 1
 - default appearance for ValueLabel is system font of size 14, black color, numberOfLines 1, text alignment right
 - default appearance of ValueImageView is fixed size "40 40", margin left 10, contentMode is UIViewContentModeScaleAspectFit
 
 
 <pre>
 **************************************************************
 |                                                            |
 | [PropertyNameLabel] [       ValueLabel  ] [ValueImageView] |
 |                                                            |
 **************************************************************
 
 or is no image found:
 
 **************************************************************
 |                                                            |
 | [PropertyNameLabel] [                      ValueLabel  ] > |
 |                                                            |
 **************************************************************
 
 </pre>
 
 
 #CUSTOMIZING THE APPEARANCE
 
 *Stylesheets*
 
 In the stylesheet of the view controller embedding the CKPropertySelectionViewController, you can customize the appearance of this view controller as follow:
 
 <pre>
 {
     //Target your controller by type and the property path that you set when initializing your property
 
     "CKPropertySelectionViewController[property.keypath=propertyPath]" : {
 
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
         },
 
         "UIImageView[name=ValueImageView]" : {
            //customize any appearance or layout properties of UIImageView
         }
     }
 }
 </pre>
 
 */
@interface CKPropertySelectionViewController : CKPropertyViewController

/**
 */
- (id)initWithProperty:(CKProperty*)property enumDescriptor:(CKEnumDescriptor*)enumDescriptor readOnly:(BOOL)readOnly;

/**
 */
- (id)initWithProperty:(CKProperty*)property valuesAndLabels:(NSDictionary*)valuesAndLabels readOnly:(BOOL)readOnly;

/**
 */
- (id)initWithProperty:(CKProperty*)property valuesAndLabels:(NSDictionary*)valuesAndLabels multiSelectionEnabled:(BOOL)multiSelectionEnabled readOnly:(BOOL)readOnly;

/** multiSelectionSeparatorString is used when concatenating the string representation of values that matches the property value in case the property is declared as a bit mask. Default value is '\n'.
 */
@property(nonatomic,retain) NSString* multiSelectionSeparatorString;

/** Derfault value is YES. This allows to hide the disclosure indicator when an image representing the current value of the property is displayed.
 */
@property(nonatomic,assign) BOOL hideDisclosureIndicatorWhenImageIsAvailable;

///-----------------------------------
/// @name Customizing the enum edition view controller
///-----------------------------------

/** An accessor on the properties extended attribute enum definition that is YES if the enum descriptor is a bit mask.
 */
@property(nonatomic,readonly) BOOL multiSelectionEnabled;

/** Defines if we should present a table view controller or a picker view controller for editing the value.
 */
@property(nonatomic,assign) CKPropertyEditionAppearanceStyle editionControllerAppearance;

/** Defines how we should present the edition controller.
 */
@property(nonatomic,assign) CKPropertyEditionPresentationStyle editionControllerPresentationStyle;

/** Enum value edition is presented as a form of table view controller.
 Each individual cell in the table view controller can be customized by setting selectionControllerFactory with an item for object of class CKPropertySelectionValue.
 */
@property(nonatomic,retain) CKReusableViewControllerFactory* editionControllerFactory;

/** Set this block to sort the enum values in the table view controller and when computing the multi selection value label as you expect.
 */
@property(nonatomic,copy) NSComparisonResult(^sortBlock)(CKPropertySelectionValue* obj1, CKPropertySelectionValue* obj2);

@end



