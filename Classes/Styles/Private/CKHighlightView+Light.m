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

@interface CKLight()
@property (nonatomic, assign) CGPoint motionEffectOffset;
@end


@interface CKHighlightView()
@property(nonatomic,assign)CGRect lastFrameInWindow;
@property(nonatomic,retain)CALayer* highlightLayer;
@end

@implementation CKHighlightView (Light)

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
    CGPoint lightEnd = CGPointMake(light.end.x * self.window.bounds.size.width, light.end.y * self.window.bounds.size.height);
    CGPoint lightDirection = CGPointMake(lightEnd.x - lightStart.x,lightEnd.y - lightStart.y);
    
    CGPoint intersection = CKCGRectIntersect(rect,lightStart,lightDirection);
    
    self.highlightCenter = intersection;
    return !CGPointEqualToPoint(intersection,CGPointZero);
}

@end
