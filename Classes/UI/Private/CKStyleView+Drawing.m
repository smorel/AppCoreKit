//
//  CKStyleView+Drawing.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-24.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKStyleView+Drawing.h"
#import "CKStyleView+Paths.h"

#import "UIColor+Additions.h"

@interface CKStyleView ()
@property(nonatomic,retain)UIColor* fillColor;
@property(nonatomic,assign)CGRect drawFrame;
@property(nonatomic,assign)CGRect originalFrame;
@end


@implementation CKStyleView (Drawing)


- (void)drawRect:(CGRect)rect{
    CGContextRef gc = UIGraphicsGetCurrentContext();
    
    [self drawInRect:self.drawFrame inContext:gc];
}

- (void)drawInRect:(CGRect)rect inContext:(CGContextRef)gc {
    [self drawShadowInRect:rect inContext:gc];
    
    CGMutablePathRef clippingPath = [CKStyleView generateBorderPathWithBorderLocation:CKStyleViewBorderLocationAll borderWidth:0 cornerType:self.corners roundedCornerSize:self.roundedCornerSize rect:rect];
    
    [self drawBackgroundColorInRect:rect clippingPath:clippingPath context:gc];
    [self drawBackgroundImageInRect:rect clippingPath:clippingPath context:gc];
    [self drawBackgroundGradientInRect:rect clippingPath:clippingPath context:gc];
    [self drawTopEmbossInRect:rect context:gc];
    [self drawBottomEmbossInRect:rect context:gc];
    [self drawSeparatorInRect:rect context:gc];
    [self drawBorderInRect:rect context:gc];
    
    CFRelease(clippingPath);
}

- (void)drawShadowInRect:(CGRect)rect inContext:(CGContextRef)gc{
    // Shadow
    if(self.borderColor!= nil && self.borderColor != [UIColor clearColor] && self.borderWidth > 0 && self.borderLocation != CKStyleViewBorderLocationNone){
        CGContextSaveGState(gc);
        
        if(self.borderShadowColor!= nil && self.borderShadowColor != [UIColor clearColor] && self.borderShadowRadius > 0){
            CGContextSetShadowWithColor(gc, self.borderShadowOffset, self.borderShadowRadius, self.borderShadowColor.CGColor);
            
            CGRect shadowRect = rect;
            if(!(self.borderLocation & CKStyleViewBorderLocationTop)){
                shadowRect.origin.y -= self.borderShadowRadius;
                shadowRect.size.height += self.borderShadowRadius;
            }
            if(!(self.borderLocation & CKStyleViewBorderLocationBottom)){
                shadowRect.size.height += self.borderShadowRadius;
            }
            if(!(self.borderLocation & CKStyleViewBorderLocationLeft)){
                shadowRect.origin.x -= self.borderShadowRadius;
                shadowRect.size.width += self.borderShadowRadius;
            }
            if(!(self.borderLocation & CKStyleViewBorderLocationRight)){
                shadowRect.size.width += self.borderShadowRadius;
            }
            
            if(!(self.borderLocation & CKStyleViewBorderLocationBottom) && self.borderShadowOffset.height < 0){
                shadowRect.size.height -= self.borderShadowOffset.height;
            }
            
            if(!(self.borderLocation & CKStyleViewBorderLocationTop) && self.borderShadowOffset.height > 0){
                shadowRect.origin.y -= self.borderShadowOffset.height;
                shadowRect.size.height += self.borderShadowOffset.height;
            }
            
            if(!(self.borderLocation & CKStyleViewBorderLocationRight) && self.borderShadowOffset.width < 0){
                shadowRect.size.width -= self.borderShadowOffset.width;
            }
            
            if(!(self.borderLocation & CKStyleViewBorderLocationLeft) && self.borderShadowOffset.width > 0){
                shadowRect.origin.x -= self.borderShadowOffset.width;
                shadowRect.size.width += self.borderShadowOffset.width;
            }
            
            if (self.corners != CKStyleViewCornerTypeNone){
                CGMutablePathRef shadowPath = CGPathCreateMutable();
                if (self.corners != CKStyleViewCornerTypeNone) {
                    shadowPath = [CKStyleView generateBorderPathWithBorderLocation:CKStyleViewBorderLocationAll  borderWidth:0 cornerType:self.corners roundedCornerSize:self.roundedCornerSize rect:shadowRect];
                }
                
                [self.borderColor setFill];
                CGContextAddPath(gc, shadowPath);
                CGContextFillPath(gc);
                CFRelease(shadowPath);
            }else{
                [self.borderColor setFill];
                CGContextFillRect(gc, shadowRect);
            }
            
        }
        
        CGContextRestoreGState(gc);
    }
}

