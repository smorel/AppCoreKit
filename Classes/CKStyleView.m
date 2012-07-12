//
//  CKStyleView.m
//  AppCoreKit
//
//  Created by Olivier Collet.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKStyleView.h"
#import "UIColor+Additions.h"
#import "UIImage+Transformations.h"
#import "NSObject+Bindings.h"
#import "NSArray+Additions.h"
#import "CKPropertyExtendedAttributes+Attributes.h"

#import <QuartzCore/QuartzCore.h>


@interface CKStyleViewUpdater : NSObject

@property(nonatomic,assign)UIView* view;
- (id)initWithView:(UIView*)view;
@end


@implementation CKStyleViewUpdater{
	UIView* _view;
	CGSize _size;
}

@synthesize view = _view;

- (void)frameChanged:(id)value{
	if(_size.width != self.view.bounds.size.width
	   || _size.height != self.view.bounds.size.height){
		_size = self.view.bounds.size;
		[self.view setNeedsDisplay];
	}
}

- (id)initWithView:(UIView*)theView{
	if(self = [super init]){
		self.view = theView;
		_size = self.view.bounds.size;
        [self beginBindingsContextByRemovingPreviousBindings];
		[theView bind:@"frame" target:self action:@selector(frameChanged:)];
		[self endBindingsContext];
	}
	return self;
}

- (void)dealloc{
    [self clearBindingsContext];
	[super dealloc];
}

@end

@interface CKStyleView () 
@property(nonatomic,retain)CKStyleViewUpdater* updater;
@property(nonatomic,retain)UIColor* fillColor;
@end



@implementation CKStyleView{
	NSArray *_gradientColors;
	NSArray *_gradientColorLocations;
	UIImage *_image;
	UIViewContentMode _imageContentMode;
    
	NSInteger _borderLocation;
	UIColor* _borderColor;
	CGFloat _borderWidth;
    
	NSInteger _separatorLocation;
	UIColor* _separatorColor;
	CGFloat _separatorWidth;
	
	CKStyleViewUpdater* _updater;
	
	UIColor* _fillColor;
	UIColor *_embossTopColor;
	UIColor *_embossBottomColor;
}

@synthesize gradientColors = _gradientColors;
@synthesize gradientColorLocations = _gradientColorLocations;
@synthesize image = _image;
@synthesize borderLocation = _borderLocation;
@synthesize borderColor = _borderColor;
@synthesize borderWidth = _borderWidth;
@synthesize separatorLocation = _separatorLocation;
@synthesize separatorColor = _separatorColor;
@synthesize separatorWidth = _separatorWidth;
@synthesize updater = _updater;
@synthesize fillColor = _fillColor;
@synthesize imageContentMode = _imageContentMode;
@synthesize embossTopColor = _embossTopColor;
@synthesize embossBottomColor = _embossBottomColor;

- (void)postInit {
	self.borderColor = [UIColor clearColor];
	self.borderWidth = 1;
	self.borderLocation = CKStyleViewBorderLocationNone;
    
	self.separatorColor = [UIColor clearColor];
	self.separatorWidth = 1;
	self.separatorLocation = CKStyleViewSeparatorLocationNone;
    
	self.updater = [[[CKStyleViewUpdater alloc]initWithView:self]autorelease];
	self.fillColor = [UIColor clearColor];
	self.imageContentMode = UIViewContentModeScaleToFill;
}

- (void)borderLocationExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKBitMaskDefinition(@"CKStyleViewBorderLocation",
                                                    CKStyleViewBorderLocationNone,
                                                    CKStyleViewBorderLocationTop,
                                                    CKStyleViewBorderLocationBottom,
                                                    CKStyleViewBorderLocationRight,
                                                    CKStyleViewBorderLocationLeft,
                                                    CKStyleViewBorderLocationAll);
}

- (void)separatorLocationExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKBitMaskDefinition(@"CKStyleViewSeparatorLocation",
                                                    CKStyleViewSeparatorLocationNone,
                                                    CKStyleViewSeparatorLocationTop,
                                                    CKStyleViewSeparatorLocationBottom,
                                                    CKStyleViewSeparatorLocationRight,
                                                    CKStyleViewSeparatorLocationLeft,
                                                    CKStyleViewSeparatorLocationAll);
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

