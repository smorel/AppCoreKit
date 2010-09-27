//
//  CKUIKeyboardInformation.h
//  CloudKit
//
//  Created by Olivier Collet on 10-09-17.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


CGRect CKUIKeyboardInformationBounds(NSDictionary *keyboardUserInfo);
CGFloat CKUIKeyboardInformationAnimationDuration(NSDictionary *keyboardUserInfo);
UIViewAnimationCurve CKUIKeyboardInformationAnimationCurve(NSDictionary *keyboardUserInfo);
