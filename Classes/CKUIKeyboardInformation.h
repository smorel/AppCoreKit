//
//  CKUIKeyboardInformation.h
//  CloudKit
//
//  Created by Olivier Collet on 10-09-17.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


/** TODO
 */
CGRect CKUIKeyboardInformationBounds(NSDictionary *keyboardUserInfo);

/** TODO
 */
CGPoint CKUIKeyboardInformationCenterEnd(NSDictionary *keyboardUserInfo);

/** TODO
 */
CGFloat CKUIKeyboardInformationAnimationDuration(NSDictionary *keyboardUserInfo);

/** TODO
 */
UIViewAnimationCurve CKUIKeyboardInformationAnimationCurve(NSDictionary *keyboardUserInfo);
