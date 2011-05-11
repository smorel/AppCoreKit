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
#import "CKUIImage+Transformations.h"

#import "CKNSObject+Bindings.h"

@implementation CKGradientViewUpdater
@synthesize view = _view;

- (void)frameChanged:(id)value{
	[self.view setNeedsDisplay];
}

- (id)initWithView:(UIView*)theView{
	if(self = [super init]){
		self.view = theView;
		[NSObject beginBindingsContext:[NSValue valueWithNonretainedObject:self]];
		[theView bind:@"frame" target:self action:@selector(frameChanged:)];
		[NSObject endBindingsContext];
	}
	return self;
}

- (void)dealloc{
	[NSObject removeAllBindingsForContext:[NSValue valueWithNonretainedObject:self]];
	[super dealloc];
}

@end

@interface CKGradientView () 
@property(nonatomic,retain)CKGradientViewUpdater* updater;
@end



@implementation CKGradientView

@synthesize gradientColors = _gradientColors;
@synthesize gradientColorLocations = _gradientColorLocations;
@synthesize image = _image;
@synthesize borderColor = _borderColor;
@synthesize borderWidth = _borderWidth;
@synthesize updater = _updater;

- (void)postInit {
	self.borderColor = [UIColor clearColor];
	self.borderWidth = 1;
	self.updater = [[[CKGradientViewUpdater alloc]initWithView:self]autorelease];
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
	[_updater release]; _updater = nil;
	[_image release]; _image = nil;
	[_gradientColors release]; _gradientColors = nil;
	[_gradientColorLocations release]; _gradientColorLocations = nil;
	[_borderColor release]; _borderColor = nil;
	[super dealloc];
}

//

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	CGContextRef gc = UIGraphicsGetCurrentContext();
	
	if(self.gradientColors == nil){
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
	
	if(_borderColor!= nil && _borderColor != [UIColor clearColor]){
		
		[_borderColor setStroke];
		
		if((self.roundedCornerSize.width == 0 && self.roundedCornerSize.height == 0)
		   || self.corners == CKRoundedCornerViewTypeNone){
			CGContextSetLineWidth(gc, _borderWidth);
			CGContextAddRect(gc, self.bounds);
			CGContextStrokePath(gc);
		}
		else{
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
			
			UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:roundedCorners cornerRadii:self.roundedCornerSize];
			/*
			enum CGLineJoin {
				kCGLineJoinMiter,
				kCGLineJoinRound,
				kCGLineJoinBevel
			};
			typedef enum CGLineJoin CGLineJoin;
			
			enum CGLineCap {
				kCGLineCapButt,
				kCGLineCapRound,
				kCGLineCapSquare
			};
			typedef enum CGLineCap CGLineCap;

			 
			 @property(nonatomic) CGLineCap lineCapStyle;
			 @property(nonatomic) CGLineJoin lineJoinStyle;
			*/
			path.lineJoinStyle = kCGLineJoinBevel;
			[path setLineWidth:_borderWidth];
			[path stroke];
		}
	}
}

@end
