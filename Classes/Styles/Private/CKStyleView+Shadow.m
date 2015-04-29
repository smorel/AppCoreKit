//
//  CKStyleView+Shadow.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-28.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKStyleView+Shadow.h"
#import "CKStyleView+Paths.h"
#import "CKStyleView+Light.h"
#import "UIImage+Transformations.h"

@interface CKStyleView()
@property(nonatomic,retain)UIImageView* shadowImageView;

@end

@implementation CKStyleView (Shadow)

- (BOOL)shadowEnabled{
    return self.borderShadowColor!= nil && self.borderShadowColor != [UIColor clearColor] && self.borderShadowRadius > 0;
}

- (CGRect)shadowImageViewFrame{
    if([self shadowEnabled]){
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
        
        CGFloat multiplier = 1;
        CGRect shadowFrame = self.bounds;
        CGPoint offset = CGPointMake(0,0);
        
        if(self.borderLocation & CKStyleViewBorderLocationLeft){
            offset.x += multiplier * self.borderShadowRadius;
            shadowFrame.size.width += multiplier * self.borderShadowRadius;
            
        }
        if(self.borderLocation & CKStyleViewBorderLocationRight){
            shadowFrame.size.width += multiplier * self.borderShadowRadius;
        }
        if(self.borderLocation & CKStyleViewBorderLocationTop){
            offset.y += multiplier * self.borderShadowRadius;
            shadowFrame.size.height += multiplier * self.borderShadowRadius;
        }
        if(self.borderLocation & CKStyleViewBorderLocationBottom){
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
        
        return CGRectIntegral(shadowFrame);
    }
    
    return self.bounds;
}

- (UIImage*)generateShadowImage{
    UIImage* result = nil;
    @autoreleasepool {
        
        //TODO: compute the smallest resizable image taking care of shadow radius and roundedcornerswidth
        CGRect frame = self.bounds;
        
        CGRect shadowFrame = [self shadowImageViewFrame];
        
        CGSize minimumDrawSize = CGSizeMake(( 2*(self.borderShadowRadius + self.roundedCornerSize)) + 1+ fabs(self.borderShadowOffset.width),
                                            (2* (self.borderShadowRadius + self.roundedCornerSize)) + 1 + fabs(self.borderShadowOffset.height));
        
        CGRect imageRect =  CGRectIntegral(CGRectMake(0,0,
                                                      shadowFrame.size.width - (frame.size.width) + minimumDrawSize.width,
                                                      shadowFrame.size.height - (frame.size.height) + minimumDrawSize.height));
        
        CGRect drawRect = CGRectMake(-shadowFrame.origin.x ,
                                     -shadowFrame.origin.y,
                                     minimumDrawSize.width,
                                     minimumDrawSize.height);
        
        UIEdgeInsets resizableInsets = UIEdgeInsetsMake(self.borderShadowRadius + self.roundedCornerSize + fabs(self.borderShadowOffset.height),
                                                        self.borderShadowRadius + self.roundedCornerSize + fabs(self.borderShadowOffset.width),
                                                        self.borderShadowRadius + self.roundedCornerSize + fabs(self.borderShadowOffset.height),
                                                        self.borderShadowRadius + self.roundedCornerSize + fabs(self.borderShadowOffset.width));
        
        CGSize size = imageRect.size;
        CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
        
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        [self drawShadowInRect:drawRect inContext:context];
        [self clearContentInRect:drawRect inContext:context];
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        result = [[image resizableImageWithCapInsets:resizableInsets resizingMode:UIImageResizingModeStretch]retain];
    }
    
    return [result autorelease];
}

- (void)clearContentInRect:(CGRect)rect inContext:(CGContextRef)gc{
    
    CGContextSaveGState(gc);
    
    CGMutablePathRef clippingPath = [CKStyleView generateBorderPathWithBorderLocation:CKStyleViewBorderLocationAll borderWidth:0 cornerType:self.corners roundedCornerSize:self.roundedCornerSize rect:rect];
    CGContextAddPath(gc, clippingPath);
    CGContextClip(gc);
    
    CGContextClearRect(gc, rect);
    
    CFRelease(clippingPath);
    
    CGContextRestoreGState(gc);
}

- (void)drawShadowInRect:(CGRect)rect inContext:(CGContextRef)gc{
    // Shadow
    if(self.borderLocation != CKStyleViewBorderLocationNone){
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
                CGMutablePathRef shadowPath = nil;
                if (self.corners != CKStyleViewCornerTypeNone) {
                    shadowPath = [CKStyleView generateBorderPathWithBorderLocation:CKStyleViewBorderLocationAll  borderWidth:0 cornerType:self.corners roundedCornerSize:self.roundedCornerSize rect:shadowRect];
                }
                if(shadowPath){
                    
                    [[UIColor blackColor] setFill];
                    CGContextAddPath(gc, shadowPath);
                    CGContextFillPath(gc);
                    CFRelease(shadowPath);
                }
            }else{
                [[UIColor blackColor] setFill];
                CGContextFillRect(gc, shadowRect);
            }
            
        }
        
        CGContextRestoreGState(gc);
    }
}

- (void)layoutShadowImageView{
    if([self shadowEnabled]){
        UIImage* shadowImage = [self generateShadowImage];
        if(!self.shadowImageView){
            self.shadowImageView = [[UIImageView alloc]initWithImage:shadowImage];
            self.shadowImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [self addSubview:self.shadowImageView];
        }else{
            @autoreleasepool {
                self.shadowImageView.image = shadowImage;
            }
        }
        
        self.shadowImageView.frame = [self shadowImageViewFrame];
    }
}

- (void)setShadowEnabled:(BOOL)enabled{
    self.shadowImageView.hidden = !enabled;
}


- (void)regenerateShadow{
    if(![self shadowEnabled])
        return;
    
    @autoreleasepool {
        UIImage* shadowImage = [self generateShadowImage];
        self.shadowImageView.image = shadowImage;
        self.shadowImageView.frame = [self shadowImageViewFrame];
    }
}

@end
