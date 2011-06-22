//
//  CKTextViewCellController.h
//  CloudKit
//
//  Created by Olivier Collet on 10-11-26.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKStandardCellController.h"

@interface CKTextViewCellController : CKStandardCellController <UITextFieldDelegate, UITextViewDelegate> {
	id _delegate;
	NSString *_placeholder;
	CGFloat _maxStretchableHeight;
	UIFont *_font;
	UIColor *_placeholderTextColor;
	BOOL _allowCarriageReturn;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) NSString *placeholder;
@property (nonatomic, assign) CGFloat maxStretchableHeight;
@property (nonatomic, retain) UIFont *font;
@property (nonatomic, retain) UIColor *placeholderTextColor;
@property (nonatomic, assign, getter=allowsCarriageReturn) BOOL allowCarriageReturn;

- (id)initWithText:(NSString *)text placeholder:(NSString *)placeholder;

@end

//

@protocol CKTextViewCellControllerDelegate

@optional
- (void)textViewCellControllerDidBeginEditing:(CKTextViewCellController *)controller;
- (void)textViewCellControllerDidEndEditing:(CKTextViewCellController *)controller;

@end