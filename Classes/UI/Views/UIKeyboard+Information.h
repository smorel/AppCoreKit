//
//  UIKeyboard+Information.h
//  AppCoreKit
//
//  Created by Olivier Collet.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


#ifdef __cplusplus
extern "C" {
#endif
    
    
/**
 */
CGRect CKUIKeyboardInformationFrameEnd(NSDictionary *keyboardUserInfo);

/**
 */
CGRect CKUIKeyboardInformationBounds(NSDictionary *keyboardUserInfo);

/**
 */
CGPoint CKUIKeyboardInformationCenterEnd(NSDictionary *keyboardUserInfo);

/**
 */
CGFloat CKUIKeyboardInformationAnimationDuration(NSDictionary *keyboardUserInfo);

/**
 */
UIViewAnimationCurve CKUIKeyboardInformationAnimationCurve(NSDictionary *keyboardUserInfo);

#ifdef __cplusplus
}
#endif