- (void)drawBackgroundColorInRect:(CGRect)rect clippingPath:(CGPathRef)clippingPath context:(CGContextRef)gc {
    if(self.gradientColors == nil && self.image == nil){
        if(self.fillColor != nil)
            [self.fillColor setFill];
        else
            [[UIColor clearColor] setFill];
        
        if (self.corners != CKStyleViewCornerTypeNone){
            CGContextAddPath(gc, clippingPath);
            CGContextFillPath(gc);
        }
        else{
            CGContextFillRect(gc, rect);
        }
    }
}


- (void)drawBackgroundImageInRect:(CGRect)rect clippingPath:(CGPathRef)clippingPath context:(CGContextRef)gc {
    if(self.image){
        if(clippingPath != nil){
            CGContextAddPath(gc, clippingPath);
            CGContextClip(gc);
        }
        
        BOOL clip = NO;
        CGRect originalRect = rect;
        if (self.image.size.width != rect.size.width || self.image.size.height != rect.size.height) {
            if (self.imageContentMode == UIViewContentModeLeft) {
                rect = CGRectMake(rect.origin.x,
                                  rect.origin.y + floor(rect.size.height/2 - self.image.size.height/2),
                                  self.image.size.width, self.image.size.height);
                clip = NO;
            } else if (self.imageContentMode == UIViewContentModeRight) {
                rect = CGRectMake(rect.origin.x + (rect.size.width - self.image.size.width),
                                  rect.origin.y + floor(rect.size.height/2 - self.image.size.height/2),
                                  self.image.size.width, self.image.size.height);
                clip = NO;
            } else if (self.imageContentMode == UIViewContentModeTop) {
                rect = CGRectMake(rect.origin.x + floor(rect.size.width/2 - self.image.size.width/2),
                                  rect.origin.y,
                                  self.image.size.width, self.image.size.height);
                clip = NO;
            } else if (self.imageContentMode == UIViewContentModeBottom) {
                rect = CGRectMake(rect.origin.x + floor(rect.size.width/2 - self.image.size.width/2),
                                  rect.origin.y + floor(rect.size.height - self.image.size.height),
                                  self.image.size.width, self.image.size.height);
                clip = NO;
            } else if (self.imageContentMode == UIViewContentModeCenter) {
                rect = CGRectMake(rect.origin.x + floor(rect.size.width/2 - self.image.size.width/2),
                                  rect.origin.y + floor(rect.size.height/2 - self.image.size.height/2),
                                  self.image.size.width, self.image.size.height);
                clip = NO;
            } else if (self.imageContentMode == UIViewContentModeBottomLeft) {
                rect = CGRectMake(rect.origin.x,
                                  rect.origin.y + floor(rect.size.height - self.image.size.height),
                                  self.image.size.width, self.image.size.height);
                clip = NO;
            } else if (self.imageContentMode == UIViewContentModeBottomRight) {
                rect = CGRectMake(rect.origin.x + (rect.size.width - self.image.size.width),
                                  rect.origin.y + (rect.size.height - self.image.size.height),
                                  self.image.size.width, self.image.size.height);
                clip = NO;
            } else if (self.imageContentMode == UIViewContentModeTopLeft) {
                rect = CGRectMake(rect.origin.x,
                                  rect.origin.y,
                                  self.image.size.width, self.image.size.height);
                clip = NO;
            } else if (self.imageContentMode == UIViewContentModeTopRight) {
                rect = CGRectMake(rect.origin.x + (rect.size.width - self.image.size.width),
                                  rect.origin.y,
                                  self.image.size.width, self.image.size.height);
                clip = NO;
            } else if (self.imageContentMode == UIViewContentModeScaleAspectFill) {
                CGSize imageSize = self.image.size;
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
                clip = YES;
            } else if (self.imageContentMode == UIViewContentModeScaleAspectFit) {
                CGSize imageSize = self.image.size;
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
                clip = YES;
            }
        }
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        if (clip) {
            CGContextSaveGState(context);
            CGContextAddRect(context, originalRect);
            CGContextClip(context);
        }
        
        [self.image drawInRect:rect];
        
        if (clip) {
            CGContextRestoreGState(context);
        }
    }
}


- (void)drawBackgroundGradientInRect:(CGRect)rect clippingPath:(CGPathRef)clippingPath context:(CGContextRef)gc {
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
        switch(self.gradientStyle){
            case CKStyleViewGradientStyleVertical:
                CGContextDrawLinearGradient(gc, gradient, CGPointMake(rect.origin.x, rect.origin.y), CGPointMake(rect.origin.x, rect.origin.y + rect.size.height), 0);
                break;
            case CKStyleViewGradientStyleHorizontal:
                CGContextDrawLinearGradient(gc, gradient, CGPointMake(rect.origin.x, rect.origin.y), CGPointMake(rect.origin.x + rect.size.width, rect.origin.y), 0);
                break;
        }
        //CGContextDrawRadialGradient
        
        CGGradientRelease(gradient);
        CGContextRestoreGState(gc);
    }
}


