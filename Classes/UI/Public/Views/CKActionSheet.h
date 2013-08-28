//
//  CKActionSheet.h
//  AppCoreKit
//
//  Created by Olivier Collet.
//  Copyright 2011 WhereCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^CKActionSheetActionBlock)();

/** Simplified interface for the UIActionSheet.
 */
@interface CKActionSheet : NSObject <UIActionSheetDelegate> {
}

///-----------------------------------
/// @name Setting Properties
///-----------------------------------

/** 
 The action sheet's presentation style.
 */
@property(nonatomic) UIActionSheetStyle actionSheetStyle;

/** 
 Setting this value to `YES` will cancel the action sheet when the app enters in background. Default value is `NO`.
 This parameter has no effect if no cancel button has been added to the action sheet.
 */
@property(nonatomic) BOOL cancelOnEnterBackground;

///-----------------------------------
/// @name Creating the CKActionSheet
///-----------------------------------

/** 
 Initalizes the CKActionSheet with the specified starting parameters.
 @param title A string to display in the title area of the action sheet. Pass `nil` if you do not want to display any text in the title area.
 @return A newly initialized CKActionSheet.
 */
- (id)initWithTitle:(NSString *)title;

///-----------------------------------
/// @name Adding Buttons
///-----------------------------------

/** 
 Adds a button.
 @param title The title of the new button.
 @param actionBlock The block to be executed when the button it pressed. Pass `nil` if you do not want any action to be executed.
 @see addCancelButtonWithTitle:action:
 @see addDestructiveButtonWithTitle:action:
 */
- (void)addButtonWithTitle:(NSString *)title action:(void (^)(void))actionBlock;

/** 
 Adds a button with the Cancel style.
 @warning This method can be called only once per instance of CKActionSheet. Calling this method more times will generate an assertion.
 @param title The title of the new button.
 @param actionBlock The block to be executed when the button it pressed. Pass `nil` if you do not want any action to be executed.
 @see addButtonWithTitle:action:
 @see addDestructiveButtonWithTitle:action:
 */
- (void)addCancelButtonWithTitle:(NSString *)title action:(void (^)(void))actionBlock;

/** 
 Adds a button with the Destructive style.
 @warning This method can be called only once per instance of CKActionSheet. Calling this method more times will generate an assertion.
 @param title The title of the new button.
 @param actionBlock The block to be executed when the button it pressed. Pass `nil` if you do not want any action to be executed.
 @see addButtonWithTitle:action:
 @see addCancelButtonWithTitle:action:
 */
- (void)addDestructiveButtonWithTitle:(NSString *)title action:(void (^)(void))actionBlock;

///-----------------------------------
/// @name Presenting the Action Sheet
///-----------------------------------

/** 
 Displays an action sheet that originates from the specified tab bar.
 @param tabBar The tab bar from which the action sheet originates.
 @see showFromToolbar:
 @see showInView:
 */
- (void)showFromTabBar:(UITabBar *)tabBar;

/** 
 Displays an action sheet that originates from the specified toolbar.
 @param toolbar The toolbar from which the action sheet originates.
 @see showFromTabBar:
 @see showInView:
 */
- (void)showFromToolbar:(UIToolbar *)toolbar;

/** 
 Displays an action sheet that originates from the specified view.
 @param view The view from which the action sheet originates.
 @see showFromTabBar:
 @see showFromToolbar:
 */
- (void)showInView:(UIView *)view;

/** 
 Displays an action sheet that originates from the specified bar button item.
 @param item The bar button item from which the action sheet originates.
 @param animated Specify `YES` to animate the presentation of the action sheet or `NO` to present it immediately without any animation effects.
 @see showFromRect:inView:animated:
 */
- (void)showFromBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated;

/** 
 Displays an action sheet that originates from the specified view.
 @param rect The portion of view from which to originate the action sheet.
 @param view The view from which to originate the action sheet.
 @param animated Specify `YES` to animate the presentation of the action sheet or `NO` to present it immediately without any animation effects.
 @see showFromBarButtonItem:animated:
 */
- (void)showFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated;

@end
