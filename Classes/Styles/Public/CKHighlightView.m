//
//  CKHighlightView.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-29.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKHighlightView.h"
#import "CKImageCache.h"
#import "NSObject+Bindings.h"
#import "CKStyleView+Paths.h"
#import "UIImage+Transformations.h"
#import "CKImageCache.h"
#import "CoreGraphics+Additions.h"

@interface CKLight()
@property (nonatomic, assign) CGPoint motionEffectOffset;
@end


@interface CKHighlightView()
@property(nonatomic,retain)NSString* highlightGradientCacheIdentifier;
@property(nonatomic,retain)UIImageView* highlightGradientLayer;
@property(nonatomic,retain)NSString* highlightMaskCacheIdentifier;
@property(nonatomic,retain)UIImageView* highlightMaskLayer;
@end



@implementation CKHighlightView

- (void)dealloc {
    if(self.highlightGradientCacheIdentifier){
        [[CKImageCache sharedInstance]unregisterHandler:self withIdentifier:self.highlightGradientCacheIdentifier];
    }
    
    if(self.highlightMaskCacheIdentifier){
        [[CKImageCache sharedInstance]unregisterHandler:self withIdentifier:self.highlightMaskCacheIdentifier];
    }
    
    [_highlightColor release]; _highlightColor = nil;
    [_highlightMaskLayer release]; _highlightMaskLayer = nil;
    [_highlightGradientLayer release]; _highlightGradientLayer = nil;
    [_highlightGradientCacheIdentifier release]; _highlightGradientCacheIdentifier = nil;
    [_highlightMaskCacheIdentifier release]; _highlightMaskCacheIdentifier = nil;
    [super dealloc];
}

