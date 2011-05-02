//
//  CKUIGradientView.m
//  GroupedTableStyled
//
//  Created by Olivier Collet on 11-04-07.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKGradientView.h"
#import "CKUIColorAdditions.h"
#import <QuartzCore/QuartzCore.h>


@implementation CKGradientView

@synthesize gradientColors = _gradientColors;
@synthesize gradientColorLocations = _gradientColorLocations;
@synthesize image = _image;

- (void)postInit {
}

- (id)init {
	self = [super init];
	if (self) {
		[self postInit];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self postInit];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self postInit];
	}
	return self;
}

- (void)dealloc {
	[_gradientColors release]; _gradientColors = nil;
	[_gradientColorLocations release]; _gradientColorLocations = nil;
	[_image release]; _image = nil;
	[super dealloc];
}

//

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	CGContextRef gc = UIGraphicsGetCurrentContext();
	
	if(self.backgroundColor != nil){
		CGContextSetFillColorWithColor(gc, self.backgroundColor.CGColor);
		CGContextSetAlpha(gc,CGColorGetAlpha([self.backgroundColor CGColor]));
		CGContextFillRect(gc,self.bounds);
	}
	else{
		CGContextSetFillColorWithColor(gc, [UIColor clearColor].CGColor);
		CGContextSetAlpha(gc,0.0);
		CGContextFillRect(gc, self.bounds);
	}
	
	if(_image){
		[_image drawInRect:self.bounds];
	}	
						  
	if(self.gradientColors){
		CGFloat colorLocations[self.gradientColorLocations.count];
		int i = 0;
		for (NSNumber *n in self.gradientColorLocations) {
			colorLocations[i++] = [n floatValue];
		}
		
		NSMutableArray *colors = [NSMutableArray array];
		for (UIColor *color in self.gradientColors) {
			[colors addObject:(id)([[color RGBColor]CGColor])];
		}
		
		CGGradientRef gradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), (CFArrayRef)colors, colorLocations);
		CGContextDrawLinearGradient(gc, gradient, CGPointMake(0.0f, 0.0f), CGPointMake(0, self.bounds.size.height), 0);
	}
}

@end
