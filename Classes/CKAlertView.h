//
//  CKAlertView.h
//  AppCoreKit
//
//  Created by Fred Brunel.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^CKAlertViewActionBlock)();

/** Simplified interface for the UIAlertView.
 */
@interface CKAlertView : NSObject <UIAlertViewDelegate> {
}
@property (nonatomic, retain, readonly) UIAlertView *alertView;
@property (nonatomic, copy) CKAlertViewActionBlock deallocBlock;

///-----------------------------------
/// @name Creating the CKAlertView
///-----------------------------------

/** 
 Returns an autoreleased CKAlertView with the specified starting parameters.
 @param title A string to display in the title area of the alert. Pass `nil` if you do not want to display any text in the title area.
 @param message A string to display in the message area of the alert. Pass `nil` if you do not want to display any text in the message area.
 @return A newly initialized CKAlertView.
 */
+ (id)alertViewWithTitle:(NSString *)title message:(NSString *)message;

/** 
 Initalizes the CKAlertView with the specified starting parameters.
 @param title A string to display in the title area of the alert. Pass `nil` if you do not want to display any text in the title area.
 @param message A string to display in the message area of the alert. Pass `nil` if you do not want to display any text in the message area.
 @return A newly initialized CKAlertView.
 */
- (id)initWithTitle:(NSString *)title message:(NSString *)message;

///-----------------------------------
/// @name Adding Buttons
///-----------------------------------

/** 
 Adds a button.
 @param title The title of the new button.
 @param actionBlock The block to be executed when the button it pressed. Pass `nil` if you do not want any action to be executed.
 */
- (void)addButtonWithTitle:(NSString *)title action:(void (^)(void))actionBlock;

///-----------------------------------
/// @name Presenting the Alert
///-----------------------------------

/** 
 Displays an alert view.
 */
- (void)show;

@end