- (void)postInit {
    [super postInit];
    self.highlightColor = [UIColor whiteColor];
    self.highlightRadius = 200;
    self.highlightWidth = 0;
    self.highlightEndColor =[UIColor colorWithRed:1 green:1 blue:1 alpha:0];
    
    self.backgroundColor = [UIColor clearColor];
    
    self.corners = CKStyleViewCornerTypeNone;
    self.roundedCornerSize = 10;
    
    self.clipsToBounds = 1;
    self.userInteractionEnabled = NO;
    
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (id)copyWithZone:(NSZone *)zone{
    CKHighlightView* other = [[[self class]alloc]initWithFrame:self.frame];
    other.corners = self.corners;
    other.roundedCornerSize = self.roundedCornerSize;
    other.highlightColor = self.highlightColor;
    other.highlightRadius = self.highlightRadius;
    other.highlightWidth = self.highlightWidth;
    other.highlightEndColor = self.highlightEndColor;
    return other;
}

- (void)layoutSubviews{
    [super layoutSubviews];

    [self updateEffect];
    [self layoutHighlightLayers];
}

- (void)superViewDidModifySubviewHierarchy{
    [self.superview bringSubviewToFront:self];
}


- (BOOL)highlightEnabled{
    return self.highlightColor!= nil && self.highlightColor != [UIColor clearColor] && self.highlightWidth > 0;
}

- (void)setHighlightEnabled:(BOOL)enabled{
    self.hidden = !enabled;
}

- (void)layoutHighlightLayers{
    if([self highlightEnabled]){
        
        if(!self.highlightGradientLayer){
            self.highlightGradientLayer = [[[UIImageView alloc]init]autorelease];
            [self addSubview:self.highlightGradientLayer];
        }
        
        if(!self.highlightMaskLayer){
            self.highlightMaskLayer = [[[UIImageView alloc]init]autorelease];
            self.layer.mask = self.highlightMaskLayer.layer;
        }
        
        self.highlightMaskLayer.frame = self.bounds;
        
        [self updateHighlightGradientLayerContent];
        [self updateHighlightMaskLayerContent];
        [self setupHighlightLayers];
    }
    
}

- (UIImage*)highlightGradientImage{
    NSString* cacheIdentifier = [NSString stringWithFormat:@"CKStyleView_Highlight_Gradient_%f_%@_%@",
                                             self.highlightRadius,self.highlightColor,self.highlightEndColor];
    
    return [[CKImageCache sharedInstance]findOrCreateImageWithHandler:self handlerCacheIdentifierProperty:@"highlightGradientCacheIdentifier" cacheIdentifier:cacheIdentifier generateImageBlock:^UIImage *{
        return [UIImage radialGradientImageWithRadius:self.highlightRadius startColor:self.highlightColor endColor:self.highlightEndColor options:0];
    }];
}

- (void)updateHighlightGradientLayerContent{
    UIImage* gradientImage = [self highlightGradientImage];
    
    self.highlightGradientLayer.image = gradientImage;
    self.highlightGradientLayer.bounds = CGRectMake(0,0,gradientImage.size.width,gradientImage.size.height);
}

- (UIImage*)highlightMaskImage{
    NSString* cacheIdentifier = [NSString stringWithFormat:@"CKStyleView_Highlight_Mask_%lu_%f_%f",
                                         (unsigned long)self.corners,self.roundedCornerSize,self.highlightWidth];
    
    return [[CKImageCache sharedInstance]findOrCreateImageWithHandler:self handlerCacheIdentifierProperty:@"highlightMaskCacheIdentifier" cacheIdentifier:cacheIdentifier generateImageBlock:^UIImage *{
        CGFloat cornerSize = (self.roundedCornerSize > 0 ? self.roundedCornerSize : 1) + self.highlightWidth;
        
        CGSize size = CGSizeMake(2*cornerSize,2*cornerSize+1);
        CGRect rect = CGRectMake(0,0,size.width,size.height);
        
        CGMutablePathRef highlightPath = [CKStyleView generateBorderPathWithBorderLocation:CKStyleViewBorderLocationAll
                                                                               borderWidth:self.highlightWidth
                                                                                cornerType:self.corners
                                                                         roundedCornerSize:self.roundedCornerSize
                                                                                      rect:rect];
        
        UIImage* maskImage = [UIImage maskImageWithStrokePath:highlightPath width:self.highlightWidth size:size];
        maskImage = [maskImage resizableImageWithCapInsets:UIEdgeInsetsMake(cornerSize, cornerSize,cornerSize,cornerSize)
                                              resizingMode:UIImageResizingModeStretch];
        
        CGPathRelease(highlightPath);
        
        return maskImage;
    }];
}

- (void)updateHighlightMaskLayerContent{
    UIImage* maskImage = [self highlightMaskImage];
    
    self.highlightMaskLayer.image = maskImage;
}

- (void)setupHighlightLayers{
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    self.highlightGradientLayer.layer.position = self.highlightCenter;
    
    [CATransaction commit];
}

- (void)regenerateHighlight{
    if(![self highlightEnabled])
        return;
    
    [self setupHighlightLayers];
}

- (void)updateEffectWithRect:(CGRect)rect{
    if([self updateHighlightWithLightWithRect:rect]){
        [self regenerateHighlight];
    }
}

- (BOOL)updateHighlightWithLightWithRect:(CGRect)rect{
    if(![self highlightEnabled] || !self.window)
        return NO;
    
    CKLight* light = self.light;
    
    CGPoint lightStart = CGPointMake((light.motionEffectOffset.x + light.origin.x) * self.window.bounds.size.width,
                                     (light.motionEffectOffset.y + light.origin.y ) * self.window.bounds.size.height);
    
    CGPoint lightEnd = CGPointMake(rect.origin.x + (light.anchorPoint.x * (rect.size.width - 1)),
                                   rect.origin.y + (light.anchorPoint.y * (rect.size.height - 1)));
    
    CGPoint lightDirection = CGPointMake(lightEnd.x - lightStart.x,lightEnd.y - lightStart.y);
    
    CGPoint intersection = CKCGRectIntersect(rect,lightStart,lightDirection);
    
    self.highlightCenter = intersection;
    return !CGPointEqualToPoint(intersection,CGPointZero);
}



@end



@implementation UIView(CKHighlightView)

- (CKHighlightView*)highlightView{
    if(self.subviews.count == 0)
        return nil;
    
    for(NSInteger i = self.subviews.count - 1; i >= 0; --i){
        UIView* view =[self.subviews objectAtIndex:i];
        if([view isKindOfClass:[CKHighlightView class]])
            return (CKHighlightView*)view;
    }
    
    return nil;
}

@end