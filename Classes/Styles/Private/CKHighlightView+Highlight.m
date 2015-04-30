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
@property(nonatomic,retain)NSString* highlightGradientCacheIdentifier;
@property(nonatomic,retain)UIImageView* highlightGradientLayer;
@property(nonatomic,retain)NSString* highlightMaskCacheIdentifier;
@property(nonatomic,retain)UIImageView* highlightMaskLayer;
@end

@implementation CKHighlightView (Highlight)


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
    
    self.highlightGradientLayer.image = gradientImage;
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


@end
