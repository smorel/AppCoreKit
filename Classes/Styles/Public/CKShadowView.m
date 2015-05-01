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

//#define PRE_COMPUTED_CACHED_SHADOW

@interface CKLight()
@property (nonatomic, assign) CGPoint motionEffectOffset;
@end

@interface CKShadowView()
@property(nonatomic,retain) NSString* shadowCacheIdentifier;
@property(nonatomic,retain) UIImageView* shadowLayer;
@property(nonatomic,retain) NSString* shadowMaskCacheIdentifier;
@property(nonatomic,retain) UIImageView* shadowMaskLayer;
@property(nonatomic,assign) CGPoint shadowMaskInsets;
@end

@implementation CKShadowView

- (void)dealloc{
    if(self.shadowCacheIdentifier){
        [[CKImageCache sharedInstance]unregisterHandler:self withIdentifier:self.shadowCacheIdentifier];
    }
    
    if(self.shadowMaskCacheIdentifier){
        [[CKImageCache sharedInstance]unregisterHandler:self withIdentifier:self.shadowMaskCacheIdentifier];
    }
    
    [_shadowCacheIdentifier release]; _shadowCacheIdentifier = nil;
    [_shadowLayer release]; _shadowLayer = nil;
    [_shadowMaskCacheIdentifier release]; _shadowMaskCacheIdentifier = nil;
    [_shadowMaskLayer release]; _shadowMaskLayer = nil;
    
    [_borderShadowColor release]; _borderShadowColor = nil;
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
    self.borderShadowOffset = CGPointMake(0,0);
    self.borderLocation = CKStyleViewBorderLocationNone;
    
    self.corners = CKStyleViewCornerTypeNone;
    self.roundedCornerSize = 10;
    
    self.userInteractionEnabled = NO;
    
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}


- (void)layoutSubviews{
    [super layoutSubviews];
    
    [self updateEffect];
    [self layoutShadowLayers];
}

- (void)superViewDidModifySubviewHierarchy{
    [self.superview bringSubviewToFront:self];
}

- (BOOL)shadowEnabled{
    return self.borderShadowColor!= nil && self.borderShadowColor != [UIColor clearColor] && self.borderShadowRadius > 0;
}

- (void)layoutShadowLayers{
    if([self shadowEnabled]){
        
        if(!self.shadowLayer){
            self.shadowLayer = [[[UIImageView alloc]init]autorelease];
            [self addSubview:self.shadowLayer];
        }
        
        if(!self.shadowMaskLayer){
            self.shadowMaskLayer = [[[UIImageView alloc]init]autorelease];
            //[self insertSubview:self.shadowMaskLayer belowSubview:self.shadowLayer];
            self.layer.mask = self.shadowMaskLayer.layer;
        }
        
        self.shadowMaskInsets = CGPointMake(self.borderShadowRadius + (self.light.intensity * (self.light.motionEffectScale.x + 1)),
                                            self.borderShadowRadius + (self.light.intensity * (self.light.motionEffectScale.y + 1)));
        
        
        [self updateShadowLayerContent];
        [self updateShadowMaskLayerContent];
         [self setupShadowLayers];
    }
}

#ifdef PRE_COMPUTED_CACHED_SHADOW

- (UIImage*)shadowImage{
    NSString* cacheIdentifier = [NSString stringWithFormat:@"CKStyleView_Shadow_%lu_%f_%lu_%@_%lu",
                                 (unsigned long)self.corners,
                                 self.roundedCornerSize,
                                 (unsigned long)self.borderLocation,
                                 self.borderShadowColor,
                                 (unsigned long)self.borderShadowRadius];
    
    if(![self.shadowCacheIdentifier isEqualToString:cacheIdentifier]){
        self.shadowCacheIdentifier = cacheIdentifier;
        [[CKImageCache sharedInstance]unregisterHandler:self withIdentifier:self.shadowCacheIdentifier];
    }
    
    UIImage* shadowImage = [[CKImageCache sharedInstance]imageWithIdentifier:self.shadowCacheIdentifier];
    if(!shadowImage){
        shadowImage = [self generateShadowImage];
    }
    
    [[CKImageCache sharedInstance]registerHandler:self image:shadowImage withIdentifier:self.shadowCacheIdentifier];
    
    return shadowImage;
}

