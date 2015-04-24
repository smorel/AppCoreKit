//
//  CKStyleView.m
//  AppCoreKit
//
//  Created by Olivier Collet.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKStyleView.h"
#import "CKStyleView+Drawing.h"

#import "UIImage+Transformations.h"
#import "NSArray+Additions.h"
#import "CKPropertyExtendedAttributes+Attributes.h"

#import <QuartzCore/QuartzCore.h>

@interface CKStyleView ()
@property(nonatomic,retain)UIColor* fillColor;
@property(nonatomic,assign)CGRect drawFrame;
@property(nonatomic,assign)CGRect originalFrame;
@end



@implementation CKStyleView

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
    [_image release]; _image = nil;
    [_gradientColors release]; _gradientColors = nil;
    [_gradientColorLocations release]; _gradientColorLocations = nil;
    [_borderColor release]; _borderColor = nil;
    [_separatorColor release]; _separatorColor = nil;
    [_fillColor release]; _fillColor = nil;
    [_embossTopColor release]; _embossTopColor = nil;
    [_embossBottomColor release]; _embossBottomColor = nil;
    [_borderShadowColor release]; _borderShadowColor = nil;
    [super dealloc];
}


- (void)postInit {
	self.borderColor = [UIColor clearColor];
	self.borderWidth = 1;
	self.borderLocation = CKStyleViewBorderLocationNone;
    
	self.separatorColor = [UIColor clearColor];
	self.separatorWidth = 1;
	self.separatorLocation = CKStyleViewSeparatorLocationNone;
    
	self.fillColor = [UIColor clearColor];
	self.imageContentMode = UIViewContentModeScaleToFill;
    
    self.corners = CKStyleViewCornerTypeNone;
    self.roundedCornerSize = 10;
    
    self.clipsToBounds = 0;
    self.userInteractionEnabled = NO;
    
    _borderShadowRadius = 2;
    _borderShadowOffset = CGSizeMake(0,0);
    
    self.gradientStyle = CKStyleViewGradientStyleVertical;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.drawFrame = CGRectMake(0,0,0,0);
    self.separatorInsets = UIEdgeInsetsMake(0,0,0,0);
    
    self.separatorDashPhase = 0;
    self.separatorDashLengths = nil;
    self.separatorLineCap = kCGLineCapButt;
    self.separatorLineJoin = kCGLineJoinMiter;
}

- (void)imageContentModeExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"UIViewContentMode",
                                                    UIViewContentModeScaleToFill,
                                                    UIViewContentModeScaleAspectFit,      
                                                    UIViewContentModeScaleAspectFill,    
                                                    UIViewContentModeRedraw,              
                                                    UIViewContentModeCenter,             
                                                    UIViewContentModeTop,
                                                    UIViewContentModeBottom,
                                                    UIViewContentModeLeft,
                                                    UIViewContentModeRight,
                                                    UIViewContentModeTopLeft,
                                                    UIViewContentModeTopRight,
                                                    UIViewContentModeBottomLeft,
                                                    UIViewContentModeBottomRight);
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

- (void)gradientStyleExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKBitMaskDefinition(@"CKStyleViewGradientStyle",
                                                    CKStyleViewGradientStyleVertical,
                                                    CKStyleViewGradientStyleHorizontal);
}

- (void)separatorDashLengthsExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.contentType = [NSNumber class];
}

- (void)separatorLineCapExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"CGLineCap",
                                                 kCGLineCapButt,
                                                 kCGLineCapRound,
                                                 kCGLineCapSquare);
}

- (void)separatorLineJoinExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"CGLineJoin",
                                                 kCGLineJoinMiter,
                                                 kCGLineJoinRound,
                                                 kCGLineJoinBevel);
}


//HACK to control how to paint using the background color !
- (void)setBackgroundColor:(UIColor *)color{
    //self.gradientColors = nil;
    
	self.fillColor = color;
    CGFloat alpha = CGColorGetAlpha([color CGColor]);
    if(self.corners == CKStyleViewCornerTypeNone && alpha >= 1){
        [super setBackgroundColor:[UIColor clearColor]];
    }
    else{
        [super setBackgroundColor:[UIColor clearColor]];
    }
    [self updateDisplay];
}

- (UIColor*)backgroundColor{
    return (self.gradientColors == nil) ? self.fillColor : [UIColor clearColor];
}

- (void)setImage:(UIImage *)anImage {
    if (anImage != _image) {
        [_image release];
        _image = [anImage retain];
        
        self.opaque = YES;
        //self.backgroundColor = [UIColor blackColor];
        [self updateDisplay];
    }
}