- (void)drawTopEmbossInRect:(CGRect)rect context:(CGContextRef)gc {
    // Top Emboss
    if (self.embossTopColor && (self.embossTopColor != [UIColor clearColor])) {
        CGContextSaveGState(gc);
        
        CGContextSetShadowWithColor(gc, CGSizeMake(0, 1), 0, self.embossTopColor.CGColor);
        
        CGMutablePathRef topEmbossPath = [CKStyleView generateTopEmbossPathWithBorderLocation:self.borderLocation borderWidth:self.borderWidth borderColor:self.borderColor separatorLocation:self.separatorLocation separatorWidth:self.separatorWidth separatorColor:self.separatorColor cornerType:self.corners roundedCornerSize:self.roundedCornerSize rect:rect];
        
        CGContextAddPath(gc, topEmbossPath);
        
        [[UIColor clearColor]setStroke];
        CGContextSetLineWidth(gc, 1);
        
        UIColor*thecolor = self.embossTopColor;
        [thecolor setStroke];
        
        CGContextStrokePath(gc);
        CFRelease(topEmbossPath);
        CGContextRestoreGState(gc);
    }
}

- (void)drawBottomEmbossInRect:(CGRect)rect context:(CGContextRef)gc {
    
    // Bottom Emboss
    if (self.embossBottomColor && (self.embossBottomColor != [UIColor clearColor])) {
        CGContextSaveGState(gc);
        
        CGContextSetShadowWithColor(gc, CGSizeMake(0, -1), 0, self.embossBottomColor.CGColor);
        
        CGMutablePathRef bottomEmbossPath = [CKStyleView generateBottomEmbossPathWithBorderLocation:self.borderLocation borderWidth:self.borderWidth borderColor:self.borderColor separatorLocation:self.separatorLocation separatorWidth:self.separatorWidth separatorColor:self.separatorColor cornerType:self.corners roundedCornerSize:self.roundedCornerSize rect:rect];
        
        CGContextAddPath(gc, bottomEmbossPath);
        
        CGContextSetLineWidth(gc, 1);
        [[UIColor clearColor]setStroke];
        
        UIColor*thecolor = self.embossBottomColor;
        [thecolor setStroke];
        
        CGContextStrokePath(gc);
        CFRelease(bottomEmbossPath);
        CGContextRestoreGState(gc);
    }
}

- (void)drawSeparatorInRect:(CGRect)rect context:(CGContextRef)gc {
    // Separator
    if(self.separatorColor!= nil && self.separatorColor != [UIColor clearColor] && self.separatorWidth > 0 && self.separatorLocation != CKStyleViewSeparatorLocationNone){
        CGContextSaveGState(gc);
        [self.separatorColor setStroke];
        CGContextSetLineWidth(gc, self.separatorWidth);
        
        CGRect separatorRect = CGRectMake(rect.origin.x + self.separatorInsets.left,
                                          rect.origin.y + self.separatorInsets.top,
                                          rect.size.width - (self.separatorInsets.left + self.separatorInsets.right),
                                          rect.size.height - (self.separatorInsets.top + self.separatorInsets.bottom));
        
        CGMutablePathRef borderPath = [CKStyleView generateBorderPathWithBorderLocation:(CKStyleViewBorderLocation)self.separatorLocation borderWidth:self.separatorWidth cornerType:self.corners roundedCornerSize:self.roundedCornerSize  rect:separatorRect];
        
        CGContextAddPath(gc, borderPath);
        
        if(self.separatorDashLengths){
            CGFloat lengths[self.separatorDashLengths.count];
            int i =0;
            for(NSNumber* n in self.separatorDashLengths){
                lengths[i] = [[self.separatorDashLengths objectAtIndex:i]floatValue];
                ++i;
            }
            CGContextSetLineDash(gc, self.separatorDashPhase,lengths , [self.separatorDashLengths count]);
        }
        
        CGContextSetLineCap(gc,self.separatorLineCap);
        CGContextSetLineJoin(gc, self.separatorLineJoin);
        
        CFRelease(borderPath);
        CGContextStrokePath(gc);
        CGContextRestoreGState(gc);
    }
}


- (void)drawBorderInRect:(CGRect)rect context:(CGContextRef)gc {
    // Border
    if(self.borderColor!= nil && self.borderColor != [UIColor clearColor] && self.borderWidth > 0 && self.borderLocation != CKStyleViewBorderLocationNone){
        CGContextSaveGState(gc);
        
        CGContextSetLineWidth(gc, self.borderWidth);
        
        CGMutablePathRef borderPath = [CKStyleView generateBorderPathWithBorderLocation:(CKStyleViewBorderLocation)self.borderLocation borderWidth:self.borderWidth cornerType:self.corners roundedCornerSize:self.roundedCornerSize  rect:rect];
        
        [self.borderColor setStroke];
        CGContextAddPath(gc, borderPath);
        CGContextStrokePath(gc);
        
        CFRelease(borderPath);
        CGContextRestoreGState(gc);
    }
}

@end
