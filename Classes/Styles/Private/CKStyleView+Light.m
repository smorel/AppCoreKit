//
//  CKStyleView+Light.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-24.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKStyleView+Light.h"
#import "CKStyleView+Paths.h"
#import "CoreGraphics+Additions.h"
#import "UIColor+Additions.h"
#import "UIColor+Components.h"
#import "CKImageCache.h"
#import "UIImage+Transformations.h"
#import "CKStyleView+Highlight.h"
#import "CKStyleView+Shadow.h"

@interface CKStyleView()
@property(nonatomic,assign)CGRect lastFrameInWindow;
@property(nonatomic,retain)UIImageView* shadowImageView;
@property(nonatomic,retain)CALayer* highlightLayer;
@end

@implementation CKStyleView (Light)


- (void)willMoveToWindow:(UIWindow *)newWindow{
    if(newWindow == nil){
        [CKSharedDisplayLink unregisterHandler:self];
    }
}

- (void)didMoveToWindow{
    // if([self shadowEnabled] || [self highlightEnabled]){
        [CKSharedDisplayLink registerHandler:self];
    //}
}

- (void)sharedDisplayLinkDidRefresh:(CKSharedDisplayLink*)displayLink{
    [self updateLights];
}

- (void)updateLights{
    // if(   ([self shadowEnabled] && self.shadowImageView.hidden == NO)
    //   || ([self highlightEnabled] && self.highlightLayer.hidden == NO) ){
        CALayer* prez = self.layer.presentationLayer;
        CGRect rect = [prez.superlayer convertRect:prez.frame toLayer:self.window.layer.presentationLayer];
        if(CGRectEqualToRect(rect, self.lastFrameInWindow))
            return;
        
        self.lastFrameInWindow = rect;
    
      [CATransaction begin];
     [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        if([self updateShadowWithLightWithRect:rect]){
            [self regenerateShadow];
        }
        
        if([self updateHighlightWithLightWithRect:rect]){
            [self regenerateHighlight];
        }
    [CATransaction commit];
    //}
}

- (BOOL)updateShadowWithLightWithRect:(CGRect)rect{
    if(![self shadowEnabled] || !self.window)
        return NO;
    
    CGPoint lightPosition = self.lightPosition;
    CGFloat lightIntensity = self.lightIntensity;
    CGPoint lightDirection = self.lightDirection;
    
    CGPoint diff = CGPointMake(rect.origin.x + rect.size.width - lightPosition.x,rect.origin.y + rect.size.height - lightPosition.y );
    
    CGPoint direction = CKCGPointNormalize( diff );
    
    CGSize offset = CGSizeMake((NSInteger)(direction.x * lightIntensity) , (NSInteger)(direction.y * lightIntensity) );
    [self setBorderShadowOffset:offset];
    
    return YES;
}


- (BOOL)updateHighlightWithLightWithRect:(CGRect)rect{
    if(![self highlightEnabled] || !self.window)
        return NO;
    
    CGPoint lightPosition = self.lightPosition;
    CGFloat lightIntensity = self.lightIntensity;
    CGPoint lightDirection = self.lightDirection;
    
    CGPoint nonNormalizedLightDirection = CGPointMake(lightDirection.x * self.window.bounds.size.width * 2,lightDirection.y * self.window.bounds.size.height * 2);
    
    CGPoint intersection = CKCGRectIntersect(rect,lightPosition,nonNormalizedLightDirection);
    
    self.highlightCenter = intersection;
    return !CGPointEqualToPoint(intersection,CGPointZero);
}



@end
