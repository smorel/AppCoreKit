//
//  CKRoundedCornerView.m
//  AppCoreKit
//
//  Created by Olivier Collet.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKRoundedCornerView.h"
#import "UIColor+Additions.h"
#import <QuartzCore/QuartzCore.h>

@implementation CKRoundedCornerView {
	CKRoundedCornerViewType _corners;
	CGFloat _roundedCornerSize;
}

@synthesize corners = _corners;
@synthesize roundedCornerSize = _roundedCornerSize;


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.corners = CKRoundedCornerViewTypeNone;
		self.roundedCornerSize = 10;
    }
    return self;
}

- (void)setCorners:(CKRoundedCornerViewType)newCorners {
	_corners = newCorners;
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
	/*
	UIRectCorner roundedCorners = UIRectCornerAllCorners;
	switch (self.corners) {
		case CKRoundedCornerViewTypeTop:
			roundedCorners = (UIRectCornerTopLeft | UIRectCornerTopRight);
			break;
		case CKRoundedCornerViewTypeBottom:
			roundedCorners = (UIRectCornerBottomLeft | UIRectCornerBottomRight);
			break;
			
		default:
			break;
	}
	
	if (self.corners != CKRoundedCornerViewTypeNone) {
		[[UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:roundedCorners cornerRadii:CGSizeMake(self.roundedCornerSize,self.roundedCornerSize)] addClip];
	}
     */
}

- (void)dealloc {
    [super dealloc];
}


@end
