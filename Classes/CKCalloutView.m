//
//  CKCalloutView.m
//  YellowPages
//
//  Created by Olivier Collet on 10-06-16.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKCalloutView.h"
#import "CKConstants.h"

#define ARROW_DISTANCE 10


@interface CKOverlayView ()
- (void)setup;
@end

//

@interface CKCalloutView ()

- (CGPoint)centerFromRect:(CGRect)rect arrowDirection:(CKCalloutArrowDirection)direction;
- (CGPoint)arrowDeltaFromRect:(CGRect)rect inRect:(CGRect)parentRect;

@end

//

@implementation CKCalloutView

@synthesize arrowDirection = _arrowDirection;

- (void)setup {
	[super setup];
	self.arrowDirection = CKCalloutArrowDirectionUp;
}

- (void)dealloc {
    [super dealloc];
}

//

- (void)presentFromRect:(CGRect)rect inView:(UIView *)parentView animated:(BOOL)animated {
	self.center = [self centerFromRect:rect arrowDirection:self.arrowDirection];

	_arrowDeltaX = [self arrowDeltaFromRect:rect inRect:parentView.bounds].x;
	_arrowDeltaY = [self arrowDeltaFromRect:rect inRect:parentView.bounds].y;

	self.frame = CGRectIntegral(self.frame);
	
	[super presentInView:parentView animated:animated];
}


//

- (CGRect)boxFrame {
	CGRect rect = self.bounds;
	
	if (self.arrowDirection == CKCalloutArrowDirectionUp)	
		rect = CGRectMake(self.bounds.origin.x + (self.shadowSize) - self.shadowOffsetX, 
						  self.bounds.origin.y + ARROW_DISTANCE + (self.shadowSize) - self.shadowOffsetY, 
						  self.bounds.size.width - (self.shadowSize * 2),
						  self.bounds.size.height - (self.shadowSize * 2) - self.shadowOffsetY - ARROW_DISTANCE);
	if (self.arrowDirection == CKCalloutArrowDirectionDown)	
		rect = CGRectMake(self.bounds.origin.x + (self.shadowSize - self.shadowOffsetX), 
						  self.bounds.origin.y + (self.shadowSize - self.shadowOffsetY), 
						  self.bounds.size.width - (self.shadowSize * 2),
						  self.bounds.size.height - (self.shadowSize * 2) - self.shadowOffsetY - ARROW_DISTANCE);
	if (self.arrowDirection == CKCalloutArrowDirectionLeft)	
		rect = CGRectMake(self.bounds.origin.x + ARROW_DISTANCE + (self.shadowSize - self.shadowOffsetX), 
						  self.bounds.origin.y + (self.shadowSize - self.shadowOffsetY), 
						  self.bounds.size.width - ARROW_DISTANCE - (self.shadowSize * 2),
						  self.bounds.size.height - (self.shadowSize * 2) - self.shadowOffsetY);
	if (self.arrowDirection == CKCalloutArrowDirectionRight)	
		rect = CGRectMake(self.bounds.origin.x + (self.shadowSize - self.shadowOffsetX), 
						  self.bounds.origin.y + (self.shadowSize - self.shadowOffsetY), 
						  self.bounds.size.width - ARROW_DISTANCE - (self.shadowSize * 2),
						  self.bounds.size.height - (self.shadowSize * 2) - self.shadowOffsetY);
	return rect;
}