//HACK to control how to paint using the background color !
- (void)setBackgroundColor:(UIColor *)color{
    //self.gradientColors = nil;
    
	self.fillColor = color;
    CGFloat alpha = CGColorGetAlpha([color CGColor]);
    if(self.corners == CKRoundedCornerViewTypeNone && alpha >= 1){
        [super setBackgroundColor:[UIColor blackColor]];
    }
    else{
        [super setBackgroundColor:[UIColor clearColor]];
    }
}

- (UIColor*)backgroundColor{
    return (self.gradientColors == nil) ? self.fillColor : [UIColor clearColor];
}

- (void)setImage:(UIImage *)anImage {
    if (anImage != _image) {
        [_image release];
        _image = [anImage retain];
        
        self.opaque = YES;
        self.backgroundColor = [UIColor blackColor];
    }
}

- (void)setCorners:(CKRoundedCornerViewType)corners{
    [super setCorners:corners];
    
    CGFloat alpha = CGColorGetAlpha([_fillColor CGColor]);
    if(corners == CKRoundedCornerViewTypeNone && alpha >= 1){
        [super setBackgroundColor:[UIColor blackColor]];
        self.opaque = YES;
    }
    else{
        [super setBackgroundColor:[UIColor clearColor]];
        self.opaque = NO;
    }
}

- (void)setBorderWidth:(CGFloat)width {
	//CGFloat scale = [[UIScreen mainScreen] respondsToSelector:@selector(scale)] ? [[UIScreen mainScreen] scale] : 1;
	//_borderWidth = 2 * width * scale;
    _borderWidth = width;
}

- (void)dealloc {
	[_updater release]; _updater = nil;
	[_image release]; _image = nil;
	[_gradientColors release]; _gradientColors = nil;
	[_gradientColorLocations release]; _gradientColorLocations = nil;
	[_borderColor release]; _borderColor = nil;
	[_separatorColor release]; _separatorColor = nil;
	[_fillColor release]; _fillColor = nil;
	[_embossTopColor release]; _embossTopColor = nil;
	[_embossBottomColor release]; _embossBottomColor = nil;
	[super dealloc];
}

#pragma mark - Emboss Paths

- (void)generateTopEmbossPath:(CGMutablePathRef)path {
	UIRectCorner roundedCorners = UIRectCornerAllCorners;
	switch (self.corners) {
		case CKRoundedCornerViewTypeTop:
			roundedCorners = (UIRectCornerTopLeft | UIRectCornerTopRight);
			break;
		case CKRoundedCornerViewTypeBottom:
			roundedCorners = (UIRectCornerBottomLeft | UIRectCornerBottomRight);
			break;
		case CKRoundedCornerViewTypeNone:
			roundedCorners = 0;
			break;
		default:
			break;
	}
    
    CGFloat offset = 0;
    
	if (self.borderLocation & CKStyleViewBorderLocationTop && self.borderColor && (self.borderColor != [UIColor clearColor])) {
        offset = self.borderWidth;
    }
    if (self.separatorLocation & CKStyleViewSeparatorLocationTop && self.separatorColor && (self.separatorColor != [UIColor clearColor])) {
        offset = MAX(offset,self.separatorWidth);
    }
	
	CGFloat x = self.bounds.origin.x + offset-1;
	CGFloat y = self.bounds.origin.y + offset - 1;
	CGFloat width = self.bounds.size.width - (2 * (offset - 1));
	CGFloat radius = self.roundedCornerSize - offset + 2;
	
    
    CGPoint startLinePoint = CGPointMake(x, y + ((roundedCorners & UIRectCornerTopLeft) ? radius : 0));
    CGPoint endLinePoint = CGPointMake((roundedCorners & UIRectCornerTopRight) ? (x + width - radius) : x + width, y);
    
    CGPathMoveToPoint (path, nil, startLinePoint.x,startLinePoint.y );
	if(roundedCorners & UIRectCornerTopLeft){
        CGPathAddArc(path, nil,x + radius,y + radius,radius, M_PI,  3 * (M_PI / 2.0),NO);
	}
	CGPathAddLineToPoint (path, nil, endLinePoint.x,endLinePoint.y );
	if(roundedCorners & UIRectCornerTopRight){
        CGPathAddArc(path, nil,endLinePoint.x,endLinePoint.y + radius,radius, 3 * (M_PI / 2.0), 0,NO);
	}
}

