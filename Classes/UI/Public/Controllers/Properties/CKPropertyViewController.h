//
//  CKPropertyViewController.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-04.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKResusableViewController.h"
#import "CKProperty.h"
#import "NSObject+Bindings.h"
#import "Layout.h"
#import "UIView+Name.h"


/**
 */
typedef NS_ENUM(NSInteger, CKPropertyEditionPresentationStyle){
    CKPropertyEditionPresentationStyleDefault,
    CKPropertyEditionPresentationStylePush,
    CKPropertyEditionPresentationStylePopover,
    CKPropertyEditionPresentationStyleModal,
    CKPropertyEditionPresentationStyleSheet,
    CKPropertyEditionPresentationStyleInline
};


//TODO: adds support for property validation UI compatible with any CKCollectionViewController

/** CKPropertyViewController provides the base mechanism for implementing a view controller that synchronize, edit and display any kind of properties.
 It doesn't display anything by itself and requiers to get subclassed to implement logic related to certain type of properties.
 
 @see: CKPropertyStringViewController
 
 
 TODO: Explain how to customize the navigationToolbar in stylesheets
 
 */
@interface CKPropertyViewController : CKResusableViewController

///-----------------------------------
/// @name Creating initialized Property View Controller Objects
///-----------------------------------

/**
*/
+ (instancetype)controllerWithProperty:(CKProperty*)property;

/**
 */
+ (instancetype)controllerWithProperty:(CKProperty*)property readOnly:(BOOL)readOnly;

/**
 */
- (id)initWithProperty:(CKProperty*)property;

/**
 */
- (id)initWithProperty:(CKProperty*)property readOnly:(BOOL)readOnly;


///-----------------------------------
/// @name Accessing Property
///-----------------------------------

/**
 This method returns the property currently used in the controller.
 @return the object property.
 */
@property(nonatomic,retain)CKProperty* property;

///-----------------------------------
/// @name Customizing the appearance
///-----------------------------------

/**
 Specify whether the cell should be editable or readonly. default value is NO if the property itself is not readonly.
 Setting it to NO when the property is readonly in the class definition will have no effect and will be reset to YES.
 Setting this property to YES while the view is displayed will resign responder if the property was currently edited.
 */
@property(nonatomic,assign)BOOL readOnly;

/** This method will be called whenever the readonly property changes while the controller's view is displayed.
 You should overload this method in your subclass if you need to modify the layout or do any additional processing to handle the new readOnly state.
 */
- (void)readOnlyDidChange;

///-----------------------------------
/// @name Customizing the Toolbar for editing
///-----------------------------------

/** By enabling this flag, a toolbar will be added on top of the keyboard when editing the property. 
 This adds an automanaged next/done button as well as a label with a localized string with the following format: _(@"propertyName_editionTitle").
 You can change this label by adding a key with the specified value in your localisation file or by setting the propertyEditionTitleLabel property
 Default value is NO.
 */
@property(nonatomic,assign)BOOL editionToolbarEnabled;

/** If editionToolbarEnabled is set to YES and you don't set the editionToolbar, a default one will be created.
 @see editionToolbarEnabled.
 */
@property(nonatomic,retain)UIToolbar* editionToolbar;

/** Default value is a localized string as follow: _(@"propertyName_editionTitle") that can be customized by setting a key/value in your localization file as follow:
 "propertyName_editionTitle" = "My Title";
 Or simply set the propertyEditionTitleLabel property programatically or in your stylesheet in the CKPropertyViewController scope.
 */
@property(nonatomic,retain) NSString* propertyEditionTitleLabel;

///-----------------------------------
/// @name Presenting an edition view controller
///-----------------------------------

/**
 */
- (void)presentEditionViewController:(CKViewController*)controller
                   presentationStyle:(CKPropertyEditionPresentationStyle)presentationStyle
  shouldDismissOnPropertyValueChange:(BOOL)shouldDismissOnPropertyValueChange;

@end
