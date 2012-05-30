//
//  CKKeypadView.m
//  CloudKit
//
//  Created by Olivier Collet on 10-05-26.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKKeypadView.h"
#import "CKUIView+Layout.h"
#import "CKBundle.h"


@interface CKKeypadView ()
- (void)constructView;
@end


@implementation CKKeypadView

@synthesize value = _value;
@synthesize delegate = _delegate;


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		self.value = @"";
		[self constructView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		self.value = @"";
		[self constructView];
	}
	return self;
}

- (void)dealloc {
	self.value = nil;
    [super dealloc];
}


- (void)addButtonForKey:(CKKeypadViewKey)key {
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = CGRectMake(0, 0, 10, 10);
	button.tag = key;
	if (key < 1000) [button setTitle:[NSString stringWithFormat:@"%d",key] forState:UIControlStateNormal];
	[button addTarget:self action:@selector(keyPressed:) forControlEvents:UIControlEventTouchUpInside];

	// Theming
	[button setBackgroundImage:[CKBundle imageForName:@"CKKeypadViewButtonBackground.png"] forState:UIControlStateNormal];
	[button setBackgroundImage:[CKBundle imageForName:@"CKKeypadViewButtonBackground.png"] forState:UIControlStateDisabled];
	[button setBackgroundImage:[CKBundle imageForName:@"CKKeypadViewButtonBackground-Highlighted.png"] forState:UIControlStateHighlighted];
	[button setBackgroundImage:[CKBundle imageForName:@"CKKeypadViewButtonBackground-Selected.png"] forState:UIControlStateSelected];
	[button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
	[button setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[button setTitleShadowColor:[UIColor clearColor] forState:UIControlStateHighlighted];
	[button setTitleShadowColor:[UIColor clearColor] forState:UIControlStateSelected];
	button.titleLabel.shadowOffset = CGSizeMake(0, 1);
	button.titleLabel.font = [UIFont boldSystemFontOfSize:40];
	
	if (key == CKKeypadViewKeyBackspace) {
		[button setImage:[CKBundle imageForName:@"CKKeypadViewBackspaceButton.png"] forState:UIControlStateNormal];
		[button setImage:[CKBundle imageForName:@"CKKeypadViewBackspaceButton-Highlighted.png"] forState:UIControlStateHighlighted];
		[button setImage:[CKBundle imageForName:@"CKKeypadViewBackspaceButton-Selected.png"] forState:UIControlStateSelected];
	}
	if (key == CKKeypadViewKeyNone) button.enabled = NO;

	[self addSubview:button];
}

- (void)constructView {
	// 1 - 9
	for (int i=1 ; i<10 ; i++) {
		[self addButtonForKey:i];
	}

	// Empty
	[self addButtonForKey:CKKeypadViewKeyNone];

	// 0
	[self addButtonForKey:CKKeypadViewKeyZero];

	// Backspace
	[self addButtonForKey:CKKeypadViewKeyBackspace];
}


- (void)layoutSubviews {
	[super layoutSubviews];
	[self layoutSubviewsWithColumns:3 lines:4];	
}

- (void)keyPressed:(id)sender {
	UIButton *button = (UIButton *)sender;

	switch (button.tag) {
		case CKKeypadViewKeyBackspace:
			if (self.value.length > 0) self.value = [self.value substringToIndex:self.value.length-1];
			break;
		default:
			if ([(NSObject *)self.delegate respondsToSelector:@selector(keypadView:shouldSelectKey:)] &&
				[self.delegate keypadView:self shouldSelectKey:button.tag] == NO)
				return;
			self.value = [NSString stringWithFormat:@"%@%d", self.value, button.tag];
			break;
	}

	if ([(NSObject *)self.delegate respondsToSelector:@selector(keypadView:didSelectKey:)])
		[self.delegate keypadView:self didSelectKey:button.tag];
}


@end
