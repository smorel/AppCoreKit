//
//  CKSheetController.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


#ifdef __cplusplus
extern "C" {
#endif
    
extern NSString *const CKSheetResignNotification;
extern NSString *const CKSheetWillShowNotification;
extern NSString *const CKSheetDidShowNotification;
extern NSString *const CKSheetWillHideNotification;
extern NSString *const CKSheetDidHideNotification;
extern NSString *const CKSheetFrameEndUserInfoKey;
extern NSString *const CKSheetAnimationDurationUserInfoKey;
extern NSString *const CKSheetAnimationCurveUserInfoKey;
extern NSString *const CKSheetKeyboardWillShowInfoKey;
    
#ifdef __cplusplus
}
#endif

/**
 */
@interface CKSheetController : NSObject

///-----------------------------------
/// @name Initializing a CKSheetController Object
///-----------------------------------

/** 
 */
- (id)initWithContentViewController:(UIViewController *)viewController;

///-----------------------------------
/// @name Managing the delegate
///-----------------------------------

/** 
 */
@property(nonatomic,assign) id delegate;

///-----------------------------------
/// @name Getting the sheetView and contentViewController
///-----------------------------------

/** 
 */
@property(nonatomic,retain) UIViewController* contentViewController;

/** 
 */
@property(nonatomic,retain, readonly) UIView* sheetView;

///-----------------------------------
/// @name Getting the sheetView status
///-----------------------------------

/** 
 */
@property(nonatomic,assign, readonly) BOOL visible;

///-----------------------------------
/// @name Presenting a sheetViewController
///-----------------------------------

/** 
 */
- (void)showFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated;

///-----------------------------------
/// @name Dismissing a sheetViewController
///-----------------------------------

/** 
 */
- (void)dismissSheetAnimated:(BOOL)animated;

@end

@protocol CKSheetControllerDelegate
@optional
///-----------------------------------
/// @name Dismissing/Presenting a sheetViewController
///-----------------------------------

/** 
 */
- (void)sheetControllerWillShowSheet:(CKSheetController*)sheetController;

/** 
 */
- (void)sheetControllerDidShowSheet:(CKSheetController*)sheetController;

/** 
 */
- (void)sheetControllerWillDismissSheet:(CKSheetController*)sheetController;

/** 
 */
- (void)sheetControllerDidDismissSheet:(CKSheetController*)sheetController;

@end
