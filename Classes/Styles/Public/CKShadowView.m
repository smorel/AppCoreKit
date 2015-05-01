//
//  CKShadowView.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-05-01.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKShadowView.h"
#import "CKImageCache.h"
#import "NSObject+Bindings.h"
#import "CKStyleView+Paths.h"
#import "UIImage+Transformations.h"
#import "CKImageCache.h"
#import "CoreGraphics+Additions.h"

@interface CKLight()
@property (nonatomic, assign) CGPoint motionEffectOffset;
@end

@interface CKShadowView()
@property(nonatomic,retain)UIImageView* shadowImageView;
@end

@implementation CKShadowView

- (void)dealloc{
    [_borderShadowColor release]; _borderShadowColor = nil;
    [_shadowImageView release]; _shadowImageView = nil;
    [super dealloc];
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

- (void)postInit {
    
    self.borderShadowRadius = 2;
    self.borderShadowOffset = CGSizeMake(0,0);
    self.borderLocation = CKStyleViewBorderLocationNone;
    
    self.corners = CKStyleViewCornerTypeNone;
    self.roundedCornerSize = 10;
    
    self.userInteractionEnabled = NO;
    
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}


- (void)layoutSubviews{
    [super layoutSubviews];
    
    [self updateEffect];
    [self layoutShadowImageView];
}

- (void)superViewDidModifySubviewHierarchy{
    [self.superview bringSubviewToFront:self];
}

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
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    @autoreleasepool {
        UIImage* shadowImage = [self generateShadowImage];
        self.shadowImageView.image = shadowImage;
        self.shadowImageView.frame = [self shadowImageViewFrame];
    }
    
    [CATransaction commit];
}

- (void)updateEffectWithRect:(CGRect)rect{
    if([self updateShadowWithLightWithRect:rect]){
        [self regenerateShadow];
    }
}

- (BOOL)updateShadowWithLightWithRect:(CGRect)rect{
    if(![self shadowEnabled] || !self.window)
        return NO;
    
    CKLight* light = [CKLight sharedInstance];
    
    CGPoint lightStart = CGPointMake((light.motionEffectOffset.x + light.origin.x) * self.window.bounds.size.width,
                                     (light.motionEffectOffset.y + light.origin.y ) * self.window.bounds.size.height);
    
    CGPoint lightEnd = CGPointMake(light.end.x * self.window.bounds.size.width, light.end.y * self.window.bounds.size.height);
    CGPoint lightDirection = CGPointMake(lightEnd.x - lightStart.x,lightEnd.y - lightStart.y);
    
    CGPoint intersection = CKCGRectIntersect(rect,lightStart,lightDirection);
    CGPoint bottomRight = CGPointMake(rect.size.width ,rect.size.height);
    
    CGPoint direction = CKCGPointNormalize( CGPointMake( bottomRight.x - intersection.x ,bottomRight.y - intersection.y) );
    
    CGSize offset = CGSizeMake((NSInteger)((-light.motionEffectOffset.x * light.intensity) +  (direction.x * light.intensity)) ,
                               (NSInteger)((-light.motionEffectOffset.y *light.intensity) + (direction.y * light.intensity)) );
    [self setBorderShadowOffset:offset];
    
    return YES;
}


@end


@implementation UIView(CKShadowView)

- (CKShadowView*)shadowView{
    if(self.subviews.count == 0)
        return nil;
    
    for(NSInteger i = self.subviews.count - 1; i >= 0; --i){
        UIView* view =[self.subviews objectAtIndex:i];
        if([view isKindOfClass:[CKShadowView class]])
            return (CKShadowView*)view;
    }
    
    return nil;
}

@end