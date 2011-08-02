//
//  CKSheetController.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-01.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString *const CKSheetResignNotification;
extern NSString *const CKSheetWillShowNotification;
extern NSString *const CKSheetWillHideNotification;
extern NSString *const CKSheetFrameEndUserInfoKey;
extern NSString *const CKSheetAnimationDurationUserInfoKey;
extern NSString *const CKSheetAnimationCurveUserInfoKey;
extern NSString *const CKSheetKeyboardWillShowInfoKey;

@interface CKSheetController : NSObject{
    id _delegate;
    UIViewController* _contentViewController;
}

@property(nonatomic,assign) id delegate;
@property(nonatomic,retain) UIViewController* contentViewController;

- (id)initWithContentViewController:(UIViewController *)viewController;
- (void)showFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated;
- (void)dismissSheetAnimated:(BOOL)animated;

@end

@protocol CKSheetControllerDelegate
@optional
- (void)sheetControllerWillShowSheet:(CKSheetController*)sheetController;
- (void)sheetControllerDidShowSheet:(CKSheetController*)sheetController;
- (void)sheetControllerWillDismissSheet:(CKSheetController*)sheetController;
- (void)sheetControllerDidDismissSheet:(CKSheetController*)sheetController;

@end
