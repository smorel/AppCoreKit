//
//  CKKeypadView.m
//  CloudKit
//
//  Created by Olivier Collet on 10-05-26.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKKeypadView.h"
#import "CKUIView+Layout.h"


@interface CKKeypadView ()
- (void)constructView;
@end


@implementation CKKeypadView

@synthesize value = _value;
@synthesize delegate = _delegate;


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		self.value = [[NSString alloc] init];
		[self constructView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		self.value = [[NSString alloc] init];
		[self constructView];
	}
	return self;
}

- (void)dealloc {
	self.value = nil;
    [super dealloc];
}


- (void)addButtonForKey:(CKKeypadViewKey)key {
	UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	button.frame = CGRectMake(0, 0, 10, 10);
	if (key < 1000) [button setTitle:[NSString stringWithFormat:@"%d",key] forState:UIControlStateNormal];
	[button addTarget:self action:@selector(keyPressed:) forControlEvents:UIControlEventTouchUpInside];
	button.tag = key;
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
			if (self.value.length > 0) self.value = [[self.value substringToIndex:self.value.length-1] retain];
			break;
		default:
			self.value = [NSString stringWithFormat:@"%@%d", self.value, button.tag];
			break;
	}

	if ([(NSObject *)self.delegate respondsToSelector:@selector(keypadView:didPressKey:)])
		[self.delegate keypadView:self didPressKey:button.tag];
}


@end
