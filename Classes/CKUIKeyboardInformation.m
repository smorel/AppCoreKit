//
//  CKUIKeyboardInformation.m
//  CloudKit
//
//  Created by Olivier Collet on 10-09-17.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKUIKeyboardInformation.h"


CGRect CKUIKeyboardInformationBounds(NSDictionary *keyboardUserInfo) {
	NSValue *keyBounds = [keyboardUserInfo objectForKey:UIKeyboardBoundsUserInfoKey];
	CGRect keyboardRect;
	[keyBounds getValue:&keyboardRect];
	return keyboardRect;
}

CGFloat CKUIKeyboardInformationAnimationDuration(NSDictionary *keyboardUserInfo) {
	NSValue *keyAnimDuration = [keyboardUserInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
	double duration;
	[keyAnimDuration getValue:&duration];
	return duration;
}

UIViewAnimationCurve CKUIKeyboardInformationAnimationCurve(NSDictionary *keyboardUserInfo) {
	NSValue *keyAnimCurve = [keyboardUserInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
	UIViewAnimationCurve curve;
	[keyAnimCurve getValue:&curve];
	return curve;
}