- (void)generateBottomEmbossPath:(CGMutablePathRef)path {
	UIRectCorner roundedCorners = UIRectCornerAllCorners;
	switch (self.corners) {
		case CKRoundedCornerViewTypeTop:
			roundedCorners = (UIRectCornerTopLeft | UIRectCornerTopRight);
			break;
		case CKRoundedCornerViewTypeBottom:
			roundedCorners = (UIRectCornerBottomLeft | UIRectCornerBottomRight);
			break;
		case CKRoundedCornerViewTypeNone:
			roundedCorners = 0;
			break;
		default:
			break;
	}
    
    CGFloat offset = 0;
    
	if (self.borderLocation & CKStyleViewBorderLocationBottom && self.borderColor && (self.borderColor != [UIColor clearColor])) {
        offset = self.borderWidth;
    }
    if (self.separatorLocation & CKStyleViewSeparatorLocationBottom && self.separatorColor && (self.separatorColor != [UIColor clearColor])) {
        offset = MAX(offset,self.separatorWidth);
    }
	
	CGFloat x = self.bounds.origin.x + self.borderWidth - 1;
	CGFloat y = self.bounds.size.height - (offset - 1);
	CGFloat width = self.bounds.size.width - (2 * (self.borderWidth - 1));
	CGFloat radius = self.roundedCornerSize - self.borderWidth + 2;
    
    
    CGPoint startLinePoint = CGPointMake(x, ((roundedCorners & UIRectCornerBottomLeft) ? y - radius : y));
    CGPoint endLinePoint = CGPointMake((roundedCorners & UIRectCornerBottomRight) ? (x + width - radius) : x + width, y);
	
    CGPathMoveToPoint (path, nil, startLinePoint.x,startLinePoint.y );
	if(roundedCorners & UIRectCornerBottomLeft){
        CGPathAddArc(path, nil,startLinePoint.x + radius,startLinePoint.y,radius, -M_PI,  M_PI / 2,YES);
	}
	CGPathAddLineToPoint (path, nil, endLinePoint.x,endLinePoint.y );
	if(roundedCorners & UIRectCornerBottomRight){
        CGPathAddArc(path, nil,endLinePoint.x,endLinePoint.y - radius,radius, M_PI / 2.0, 0,YES);
	}
}

#pragma mark - Border Path