- (UIImage*)generateShadowImage{
    UIImage* result = nil;
    NSInteger multiple = 1;
    @autoreleasepool {
        CGSize size = CGSizeMake((multiple*2*self.roundedCornerSize) +1, (multiple*2*self.roundedCornerSize) +1);
        
        CGRect shadowRect = CGRectMake(0,0,
                                       size.width  + (2 * self.borderShadowRadius),
                                       size.height + (2 * self.borderShadowRadius));
        
        CGRect drawRect = CGRectMake(self.borderShadowRadius ,
                                     self.borderShadowRadius,
                                     size.width,
                                     size.height);
        
        UIGraphicsBeginImageContext(shadowRect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        [self drawShadowInRect:drawRect inContext:context];
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSInteger inset = self.borderShadowRadius + (self.roundedCornerSize);
        result =  [[image resizableImageWithCapInsets:UIEdgeInsetsMake(inset,inset,inset,inset)
                                         resizingMode:UIImageResizingModeStretch]retain];
    }
    return [result autorelease];
}

- (void)drawShadowInRect:(CGRect)rect inContext:(CGContextRef)gc{
    // Shadow
    if(self.borderLocation != CKStyleViewBorderLocationNone){
        CGContextSaveGState(gc);
        
        CGContextSetShadowWithColor(gc, CGSizeMake(5,5), self.borderShadowRadius, self.borderShadowColor.CGColor);
        [self.borderShadowColor setFill];
        
        if (self.corners != CKStyleViewCornerTypeNone){
            CGMutablePathRef shadowPath = nil;
            if (self.corners != CKStyleViewCornerTypeNone) {
                shadowPath = [CKStyleView generateBorderPathWithBorderLocation:CKStyleViewBorderLocationAll
                                                                   borderWidth:0
                                                                    cornerType:self.corners
                                                             roundedCornerSize:self.roundedCornerSize
                                                                          rect:rect];
            }
            
            if(shadowPath){
                CGContextAddPath(gc, shadowPath);
                CGContextFillPath(gc);
                CFRelease(shadowPath);
            }
            
        }else{
            CGContextFillRect(gc, rect);
        }
        
        
        CGContextRestoreGState(gc);
    }
}



#else

- (UIImage*)shadowImage{
    return [self generateShadowImage];
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
        
        if(self.borderLocation & CKStyleViewBorderLocationBottom && self.borderShadowOffset.y > 0){
            shadowFrame.size.height += self.borderShadowOffset.y;
        }
        
        if(self.borderLocation & CKStyleViewBorderLocationTop && self.borderShadowOffset.y < 0){
            offset.y -= self.borderShadowOffset.y;
            shadowFrame.size.height += -self.borderShadowOffset.y;
        }
        
        if(self.borderLocation & CKStyleViewBorderLocationRight && self.borderShadowOffset.x > 0){
            shadowFrame.size.width += self.borderShadowOffset.x;
        }
        
        if(self.borderLocation & CKStyleViewBorderLocationLeft && self.borderShadowOffset.x < 0){
            offset.x -= self.borderShadowOffset.x;
            shadowFrame.size.width += -self.borderShadowOffset.x;
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
        
        CGSize minimumDrawSize = CGSizeMake(( 2*(self.borderShadowRadius + self.roundedCornerSize)) + 1+ fabs(self.borderShadowOffset.x),
                                            (2* (self.borderShadowRadius + self.roundedCornerSize)) + 1 + fabs(self.borderShadowOffset.y));
        
        CGRect imageRect =  CGRectIntegral(CGRectMake(0,0,
                                                      shadowFrame.size.width - (frame.size.width) + minimumDrawSize.width,
                                                      shadowFrame.size.height - (frame.size.height) + minimumDrawSize.height));
        
        CGRect drawRect = CGRectMake(-shadowFrame.origin.x ,
                                     -shadowFrame.origin.y,
                                     minimumDrawSize.width,
                                     minimumDrawSize.height);
        
        UIEdgeInsets resizableInsets = UIEdgeInsetsMake(self.borderShadowRadius + self.roundedCornerSize + fabs(self.borderShadowOffset.y),
                                                        self.borderShadowRadius + self.roundedCornerSize + fabs(self.borderShadowOffset.x),
                                                        self.borderShadowRadius + self.roundedCornerSize + fabs(self.borderShadowOffset.y),
                                                        self.borderShadowRadius + self.roundedCornerSize + fabs(self.borderShadowOffset.x));
        
        CGSize size = imageRect.size;
        CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
        
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        [self drawShadowInRect:drawRect inContext:context];
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        result = [[image resizableImageWithCapInsets:resizableInsets resizingMode:UIImageResizingModeStretch]retain];
    }
    
    return [result autorelease];
}

- (void)drawShadowInRect:(CGRect)rect inContext:(CGContextRef)gc{
    // Shadow
    if(self.borderLocation != CKStyleViewBorderLocationNone){
        CGContextSaveGState(gc);
        
        if(self.borderShadowColor!= nil && self.borderShadowColor != [UIColor clearColor] && self.borderShadowRadius > 0){
            CGContextSetShadowWithColor(gc, CGSizeMake(self.borderShadowOffset.x,self.borderShadowOffset.y), self.borderShadowRadius, self.borderShadowColor.CGColor);
            
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
            
            if(!(self.borderLocation & CKStyleViewBorderLocationBottom) && self.borderShadowOffset.y < 0){
                shadowRect.size.height -= self.borderShadowOffset.y;
            }
            
            if(!(self.borderLocation & CKStyleViewBorderLocationTop) && self.borderShadowOffset.y > 0){
                shadowRect.origin.y -= self.borderShadowOffset.y;
                shadowRect.size.height += self.borderShadowOffset.y;
            }
            
            if(!(self.borderLocation & CKStyleViewBorderLocationRight) && self.borderShadowOffset.x < 0){
                shadowRect.size.width -= self.borderShadowOffset.x;
            }
            
            if(!(self.borderLocation & CKStyleViewBorderLocationLeft) && self.borderShadowOffset.x > 0){
                shadowRect.origin.x -= self.borderShadowOffset.x;
                shadowRect.size.width += self.borderShadowOffset.x;
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

#endif



- (void)updateShadowLayerContent{
    UIImage* shadowImage = [self shadowImage];
    self.shadowLayer.image = shadowImage;
}



- (UIImage*)shadowMaskImage{
    NSString* cacheIdentifier = [NSString stringWithFormat:@"CKStyleView_Shadow_Mask_%lu_%f_%lu_%lu_%lu",
                                      (unsigned long)self.corners,self.roundedCornerSize,(unsigned long)self.borderLocation,
                                 (unsigned long)self.shadowMaskInsets.x,(unsigned long)self.shadowMaskInsets.y];
    
    if(![self.shadowMaskCacheIdentifier isEqualToString:@"cacheIdentifier"]){
        self.shadowMaskCacheIdentifier = cacheIdentifier;
        [[CKImageCache sharedInstance]unregisterHandler:self withIdentifier:self.shadowMaskCacheIdentifier];
    }
    
    
    UIImage* maskImage = [[CKImageCache sharedInstance]imageWithIdentifier:self.shadowMaskCacheIdentifier];
    if(!maskImage){
        CGSize size = CGSizeMake((2*self.roundedCornerSize) + (2* self.shadowMaskInsets.x) +1,
                                 (2*self.roundedCornerSize) + (2* self.shadowMaskInsets.y) +1);
        
        CGRect rect = CGRectMake(self.shadowMaskInsets.x,self.shadowMaskInsets.y,
                                 size.width - (2 *self.shadowMaskInsets.x),
                                 size.height - (2 * self.shadowMaskInsets.y));
        
        CGMutablePathRef contentPath = [CKStyleView generateBorderPathWithBorderLocation:CKStyleViewBorderLocationAll
                                                                               borderWidth:0
                                                                                cornerType:self.corners
                                                                         roundedCornerSize:self.roundedCornerSize
                                                                                      rect:rect];
        //CGPathRef reversePath = CGPathByReversingPath(contentPath);
        
        maskImage = [UIImage maskImageWithEvenOddPath:contentPath size:size];
        maskImage = [maskImage resizableImageWithCapInsets:UIEdgeInsetsMake(self.shadowMaskInsets.y + self.roundedCornerSize,
                                                                            self.shadowMaskInsets.x + self.roundedCornerSize,
                                                                            self.shadowMaskInsets.y + self.roundedCornerSize,
                                                                            self.shadowMaskInsets.x + self.roundedCornerSize)
                                              resizingMode:UIImageResizingModeStretch];
        
        CGPathRelease(contentPath);
        //CGPathRelease(reversePath);
    }
    
    [[CKImageCache sharedInstance]registerHandler:self image:maskImage withIdentifier:self.shadowMaskCacheIdentifier];
    return maskImage;
}

- (void)updateShadowMaskLayerContent{
    UIImage* maskImage = [self shadowMaskImage];
    self.shadowMaskLayer.image = maskImage;
}

- (void)setupShadowLayers{
    CGRect rect = CGRectMake(-self.shadowMaskInsets.x,
                             -self.shadowMaskInsets.y,
                             self.bounds.size.width + (2 * self.shadowMaskInsets.x),
                             self.bounds.size.height + (2 * self.shadowMaskInsets.y));
    
    self.shadowMaskLayer.frame = rect;
    
    self.shadowLayer.frame = CGRectMake(self.borderShadowOffset.x-self.borderShadowRadius,
                                        self.borderShadowOffset.y-self.borderShadowRadius,
                                        self.bounds.size.width + (2 * self.borderShadowRadius),
                                        self.bounds.size.height+ (2 * self.borderShadowRadius));
    
}

- (void)regenerateShadow{
    if(![self shadowEnabled])
        return;
    
#ifndef PRE_COMPUTED_CACHED_SHADOW
    [self updateShadowLayerContent];
#endif 
    
    [self setupShadowLayers];
}


- (void)setShadowEnabled:(BOOL)enabled{
    self.hidden = !enabled;
}

- (void)updateEffectWithRect:(CGRect)rect{
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    if([self updateShadowWithLightWithRect:rect]){
        [self regenerateShadow];
    }
    
    [CATransaction commit];
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
    
    CGPoint offset = CGPointMake((NSInteger)((-light.motionEffectOffset.x * light.intensity) +  (direction.x * light.intensity)) ,
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