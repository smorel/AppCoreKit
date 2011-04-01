//
//  CKTextViewCellController.m
//  CloudKit
//
//  Created by Olivier Collet on 10-11-26.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKTextViewCellController.h"
#import "CKTextView.h"
#import <CloudKit/CKConstants.h>

#define kTextViewTag 10001

@implementation CKTextViewCellController

@synthesize delegate = _delegate;
@synthesize placeholder = _placeholder;
@synthesize maxStretchableHeight = _maxStretchableHeight;
@synthesize font = _font;
@synthesize placeholderTextColor = _placeholderTextColor;
@synthesize allowCarriageReturn = _allowCarriageReturn;

- (id)initWithText:(NSString *)text placeholder:(NSString *)placeholder {
    self = [super init];
	if (self) {
		self.value = text;
		self.placeholder = placeholder;
		self.maxStretchableHeight = CGFLOAT_MAX;
		self.selectable = NO;
		self.font = [UIFont systemFontOfSize:17];
		self.allowCarriageReturn = YES;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateHeight) name:UIDeviceOrientationDidChangeNotification object:nil];
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	self.placeholder = nil;
    self.font = nil;
    self.placeholderTextColor = nil;
	[super dealloc];
}

//

- (void)updateHeight {
	if (self.tableViewCell == nil) return;
	UIView *view = [self.tableViewCell viewWithTag:kTextViewTag];
	if ([view isKindOfClass:[CKTextView class]]) {
		// FIXME: layoutSubviews isn't always called on CKTextView
		// when orientation changes
		[(CKTextView *)view updateHeight];
		// ---
		self.rowHeight = view.frame.size.height + 5;
		[self.parentController.tableView beginUpdates];
		[self.parentController.tableView endUpdates];		
	}
}

//

- (UITableViewCell *)loadCell {
	UITableViewCell *cell = [self cellWithStyle:UITableViewCellStyleDefault];
	cell.accessoryView = nil;
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.clipsToBounds = NO;
	cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	UITableView *tableView = self.parentController.tableView;
	CGFloat width = tableView.bounds.size.width - ((tableView.style == UITableViewStylePlain) ? 0 : 20);
	CGFloat offset = self.text ? (width/2.55) : 0;
	CGRect frame = CGRectMake(((tableView.style == UITableViewStylePlain) ? 0 : 10), 2, width - offset, self.rowHeight-5);
	CKTextView *textView = [[[CKTextView alloc] initWithFrame:frame] autorelease];
	textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	textView.backgroundColor = [UIColor clearColor];
	textView.tag = kTextViewTag;
	[cell.contentView addSubview:textView];

	return cell;
}

- (void)setupCell:(UITableViewCell *)cell {
	[super setupCell:cell];
	
	CKTextView *textView = (CKTextView *)[cell viewWithTag:kTextViewTag];
	textView.delegate = self;
	textView.maxStretchableHeight = self.maxStretchableHeight;
	textView.font = self.font;
	textView.returnKeyType = [self allowsCarriageReturn] ? UIReturnKeyDefault : UIReturnKeyDone;
	textView.placeholder = self.placeholder;
	textView.text = self.value;
	if (self.textColor) textView.textColor = self.textColor;
	if (self.placeholderTextColor) textView.placeholderLabel.textColor = self.placeholderTextColor;
}

#pragma mark TextView Delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
	return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
	textView.scrollEnabled = YES;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
	[textView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
	if ([self.delegate respondsToSelector:@selector(textViewCellControllerDidBeginEditing:)]) {
		[self.delegate textViewCellControllerDidBeginEditing:self];
	}
}

- (void)textViewDidEndEditing:(UITextView *)textView {
	textView.scrollEnabled = NO;
	self.value = textView.text;
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
	[textView removeObserver:self forKeyPath:@"frame"];
	if ([self.delegate respondsToSelector:@selector(textViewCellControllerDidEndEditing:)]) {
		[self.delegate textViewCellControllerDidEndEditing:self];
	}
}

// Removes the \n chars if newlineEnabled = NO (ex: when pasting new text)
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	if ([self allowsCarriageReturn]) return YES;

	if ([text isEqualToString:@"\n"]) {
		[textView endEditing:NO];
		return NO;
	}
	if ([text rangeOfString:@"\n"].location == NSNotFound) return YES;

	NSString *filteredText = [text stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
	textView.text = [textView.text stringByReplacingCharactersInRange:range withString:filteredText];
	return NO;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([object isKindOfClass:[CKTextView class]] && [keyPath isEqualToString:@"frame"]) {
		CKTextView *textView = (CKTextView *)object;
		self.rowHeight = textView.frame.size.height + 5;
		[self.parentController.tableView beginUpdates];
		[self.parentController.tableView endUpdates];		
	}
}

#pragma mark Keyboard

- (void)keyboardDidShow:(NSNotification *)notification {
	[self.parentController.tableView scrollToRowAtIndexPath:self.indexPath 
										   atScrollPosition:UITableViewScrollPositionNone 
												   animated:YES];
}

@end
