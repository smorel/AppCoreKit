//
//  CKOverlayView.m
//  BubbleView
//
//  Created by Olivier Collet on 10-06-20.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKOverlayView.h"
#import "CKConstants.h"


#define CKOVERLAYVIEW_CORNER_RADIUS 5
#define CKOVERLAYVIEW_SHADOW_SIZE 4
#define CKOVERLAYVIEW_SHADOW_OFFSET_X 0
#define CKOVERLAYVIEW_SHADOW_OFFSET_Y 0


// FIXME: The view is not properly resized when initialized from a NIB and has a shadow.
// FIXME: Add a customView property to put views inside the contentView.

@interface CKOverlayView ()

@property (nonatomic, readwrite, retain) UILabel *textLabel;

@end

//

@implementation CKOverlayView

@synthesize contentView = _contentView;
@synthesize textLabel = _textLabel;
@synthesize cornerRadius = _cornerRadius;
@synthesize shadowSize = _shadowSize;
@synthesize shadowOffsetX = _shadowOffsetX;
@synthesize shadowOffsetY = _shadowOffsetY;
@synthesize disableUserInteraction = _disableUserInteraction;

- (void)setup {
	self.backgroundColor = [UIColor clearColor];
	self.cornerRadius = CKOVERLAYVIEW_CORNER_RADIUS;
	self.shadowSize = CKOVERLAYVIEW_SHADOW_SIZE;
	self.shadowOffsetX = CKOVERLAYVIEW_SHADOW_OFFSET_X;
	self.shadowOffsetY = CKOVERLAYVIEW_SHADOW_OFFSET_Y;

	// Initialize the contentView
	self.contentView = [[[UIView alloc] initWithFrame:self.bounds] autorelease];
	self.contentView.autoresizingMask = CKUIViewAutoresizingFlexibleAll;
	self.contentView.backgroundColor = [UIColor clearColor];
	[self addSubview:self.contentView];

	// Initialize the textLabel
	self.textLabel = [[[UILabel alloc] initWithFrame:self.contentView.bounds] autorelease];
	self.textLabel.center = self.contentView.center;
	self.textLabel.autoresizingMask = CKUIViewAutoresizingFlexibleAll;
	self.textLabel.numberOfLines = 0;
	self.textLabel.textAlignment = UITextAlignmentCenter;
	self.textLabel.font = [UIFont boldSystemFontOfSize:15];
	self.textLabel.backgroundColor = [UIColor clearColor];
	self.textLabel.textColor = [UIColor whiteColor];
	[self.contentView addSubview:self.textLabel];
}

- (void)awakeFromNib {
	[self setup];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		[self setup];
	}
    return self;
}

- (void)dealloc {
	self.contentView = nil;
	self.textLabel = nil;
    [super dealloc];
}

- (void)presentInView:(UIView *)parentView animated:(BOOL)animated {
	if ([self isDescendantOfView:parentView] == NO) [parentView addSubview:self];
	
	// TODO: Put in separate method
	if (animated) {
		self.alpha = 0;
		[UIView beginAnimations:nil context:nil];
		self.alpha = 1;
		[UIView commitAnimations];		
	}
	if (self.disableUserInteraction) parentView.userInteractionEnabled = NO;
}

- (void)presentInView:(UIView *)parentView animated:(BOOL)animated withDelay:(NSTimeInterval)delay {
	if ([self isDescendantOfView:parentView] == NO) [parentView addSubview:self];
	
	// TODO: Put in separate method
	if (animated) {
		self.alpha = 0;
		[UIView beginAnimations:nil context:nil];
		self.alpha = 1;
		[UIView commitAnimations];		
	}
	if (self.disableUserInteraction) parentView.userInteractionEnabled = NO;

	if (delay > 0) [self performSelector:@selector(dismiss) withObject:nil afterDelay:delay];
}

- (void)dismiss:(BOOL)animated {
	if (self.disableUserInteraction) self.superview.userInteractionEnabled = YES;

	if (animated == NO) {
		[self removeFromSuperview];
		return;
	}
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(removeFromSuperview)];
	self.alpha = 0;
	[UIView commitAnimations];
}

- (void)dismiss {
	[self dismiss:YES];
}

//

- (CGRect)boxFrame {
	return CGRectMake(self.bounds.origin.x + (self.shadowSize - self.shadowOffsetX), 
					  self.bounds.origin.y + (self.shadowSize - self.shadowOffsetY), 
					  self.bounds.size.width - (self.shadowSize * 2) - self.shadowOffsetX,
					  self.bounds.size.height - (self.shadowSize * 2) - self.shadowOffsetY);
}

- (CGPathRef)getPath {
	CGRect frame = self.bounds;
	CGFloat x = frame.origin.x;
	CGFloat y = frame.origin.y;
	CGFloat w = frame.size.width;
	CGFloat h = frame.size.height;

	// Create a rounded path
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathMoveToPoint(path, NULL, w/2 + x, y);
	CGPathAddArcToPoint(path, NULL, w + x, y, w + x, h/2 + y, self.cornerRadius);
	CGPathAddArcToPoint(path, NULL, w + x, h + y, w/2 + x, h + y, self.cornerRadius);
	CGPathAddArcToPoint(path, NULL, x, h + y, x, h/2 + y, self.cornerRadius);
	CGPathAddArcToPoint(path, NULL, x, y, w/2 + x, y, self.cornerRadius);
	CGPathCloseSubpath(path);
	return path;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	self.contentView.frame = CGRectInset([self boxFrame], self.cornerRadius, self.cornerRadius);
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	CGContextRef gc = UIGraphicsGetCurrentContext();

	CGPathRef path = [self getPath];
	
	CGContextAddPath(gc, path);
	CGContextSetRGBFillColor(gc, 0, 0, 0, 0.6);
	CGContextSetShadowWithColor(gc, CGSizeMake(self.shadowOffsetX, self.shadowOffsetY), self.shadowSize, [UIColor colorWithWhite:0 alpha:0.75].CGColor);
	CGContextFillPath(gc);
	
	CGPathRelease(path);
}

- (CGSize)sizeThatFits:(CGSize)size {
	CGSize newSize = size;
	if (self.textLabel.text) {
		CGSize labelSize = [self.textLabel sizeThatFits:size];
		newSize = CGSizeMake(labelSize.width + (self.cornerRadius * 2) + (self.shadowSize * 2) + self.shadowOffsetX, 
							 labelSize.height + (self.cornerRadius * 2) + (self.shadowSize * 2) + self.shadowOffsetY);
	}

	return newSize;
}


@end
