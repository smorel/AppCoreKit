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
        [self clearBindingsContextWithScope:@"Light"];
    }
}

- (void)didMoveToWindow{
    [CKSharedDisplayLink registerHandler:self];
    
    __unsafe_unretained CKHighlightView* bself = self;
    
    [self beginBindingsContextWithScope:@"Light"];
    [NSNotificationCenter bindNotificationName:CKLightDidChangeNotification withBlock:^(NSNotification *notification) {
        bself.lastFrameInWindow = CGRectZero;//force recompute
        [bself updateLights];
    }];
    [self endBindingsContext];
}

- (void)sharedDisplayLinkDidRefresh:(CKSharedDisplayLink*)displayLink{
    [self updateLights];
}

- (void)updateLights{
    CGRect rect = CGRectZero;
    CALayer* prez = self.layer.presentationLayer;
    if(prez){
        rect = [prez.superlayer convertRect:prez.frame toLayer:self.window.layer.presentationLayer];
    }else{
        rect = [self.superview convertRect:self.frame toView:self.window];
    }
    
    if(CGRectEqualToRect(rect, self.lastFrameInWindow))
        return;
    
    self.lastFrameInWindow = rect;
    
    if([self updateHighlightWithLightWithRect:rect]){
        [self regenerateHighlight];
    }
    
}

- (BOOL)updateHighlightWithLightWithRect:(CGRect)rect{
    if(![self highlightEnabled] || !self.window)
        return NO;
    
    CKLight* light = self.window.light;
    
    CGPoint lightStart = CGPointMake(light.origin.x * self.window.bounds.size.width, light.origin.y * self.window.bounds.size.height);
    CGPoint lightEnd = CGPointMake(light.end.x * self.window.bounds.size.width, light.end.y * self.window.bounds.size.height);
    CGPoint lightDirection = CGPointMake(lightEnd.x - lightStart.x,lightEnd.y - lightStart.y);
    
    CGPoint intersection = CKCGRectIntersect(rect,lightStart,lightDirection);
    
    self.highlightCenter = intersection;
    return !CGPointEqualToPoint(intersection,CGPointZero);
}



@end