- (void)generateBorderPath:(CGMutablePathRef)path withStyle:(CKStyleViewBorderLocation)borderStyle width:(CGFloat)borderWidth{
	UIRectCorner roundedCorners = UIRectCornerAllCorners;
	switch (self.corners) {
		case CKRoundedCornerViewTypeTop:
			roundedCorners = (UIRectCornerTopLeft | UIRectCornerTopRight);
			break;
		case CKRoundedCornerViewTypeBottom:
			roundedCorners = (UIRectCornerBottomLeft | UIRectCornerBottomRight);
			break;
		case CKRoundedCornerViewTypeNone:
			roundedCorners = 0;
			break;
		default:
			break;
	}
	
    CGFloat x = 0 + borderWidth / 2.0;
    CGFloat y = 0 + borderWidth / 2.0;
	CGFloat width = self.bounds.size.width - borderWidth;
	CGFloat height = self.bounds.size.height - borderWidth;
    
	CGFloat radius = self.roundedCornerSize - (borderWidth / 2.0);
	
	if(borderStyle & CKStyleViewBorderLocationLeft){
		//draw arc from bottom to left or move to bottom left
		if((roundedCorners & UIRectCornerBottomLeft) && (borderStyle & CKStyleViewBorderLocationBottom)){
			CGPathMoveToPoint (path, nil, x + radius, y + height);
            CGPathAddArc(path, nil,x + radius,y + height-radius,radius, M_PI / 2,  M_PI ,NO);
		}
		else{
			CGPathMoveToPoint (path, nil, x, (roundedCorners & UIRectCornerBottomLeft) ? (y + height - radius) : height + borderWidth);
		}
		
		//draw left line
		CGPathAddLineToPoint (path, nil, x, (roundedCorners & UIRectCornerTopLeft) ? y + radius : 0);
		
		//draw arc from left to top
		if((roundedCorners & UIRectCornerTopLeft) && (borderStyle & CKStyleViewBorderLocationTop)){
            CGPathAddArc(path, nil,x + radius,y + radius,radius, M_PI,  3 * (M_PI / 2.0),NO);
			//CGPathAddArcToPoint (path, nil, 0, 0, radius, 0, radius);
		}
	}
	
	//draw top
	if(borderStyle & CKStyleViewBorderLocationTop){
		CGPathMoveToPoint (path, nil, (roundedCorners & UIRectCornerTopLeft) ? x + radius : x, y);
		CGPathAddLineToPoint (path, nil, (roundedCorners & UIRectCornerTopRight) ? (x + width - radius) : width + borderWidth, y);
	}
	
	//draw right
	if(borderStyle & CKStyleViewBorderLocationRight){
		//draw arc from top to right or move to top right
		if((roundedCorners & UIRectCornerTopRight) && (borderStyle & CKStyleViewBorderLocationTop)){
			CGPathMoveToPoint (path, nil, x + width - radius, y);
            CGPathAddArc(path, nil,x + width- radius,y + radius,radius, 3 * (M_PI / 2.0),0  ,NO);
			//CGPathAddArcToPoint (path, nil, width, 0, width, radius, radius);
		}
		else{
			CGPathMoveToPoint (path, nil, x + width, (roundedCorners & UIRectCornerTopRight) ? y + radius : 0);
		}
		
		//draw right line
		CGPathAddLineToPoint (path, nil, x + width, (roundedCorners & UIRectCornerBottomRight) ? (y + height - radius) : height + borderWidth);
		
		//draw arc from right to bottom
		if((roundedCorners & UIRectCornerBottomRight) && (borderStyle & CKStyleViewBorderLocationBottom)){
            CGPathAddArc(path, nil,x + width - radius,y + height - radius,radius, 0,  M_PI / 2.0,NO);
			//CGPathAddArcToPoint (path, nil, width, height, width - radius, height, radius);
		}
	}
	
	//draw bottom
	if(borderStyle & CKStyleViewBorderLocationBottom){
		CGPathMoveToPoint (path, nil, (roundedCorners & UIRectCornerBottomRight) ? (x + width - radius) : x + width, y + height);
		CGPathAddLineToPoint (path, nil, (roundedCorners & UIRectCornerBottomLeft) ? x + radius : 0, y + height);
	}
}

