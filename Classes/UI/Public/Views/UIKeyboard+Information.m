//
//  UIKeyboard+Information.m
//  AppCoreKit
//
//  Created by Olivier Collet.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "UIKeyboard+Information.h"

CGRect CKUIKeyboardInformationFrameEnd(NSDictionary *keyboardUserInfo) {
	NSValue *keyBounds = [keyboardUserInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
	CGRect keyboardRect;
	[keyBounds getValue:&keyboardRect];
	return keyboardRect;
}

CGRect CKUIKeyboardInformationBounds(NSDictionary *keyboardUserInfo) {
	NSValue *keyBounds = [keyboardUserInfo objectForKey:UIKeyboardBoundsUserInfoKey];
	CGRect keyboardRect;
	[keyBounds getValue:&keyboardRect];
	return keyboardRect;
}

CGPoint CKUIKeyboardInformationCenterEnd(NSDictionary *keyboardUserInfo) {
	NSValue *keyCenter = [keyboardUserInfo objectForKey:UIKeyboardCenterEndUserInfoKey];
	CGPoint endPoint;
	[keyCenter getValue:&endPoint];
	return endPoint;
}

CGFloat CKUIKeyboardInformationAnimationDuration(NSDictionary *keyboardUserInfo) {
	NSValue *keyAnimDuration = [keyboardUserInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
	CGFloat duration;
	[keyAnimDuration getValue:&duration];
	return duration;
}

UIViewAnimationCurve CKUIKeyboardInformationAnimationCurve(NSDictionary *keyboardUserInfo) {
	NSValue *keyAnimCurve = [keyboardUserInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
	UIViewAnimationCurve curve;
	[keyAnimCurve getValue:&curve];
	return curve;
}