- (void)buildPath:(CGMutablePathRef)path {
	CGRect frame = [self boxFrame];
	CGFloat x = frame.origin.x;
	CGFloat y = frame.origin.y;
	CGFloat w = frame.size.width;
	CGFloat h = frame.size.height;

	CGFloat arrowOffsetX = CGRectGetMidX(frame) + _arrowDeltaX;
	if ((arrowOffsetX + ARROW_DISTANCE) > (w - self.cornerRadius)) arrowOffsetX = w - self.cornerRadius - ARROW_DISTANCE;
	if ((arrowOffsetX - ARROW_DISTANCE) < (x + self.cornerRadius)) arrowOffsetX = x + self.cornerRadius + ARROW_DISTANCE;
	
	CGFloat arrowOffsetY = CGRectGetMidY(frame) + _arrowDeltaY;
	if ((arrowOffsetY + ARROW_DISTANCE) > (h - self.cornerRadius)) arrowOffsetY = h - self.cornerRadius - ARROW_DISTANCE;
	if ((arrowOffsetY - ARROW_DISTANCE) < (y + self.cornerRadius)) arrowOffsetY = y + self.cornerRadius + ARROW_DISTANCE;
	
	// Create a rounded path
	CGPathMoveToPoint(path, NULL, w/2 + x, y);
	
	if (self.arrowDirection == CKCalloutArrowDirectionUp) {
		CGPathAddLineToPoint(path, NULL, arrowOffsetX + ARROW_DISTANCE, y);
		CGPathAddLineToPoint(path, NULL, arrowOffsetX, y - ARROW_DISTANCE);
		CGPathAddLineToPoint(path, NULL, arrowOffsetX - ARROW_DISTANCE, y);			
	}
	
	CGPathAddArcToPoint(path, NULL, w + x, y, w + x, h/2 + y, self.cornerRadius);
	
	if (self.arrowDirection == CKCalloutArrowDirectionRight) {
		CGPathAddLineToPoint(path, NULL, x + w, arrowOffsetY - ARROW_DISTANCE);
		CGPathAddLineToPoint(path, NULL,  x + w + ARROW_DISTANCE, arrowOffsetY);
		CGPathAddLineToPoint(path, NULL, x + w, arrowOffsetY + ARROW_DISTANCE);
	}
	
	CGPathAddArcToPoint(path, NULL, w + x, h + y, w/2 + x, h + y, self.cornerRadius);

	if (self.arrowDirection == CKCalloutArrowDirectionDown) {
		CGPathAddLineToPoint(path, NULL, arrowOffsetX + ARROW_DISTANCE, h + y);
		CGPathAddLineToPoint(path, NULL, arrowOffsetX, h + y + ARROW_DISTANCE);
		CGPathAddLineToPoint(path, NULL, arrowOffsetX - ARROW_DISTANCE, h + y);			
	}

	CGPathAddArcToPoint(path, NULL, x, h + y, x, h/2 + y, self.cornerRadius);
	
	if (self.arrowDirection == CKCalloutArrowDirectionLeft) {
		CGPathAddLineToPoint(path, NULL, x, arrowOffsetY - ARROW_DISTANCE);
		CGPathAddLineToPoint(path, NULL, x - ARROW_DISTANCE, arrowOffsetY);
		CGPathAddLineToPoint(path, NULL, x, arrowOffsetY + ARROW_DISTANCE);
	}
	
	CGPathAddArcToPoint(path, NULL, x, y, w/2 + x, y, self.cornerRadius);
	CGPathCloseSubpath(path);
}

//

- (CGPoint)centerFromRect:(CGRect)rect arrowDirection:(CKCalloutArrowDirection)direction {

	CGFloat x = CGRectGetMidX(rect);
	CGFloat y = CGRectGetMidY(rect);

	switch (direction) {
		case CKCalloutArrowDirectionUp:
			y = CGRectGetMaxY(rect) + CGRectGetMidY(self.bounds) - self.shadowSize;
			break;
		case CKCalloutArrowDirectionDown:
			y = CGRectGetMinY(rect) - CGRectGetMidY(self.bounds) + self.shadowSize;
			break;
		case CKCalloutArrowDirectionLeft:
			x = CGRectGetMaxX(rect) + CGRectGetMidX(self.bounds) - self.shadowSize;
			break;
		case CKCalloutArrowDirectionRight:
			x = CGRectGetMinX(rect) - CGRectGetMidX(self.bounds) + self.shadowSize;
			break;
		default:
			break;
	}
	return CGPointMake(x, y);	
}

- (CGPoint)arrowDeltaFromRect:(CGRect)rect inRect:(CGRect)parentRect {
	// TODO: Take CKOVERLAYVIEW_SHADOW_OFFSET_X in consideration
	if (CGRectGetMinX(self.frame) < CGRectGetMinX(parentRect)) 
		self.frame = CGRectOffset(self.frame, CGRectGetMinX(parentRect) - CGRectGetMinX(self.frame) + 10 - self.shadowSize, 0);
	if (CGRectGetMaxX(self.frame) > CGRectGetMaxX(parentRect)) 
		self.frame = CGRectOffset(self.frame, CGRectGetMaxX(parentRect) - CGRectGetMaxX(self.frame) - 10 + self.shadowSize, 0);
	
	if (CGRectGetMinY(self.frame) < CGRectGetMinY(parentRect)) 
		self.frame = CGRectOffset(self.frame, 0, CGRectGetMinY(parentRect) - CGRectGetMinY(self.frame) + 10 - self.shadowSize);
	if (CGRectGetMaxY(self.frame) > CGRectGetMaxY(parentRect)) 
		self.frame = CGRectOffset(self.frame, 0, CGRectGetMaxY(parentRect) - CGRectGetMaxY(self.frame) - 10 + self.shadowSize);
	
	CGFloat arrowDeltaX = [self centerFromRect:rect arrowDirection:self.arrowDirection].x - self.center.x;
	CGFloat arrowDeltaY = [self centerFromRect:rect arrowDirection:self.arrowDirection].y - self.center.y;

	return CGPointMake(arrowDeltaX, arrowDeltaY);
}

//

- (CGSize)sizeThatFits:(CGSize)size {
	CGSize newSize = [super sizeThatFits:size];
	
	switch (self.arrowDirection) {
		case CKCalloutArrowDirectionUp:
		case CKCalloutArrowDirectionDown:
			newSize.height += ARROW_DISTANCE;
			break;
		case CKCalloutArrowDirectionLeft:
		case CKCalloutArrowDirectionRight:
			newSize.width += ARROW_DISTANCE;
			break;
		default:
			break;
	}
	
	return newSize;
}


@end