- (void)drawRect:(CGRect)rect {
	CGContextRef gc = UIGraphicsGetCurrentContext();
	
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
	
	CGPathRef clippingPath = nil;
	if (self.corners != CKRoundedCornerViewTypeNone) {
		clippingPath = [[UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:roundedCorners cornerRadii:CGSizeMake(self.roundedCornerSize,self.roundedCornerSize)]CGPath];
	}
	
	if(self.gradientColors == nil && self.image == nil){
		if(self.fillColor != nil)
			[self.fillColor setFill];
		else
			[[UIColor clearColor] setFill];
        
        if(clippingPath != nil){
            CGContextAddPath(gc, clippingPath);
            CGContextFillPath(gc);
        }
        else{
            CGContextFillRect(gc, self.bounds);
        }
	}
	
	
	if(_image){
		if(clippingPath != nil){
			CGContextAddPath(gc, clippingPath);
			CGContextClip(gc);
		}
		
		//self.imageContentMode
		//[_image drawInRect:self.bounds];
		
		BOOL clip = NO;
		CGRect originalRect = rect;
		if (_image.size.width != rect.size.width || _image.size.height != rect.size.height) {
			if (_imageContentMode == UIViewContentModeLeft) {
				rect = CGRectMake(rect.origin.x,
								  rect.origin.y + floor(rect.size.height/2 - _image.size.height/2),
								  _image.size.width, _image.size.height);
				clip = YES;
			} else if (_imageContentMode == UIViewContentModeRight) {
				rect = CGRectMake(rect.origin.x + (rect.size.width - _image.size.width),
								  rect.origin.y + floor(rect.size.height/2 - _image.size.height/2),
								  _image.size.width, _image.size.height);
				clip = YES;
			} else if (_imageContentMode == UIViewContentModeTop) {
				rect = CGRectMake(rect.origin.x + floor(rect.size.width/2 - _image.size.width/2),
								  rect.origin.y,
								  _image.size.width, _image.size.height);
				clip = YES;
			} else if (_imageContentMode == UIViewContentModeBottom) {
				rect = CGRectMake(rect.origin.x + floor(rect.size.width/2 - _image.size.width/2),
								  rect.origin.y + floor(rect.size.height - _image.size.height),
								  _image.size.width, _image.size.height);
				clip = YES;
			} else if (_imageContentMode == UIViewContentModeCenter) {
				rect = CGRectMake(rect.origin.x + floor(rect.size.width/2 - _image.size.width/2),
								  rect.origin.y + floor(rect.size.height/2 - _image.size.height/2),
								  _image.size.width, _image.size.height);
			} else if (_imageContentMode == UIViewContentModeBottomLeft) {
				rect = CGRectMake(rect.origin.x,
								  rect.origin.y + floor(rect.size.height - _image.size.height),
								  _image.size.width, _image.size.height);
				clip = YES;
			} else if (_imageContentMode == UIViewContentModeBottomRight) {
				rect = CGRectMake(rect.origin.x + (rect.size.width - _image.size.width),
								  rect.origin.y + (rect.size.height - _image.size.height),
								  _image.size.width, _image.size.height);
				clip = YES;
			} else if (_imageContentMode == UIViewContentModeTopLeft) {
				rect = CGRectMake(rect.origin.x,
								  rect.origin.y,
								  _image.size.width, _image.size.height);
				clip = YES;
			} else if (_imageContentMode == UIViewContentModeTopRight) {
				rect = CGRectMake(rect.origin.x + (rect.size.width - _image.size.width),
								  rect.origin.y,
								  _image.size.width, _image.size.height);
				clip = YES;
			} else if (_imageContentMode == UIViewContentModeScaleAspectFill) {
				CGSize imageSize = _image.size;
				if (imageSize.height < imageSize.width) {
					imageSize.width = floor((imageSize.width/imageSize.height) * rect.size.height);
					imageSize.height = rect.size.height;
				} else {
					imageSize.height = floor((imageSize.height/imageSize.width) * rect.size.width);
					imageSize.width = rect.size.width;
				}
				rect = CGRectMake(rect.origin.x + floor(rect.size.width/2 - imageSize.width/2),
								  rect.origin.y + floor(rect.size.height/2 - imageSize.height/2),
								  imageSize.width, imageSize.height);
			} else if (_imageContentMode == UIViewContentModeScaleAspectFit) {
				CGSize imageSize = _image.size;
				if (imageSize.height < imageSize.width) {
					imageSize.height = floor((imageSize.height/imageSize.width) * rect.size.width);
					imageSize.width = rect.size.width;
				} else {
					imageSize.width = floor((imageSize.width/imageSize.height) * rect.size.height);
					imageSize.height = rect.size.height;
				}
				rect = CGRectMake(rect.origin.x + floor(rect.size.width/2 - imageSize.width/2),
								  rect.origin.y + floor(rect.size.height/2 - imageSize.height/2),
								  imageSize.width, imageSize.height);
			}
		}
		
		CGContextRef context = UIGraphicsGetCurrentContext();
		if (clip) {
			CGContextSaveGState(context);
			CGContextAddRect(context, originalRect);
			CGContextClip(context);
		}
		
		[_image drawInRect:rect];
		
		if (clip) {
			CGContextRestoreGState(context);
		}
	}	
	
	// Gradient
	if(self.gradientColors){
		CGContextSaveGState(gc);
		if(clippingPath != nil){
			CGContextAddPath(gc, clippingPath);
			CGContextClip(gc);
		}
		
		CGFloat colorLocations[self.gradientColorLocations.count];
		int i = 0;
		for (NSNumber *n in self.gradientColorLocations) {
			colorLocations[i++] = [n floatValue];
		}
		
		NSMutableArray *colors = [NSMutableArray array];
		for (UIColor *color in self.gradientColors) {
			[colors addObject:(id)([[color RGBColor]CGColor])];
		}

		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)colors, colorLocations);
		CFRelease(colorSpace);

		CGContextDrawLinearGradient(gc, gradient, CGPointMake(0.0f, 0.0f), CGPointMake(0, self.bounds.size.height), 0);
		CGGradientRelease(gradient);
		CGContextRestoreGState(gc);
	}
	
	// Top Emboss
	if (_embossTopColor && (_embossTopColor != [UIColor clearColor])) {
		CGContextSaveGState(gc);
        [[UIColor clearColor]setStroke];
		CGContextSetLineWidth(gc, 1);
		CGContextSetShadowWithColor(gc, CGSizeMake(0, 1), 0, _embossTopColor.CGColor);
		CGMutablePathRef topEmbossPath = CGPathCreateMutable();
		[self generateTopEmbossPath:topEmbossPath];
		CGContextAddPath(gc, topEmbossPath);
        
        UIColor* thecolor = [self.gradientColors count] > 0 ? [self.gradientColors objectAtIndex:0] : self.fillColor;
        thecolor = [thecolor colorWithAlphaComponent:1];
		[thecolor setStroke];
        
		CGContextStrokePath(gc);
		CFRelease(topEmbossPath);
		CGContextRestoreGState(gc);
	}
	
	// Bottom Emboss
	if (_embossBottomColor && (_embossBottomColor != [UIColor clearColor])) {
		CGContextSaveGState(gc);
		if(clippingPath != nil){
			CGContextAddPath(gc, clippingPath);
			CGContextClip(gc);
		}
		CGContextSetShadowWithColor(gc, CGSizeMake(0, -1), 0, _embossBottomColor.CGColor);
		CGMutablePathRef bottomEmbossPath = CGPathCreateMutable();
		[self generateBottomEmbossPath:bottomEmbossPath];
		CGContextAddPath(gc, bottomEmbossPath);
		CFRelease(bottomEmbossPath);
        
        UIColor*thecolor = [self.gradientColors count] > 0 ? [self.gradientColors last] : self.fillColor;
        thecolor = [thecolor colorWithAlphaComponent:1];
		[thecolor setStroke];
        
		CGContextStrokePath(gc);
		CGContextRestoreGState(gc);
	}
    
    
    // Separator
	if(_separatorColor!= nil && _separatorColor != [UIColor clearColor] && _separatorWidth > 0 && _separatorLocation != CKStyleViewSeparatorLocationNone){
        CGContextSaveGState(gc);
		[_separatorColor setStroke];
		CGContextSetLineWidth(gc, self.separatorWidth);
		CGMutablePathRef borderPath = CGPathCreateMutable();
		[self generateBorderPath:borderPath withStyle:(CKStyleViewBorderLocation)_separatorLocation  width:_separatorWidth];
		CGContextAddPath(gc, borderPath);
		CFRelease(borderPath);
		CGContextStrokePath(gc);
		CGContextRestoreGState(gc);
	}
	
	// Border
	if(_borderColor!= nil && _borderColor != [UIColor clearColor] && _borderWidth > 0 && _borderLocation != CKStyleViewBorderLocationNone){
		CGContextSaveGState(gc);
		[_borderColor setStroke];
		CGContextSetLineWidth(gc, self.borderWidth);
		CGMutablePathRef borderPath = CGPathCreateMutable();
		[self generateBorderPath:borderPath withStyle:_borderLocation width:_borderWidth];
		CGContextAddPath(gc, borderPath);
		CFRelease(borderPath);
		CGContextStrokePath(gc);
		CGContextRestoreGState(gc);
	}
}

@end
