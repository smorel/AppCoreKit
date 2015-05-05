//
//  CKPropertyViewController.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-04.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKReusableViewController.h"
#import "CKProperty.h"
#import "NSObject+Bindings.h"
#import "Layout.h"
#import "UIView+Name.h"


/**
 *
 * Controls how the view controller is displayed
 * CKPropertyEditionPresentationStylePush : pushes into a new view controller
 * CKPropertyEditionPresentationStylePopover :
 * CKPropertyEditionPresentationStyleModal : presents into a modal view
 * CKPropertyEditionPresentationStyleSheet :
 * CKPropertyEditionPresentationStyleInline : pushes into a new view controller
 *
 */
typedef NS_ENUM(NSInteger, CKPropertyEditionPresentationStyle){
    CKPropertyEditionPresentationStyleDefault,
    CKPropertyEditionPresentationStylePush,
    CKPropertyEditionPresentationStylePopover,
    CKPropertyEditionPresentationStyleModal,
    CKPropertyEditionPresentationStyleSheet,
    CKPropertyEditionPresentationStyleInline
};


//TODO: adds support for property validation UI compatible with any CKCollectionViewControllerOld

/** CKPropertyViewController provides the base mechanism for implementing a view controller that synchronize, edit and display any kind of properties.
 It doesn't display anything by itself and requiers to get subclassed to implement logic related to certain type of properties.
 
 @see: CKPropertyStringViewController
 
 
 TODO: Explain how to customize the navigationToolbar in stylesheets
 
 */
@interface CKPropertyViewController : CKReusableViewController

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


/** Default value is a localized string as follow: _(@"propertyName") that can be customized by setting a key/value in your localization file as follow:
 "propertyName" = "My Title";
 Or simply set the propertyNameLabel property programatically or in your stylesheet in the CKPropertyStringViewController scope.
 */
@property(nonatomic,retain) NSString* propertyNameLabel;

///-----------------------------------
/// @name Customizing the appearance
///-----------------------------------

/**
 Specify whether the cell should be editable or readonly. default value is NO if the property itself is not readonly.
 Setting it to NO when the property is readonly in the class definition will have no effect and will be reset to YES.
 Setting this property to YES while the view is displayed will resign responder if the property was currently edited.
 */
@property(nonatomic,assign)BOOL readOnly;

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
- (void)presentEditionViewController:(UIViewController*)controller
                   presentationStyle:(CKPropertyEditionPresentationStyle)presentationStyle
  shouldDismissOnPropertyValueChange:(BOOL)shouldDismissOnPropertyValueChange;


///-----------------------------------
/// @name Setuping the controller
///-----------------------------------

/** Override this method to setup your subviews.
 The binding context is automatically manged for you and this method will be called when the view will appear, if the property or readonly gets changed while the controller is displayed.
 */
- (void)setupBindings;

@end
