//
//  CKShadeView.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-05-04.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKShadeView.h"
#import "UIView+Name.h"
#import "CKImageCache.h"
#import "CKStyleView+Paths.h"
#import "UIImage+Transformations.h"
#import "UIColor+Components.h"

@interface CKShadeView()
@property(nonatomic,retain) NSString* shadeImageChacheIdentifier;
@property(nonatomic,retain) UIImageView* shadeImageLayer;
@end

@implementation CKShadeView

- (void)dealloc {
    if(self.shadeImageChacheIdentifier){
        [[CKImageCache sharedInstance]unregisterHandler:self withIdentifier:self.shadeImageChacheIdentifier];
    }
    
    [_shadeImageChacheIdentifier release];
    [_shadeImageLayer release];
    [_shadeColor release];
    [super dealloc];
}

- (void)postInit {
    [super postInit];
    //  self.updateOnlyWhenFrameChangesInWindow = NO;
    
    
    self.corners = CKStyleViewCornerTypeNone;
    self.roundedCornerSize = 10;
    
    self.shadeColor = [UIColor blackColor];
    self.noShadeZ = 0;
    self.fullShadeZ = -100;
    
    self.backgroundColor = [UIColor clearColor];
    
    self.clipsToBounds = 1;
    self.userInteractionEnabled = NO;
    
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (id)copyWithZone:(NSZone *)zone{
    CKShadeView* other = [[[self class]alloc]initWithFrame:self.frame];
    other.corners = self.corners;
    other.roundedCornerSize = self.roundedCornerSize;
    other.shadeColor = self.shadeColor;
    other.noShadeZ = self.noShadeZ;
    other.fullShadeZ = self.fullShadeZ;
    return other;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [self updateEffect];
    [self layoutShadeLayers];
}

- (void)superViewDidModifySubviewHierarchy{
    [self.superview bringSubviewToFront:self];
}

- (void)updateEffectWithRect:(CGRect)rect{
    CATransform3D transform = CATransform3DIdentity;
    CALayer* layer = self.layer.presentationLayer ? self.layer.presentationLayer : self.layer;
    while(layer && (layer != self.window.layer && layer != self.window.layer.presentationLayer)){
       transform = CATransform3DConcat(transform, layer.transform);
       layer = layer.superlayer.presentationLayer ?  layer.superlayer.presentationLayer : layer.superlayer;
    }
    
    CGFloat z = transform.m42 + transform.m43;
    
    CGFloat shadeVect = self.fullShadeZ - self.noShadeZ;
    CGFloat shade = fabs((z - self.noShadeZ) / shadeVect);
    
    CGFloat alpha = MAX(0,MIN(1,shade));
    
    self.shadeImageLayer.alpha = alpha;
}

- (void)layoutShadeLayers{
    if(!self.shadeImageLayer){
        self.shadeImageLayer = [[[UIImageView alloc]init]autorelease];
        [self addSubview:self.shadeImageLayer];
    }
    
    self.shadeImageLayer.frame = self.bounds;
    
    [self updateShadeLayerContent];
}


- (void)updateShadeLayerContent{
    UIImage* maskImage = [self shadeImage];
    
    self.shadeImageLayer.image = maskImage;
}

- (UIImage*)shadeImage{
    NSString* cacheIdentifier = [NSString stringWithFormat:@"CKStyleView_Shade_Mask_%lu_%f_%@",
                                 (unsigned long)self.corners,self.roundedCornerSize,self.shadeColor];
    
    return [[CKImageCache sharedInstance]findOrCreateImageWithHandler:self handlerCacheIdentifierProperty:@"shadeImageChacheIdentifier" cacheIdentifier:cacheIdentifier generateImageBlock:^UIImage *{
        CGSize size = CGSizeMake(2*self.roundedCornerSize+1,2*self.roundedCornerSize+1);
        CGRect rect = CGRectMake(0,0,size.width,size.height);
        
        CGMutablePathRef shadePath = [CKStyleView generateBorderPathWithBorderLocation:CKStyleViewBorderLocationAll
                                                                           borderWidth:0
                                                                            cornerType:self.corners
                                                                     roundedCornerSize:self.roundedCornerSize
                                                                                  rect:rect];
        
        UIImage* shadeImage = [UIImage filledImageWithColor:self.shadeColor path:shadePath size:size];
        shadeImage = [shadeImage resizableImageWithCapInsets:UIEdgeInsetsMake(self.roundedCornerSize, self.roundedCornerSize,self.roundedCornerSize,self.roundedCornerSize) resizingMode:UIImageResizingModeStretch];
        
        CGPathRelease(shadePath);
        
        return shadeImage;
    }];
}

@end


@implementation UIView(CKShadeView)

- (CKShadeView*)shadeView{
    if(self.subviews.count == 0)
        return nil;
    
    for(NSInteger i = self.subviews.count - 1; i >= 0; --i){
        UIView* view =[self.subviews objectAtIndex:i];
        if([view isKindOfClass:[CKShadeView class]])
            return (CKShadeView*)view;
    }
    
    return nil;
}

@end