- (void)setCorners:(CKStyleViewCornerType)newCorners{
    if(_corners != newCorners){
        _corners = newCorners;
        
        CGFloat alpha = CGColorGetAlpha([_fillColor CGColor]);
        if(newCorners == CKStyleViewCornerTypeNone && alpha >= 1){
            //TODO : if no shadow set opaque color
            //[super setBackgroundColor:[UIColor blackColor]];
            self.opaque = YES;
        }
        else{
            [super setBackgroundColor:[UIColor clearColor]];
            self.opaque = NO;
        }
        [self updateDisplay];
    }
}

- (void)setBorderLocation:(NSInteger)theborderLocation{
    if(_borderLocation != theborderLocation){
        _borderLocation = theborderLocation;
        [self updateDisplay];
    }
}

- (void)setSeparatorLocation:(NSInteger)theseparatorLocation{
    if(_separatorLocation != theseparatorLocation){
        _separatorLocation = theseparatorLocation;
        [self updateDisplay];
    }
}

- (void)setSeparatorInsets:(UIEdgeInsets)theSeparatorInsets{
    if(!UIEdgeInsetsEqualToEdgeInsets(_separatorInsets, theSeparatorInsets)){
        _separatorInsets = theSeparatorInsets;
        [self updateDisplay];
    }
}

- (void)setBorderWidth:(CGFloat)width {
    if(width != _borderWidth){
        _borderWidth = width;
        [self updateDisplay];
    }
}

- (void)updateDisplay{
    self.frame = self.originalFrame;
    [self setNeedsDisplay];
}

- (void)setFrame:(CGRect)frame{
    //TODO : generate stretchable shadow image and add a uiimageview subview that is inseted in layoutsubviews instead of hacking the frame here to draw "out of bounds" ..
    //This shadow image should be accessible from the outside as we'll grab it while taking snapshots and transitioning between view controllers.
    
    if(CGRectEqualToRect(self.originalFrame,CGRectZero) && CGRectEqualToRect(frame, self.drawFrame))
        return;
    
    self.originalFrame = frame;
    
    CGSize oldSize = self.frame.size;
    if(_borderShadowColor!= nil && _borderShadowColor != [UIColor clearColor] && _borderShadowRadius > 0){
        //Shadow
        
        UIRectCorner roundedCorners = UIRectCornerAllCorners;
        switch (self.corners) {
            case CKStyleViewCornerTypeTop:
                roundedCorners = (UIRectCornerTopLeft | UIRectCornerTopRight);
                break;
            case CKStyleViewCornerTypeBottom:
                roundedCorners = (UIRectCornerBottomLeft | UIRectCornerBottomRight);
                break;
                
            default:
                break;
        }
        
        CGFloat multiplier = 2;
        CGRect shadowFrame = frame;
        CGPoint offset = CGPointMake(0,0);
        
        if(_borderLocation & CKStyleViewBorderLocationLeft){
            offset.x += multiplier * self.borderShadowRadius;
            shadowFrame.size.width += multiplier * self.borderShadowRadius;
            
        }
        if(_borderLocation & CKStyleViewBorderLocationRight){
            shadowFrame.size.width += multiplier * self.borderShadowRadius;
        }
        if(_borderLocation & CKStyleViewBorderLocationTop){
            offset.y += multiplier * self.borderShadowRadius;
            shadowFrame.size.height += multiplier * self.borderShadowRadius;
        }
        if(_borderLocation & CKStyleViewBorderLocationBottom){
            shadowFrame.size.height += multiplier * self.borderShadowRadius;
        }
        
        if(self.borderLocation & CKStyleViewBorderLocationBottom && self.borderShadowOffset.height > 0){
            shadowFrame.size.height += self.borderShadowOffset.height;
        }
        
        if(self.borderLocation & CKStyleViewBorderLocationTop && self.borderShadowOffset.height < 0){
            offset.y -= self.borderShadowOffset.height;
            shadowFrame.size.height += -self.borderShadowOffset.height;
        }
        
        if(self.borderLocation & CKStyleViewBorderLocationRight && self.borderShadowOffset.width > 0){
            shadowFrame.size.width += self.borderShadowOffset.width;
        }
        
        if(self.borderLocation & CKStyleViewBorderLocationLeft && self.borderShadowOffset.width < 0){
            offset.x -= self.borderShadowOffset.width;
            shadowFrame.size.width += -self.borderShadowOffset.width;
        }
        
        shadowFrame.origin.x -= offset.x;
        shadowFrame.origin.y -= offset.y;
        
        [super setFrame:shadowFrame];
        
        if( !CGSizeEqualToSize(shadowFrame.size, oldSize) ){
            self.drawFrame = CGRectMake(offset.x,offset.y,frame.size.width,frame.size.height);
            [self setNeedsDisplay];
        }
    }else{
        //Draw normally
        [super setFrame:frame];
        
        if( !CGSizeEqualToSize(frame.size, oldSize) ){
            self.drawFrame = CGRectMake(0,0,frame.size.width,frame.size.height);
            [self setNeedsDisplay];
        }
    }
}


@end
