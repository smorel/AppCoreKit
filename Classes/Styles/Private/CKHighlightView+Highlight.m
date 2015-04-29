//
//  CKStyleView+Highlight.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-28.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKHighlightView+Highlight.h"
#import "CKStyleView+Paths.h"
#import "CKStyleView+Light.h"
#import "UIImage+Transformations.h"
#import "CKImageCache.h"

@interface CKHighlightView()
@property(nonatomic,retain)CALayer* highlightLayer;
@property(nonatomic,retain)NSString* highlightGradientCacheIdentifier;
@property(nonatomic,retain)CALayer* highlightGradientLayer;
@property(nonatomic,retain)NSString* highlightMaskCacheIdentifier;
@property(nonatomic,retain)CALayer* highlightMaskLayer;
@end

@implementation CKHighlightView (Highlight)


- (BOOL)highlightEnabled{
    return self.highlightColor!= nil && self.highlightColor != [UIColor clearColor] && self.highlightWidth > 0;
}

- (void)setHighlightEnabled:(BOOL)enabled{
    self.highlightLayer.hidden = !enabled;
}

- (void)layoutHighlightLayers{
    
    if([self highlightEnabled]){
        if(!self.highlightLayer){
            self.highlightLayer = [[[CALayer alloc]init]autorelease];
            self.highlightLayer.contentsGravity = kCAGravityTopLeft;
            [self.layer addSublayer:self.highlightLayer];
        }
        
        if(!self.highlightGradientLayer){
            self.highlightGradientLayer = [[[CALayer alloc]init]autorelease];
            [self.highlightLayer addSublayer:self.highlightGradientLayer];
        }
        
        if(!self.highlightMaskLayer){
            self.highlightMaskLayer = [[[CALayer alloc]init]autorelease];
            self.highlightLayer.mask = self.highlightMaskLayer;
        }
        
        
        self.highlightLayer.frame = self.bounds;
        self.highlightMaskLayer.frame = self.highlightLayer.frame;
        
        [self updateHighlightGradientLayerContent];
        [self updateHighlightMaskLayerContent];
        [self setupHighlightLayers];
    }
    
}

- (UIImage*)highlightGradientImage{
    if(self.highlightGradientCacheIdentifier){
        [[CKImageCache sharedInstance]unregisterHandler:self withIdentifier:self.highlightGradientCacheIdentifier];
    }
    
    self.highlightGradientCacheIdentifier = [NSString stringWithFormat:@"CKStyleView_Highlight_Gradient_%f_%@_%@",
                                             self.highlightRadius,self.highlightColor,self.highlightEndColor];
    UIImage* gradientImage = [[CKImageCache sharedInstance]imageWithIdentifier:self.highlightGradientCacheIdentifier];
    if(!gradientImage){
        gradientImage = [UIImage radialGradientImageWithRadius:self.highlightRadius startColor:self.highlightColor endColor:self.highlightEndColor options:0];
    }
    
    [[CKImageCache sharedInstance]registerHandler:self image:gradientImage withIdentifier:self.highlightGradientCacheIdentifier];
    return gradientImage;
}

- (void)updateHighlightGradientLayerContent{
    UIImage* gradientImage = [self highlightGradientImage];
    
    self.highlightGradientLayer.contents = (id)gradientImage.CGImage;
    self.highlightGradientLayer.bounds = CGRectMake(0,0,gradientImage.size.width,gradientImage.size.height);
}

- (UIImage*)highlightMaskImage{
    if(self.highlightMaskCacheIdentifier){
        [[CKImageCache sharedInstance]unregisterHandler:self withIdentifier:self.highlightMaskCacheIdentifier];
    }
    
    self.highlightMaskCacheIdentifier = [NSString stringWithFormat:@"CKStyleView_Highlight_Mask_%lu_%f_%f",
                                         (unsigned long)self.corners,self.roundedCornerSize,self.highlightWidth];
    
    UIImage* maskImage = [[CKImageCache sharedInstance]imageWithIdentifier:self.highlightMaskCacheIdentifier];
    if(!maskImage){
        CGMutablePathRef highlightPath = [CKStyleView generateBorderPathWithBorderLocation:CKStyleViewBorderLocationAll
                                                                               borderWidth:self.highlightWidth
                                                                                cornerType:self.corners
                                                                         roundedCornerSize:self.roundedCornerSize
                                                                                      rect:self.bounds];
        
        maskImage = [UIImage maskImageWithStrokePath:highlightPath width:self.highlightWidth size:self.bounds.size];
        
        CGPathRelease(highlightPath);
    }
    
    [[CKImageCache sharedInstance]registerHandler:self image:maskImage withIdentifier:self.highlightMaskCacheIdentifier];
    return maskImage;
}

- (void)updateHighlightMaskLayerContent{
    UIImage* maskImage = [self highlightMaskImage];
    
    self.highlightMaskLayer.contents = (id)maskImage.CGImage;
}

- (void)setupHighlightLayers{
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    self.highlightGradientLayer.position = self.highlightCenter;
    
    [CATransaction commit];
}

- (void)regenerateHighlight{
    if(![self highlightEnabled])
        return;
    
    [self setupHighlightLayers];
}


@end
