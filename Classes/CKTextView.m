//
//  CKTextView.m
//  CloudKit
//
//  Created by Olivier Collet on 10-11-24.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKTextView.h"

@interface CKTextView ()

@property (nonatomic, readwrite, retain) IBOutlet UILabel *placeholderLabel;

@end

//

@implementation CKTextView

@synthesize placeholderLabel = _placeholderLabel;
@synthesize maxStretchableHeight = _maxStretchableHeight;

- (void)postInit {
	self.placeholderLabel = [[[UILabel alloc] initWithFrame:CGRectMake(8, 8, self.bounds.size.width-16, self.font.lineHeight)] autorelease];
	self.placeholderLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	self.placeholderLabel.font = self.font;
	self.placeholderLabel.backgroundColor = [UIColor clearColor];
	self.placeholderLabel.textColor = [UIColor lightGrayColor];
	[self addSubview:self.placeholderLabel];

	self.maxStretchableHeight = 0;

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(valueDidChange) name:UITextViewTextDidChangeNotification object:self];
	[self addObserver:self forKeyPath:@"font" options:NSKeyValueObservingOptionNew context:nil];
}

- (id)init {
	if (self = [super init]) {
		[self postInit];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		[self postInit];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		[self postInit];
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self removeObserver:self forKeyPath:@"font"];
	self.placeholderLabel = nil;
	[super dealloc];
}

//

- (void)updateHeight {
	if (self.maxStretchableHeight > 0) {
		[UIView beginAnimations:nil context:nil];
		CGRect newFrame = self.frame;
		newFrame.size.height = MIN(self.maxStretchableHeight, self.contentSize.height);
		self.frame = newFrame;
		[UIView commitAnimations];
		self.scrollEnabled = (self.contentSize.height > self.maxStretchableHeight);
	}	
}

- (void)layoutSubviews {
	[super layoutSubviews];
	[self updateHeight];
}

- (void)setText:(NSString *)text {
	[super setText:text];
	self.placeholderLabel.hidden = [self hasText];
}

//

- (UIEdgeInsets)contentInset { return UIEdgeInsetsZero; }
-(void)setContentInset:(UIEdgeInsets)s {
	UIEdgeInsets insets = s;
	
	if(s.bottom>8) insets.bottom = 0;
	insets.top = 0;
	
	[super setContentInset:insets];
}
- (void)setContentSize:(CGSize)size {
	if (size.height == 50) {
		size.height = self.font.lineHeight + 16;
	}
	[super setContentSize:size];
}

- (NSString *)placeholder {
	return self.placeholderLabel.text;
}

- (void)setPlaceholder:(NSString *)placeholder {
	self.placeholderLabel.text = placeholder;
}

//

- (void)valueDidChange {
	self.placeholderLabel.hidden = [self hasText];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"font"]) {
		self.placeholderLabel.font = self.font;
		self.placeholderLabel.frame = CGRectMake(8, 8, self.placeholderLabel.bounds.size.width, self.font.lineHeight);
	}
}

@end
