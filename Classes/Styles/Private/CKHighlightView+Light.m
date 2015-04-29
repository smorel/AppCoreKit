//
//  CKStyleView+Light.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-24.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKHighlightView+Light.h"
#import "CKStyleView+Paths.h"
#import "CKHighlightView+Highlight.h"
#import "CoreGraphics+Additions.h"
#import "UIColor+Additions.h"
#import "UIColor+Components.h"
#import "CKImageCache.h"
#import "UIImage+Transformations.h"
#import "CKStyleView+Shadow.h"

@interface CKHighlightView()
@property(nonatomic,assign)CGRect lastFrameInWindow;
@property(nonatomic,retain)CALayer* highlightLayer;
@end

@implementation CKHighlightView (Light)


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
    
        if([self updateHighlightWithLightWithRect:rect]){
            [self regenerateHighlight];
        }
    //}
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
