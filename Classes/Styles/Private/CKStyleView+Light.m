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
#import "CKStyleView+Shadow.h"

@interface CKStyleView()
@property(nonatomic,assign)CGRect lastFrameInWindow;
@property(nonatomic,retain)UIImageView* shadowImageView;
@end

@implementation CKStyleView (Light)


- (void)willMoveToWindow:(UIWindow *)newWindow{
    if(newWindow == nil){
        [CKSharedDisplayLink unregisterHandler:self];
        [self clearBindingsContextWithScope:@"Shadow"];
    }
}

- (void)didMoveToWindow{
    [CKSharedDisplayLink registerHandler:self];
    
    __unsafe_unretained CKStyleView* bself = self;
    
    [self beginBindingsContextWithScope:@"Shadow"];
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
    CALayer* prez = self.layer.presentationLayer;
    CGRect rect = [prez.superlayer convertRect:prez.frame toLayer:self.window.layer.presentationLayer];
    if(CGRectEqualToRect(rect, self.lastFrameInWindow))
        return;
    
    self.lastFrameInWindow = rect;
    
    if([self updateShadowWithLightWithRect:rect]){
        [self regenerateShadow];
    }
}

- (BOOL)updateShadowWithLightWithRect:(CGRect)rect{
    if(![self shadowEnabled] || !self.window)
        return NO;
    
    CKLight* light = self.window.light;
    
    CGPoint lightStart = CGPointMake(light.origin.x * self.window.bounds.size.width, light.origin.y * self.window.bounds.size.height);
    CGPoint lightEnd = CGPointMake(light.end.x * self.window.bounds.size.width, light.end.y * self.window.bounds.size.height);
    CGPoint lightDirection = CGPointMake(lightEnd.x - lightStart.x,lightEnd.y - lightStart.y);
    
    CGPoint intersection = CKCGRectIntersect(rect,lightStart,lightDirection);
    CGPoint center = CGPointMake((rect.size.width / 2),(rect.size.height / 2));
    
    CGPoint direction = CKCGPointNormalize( CGPointMake(center.x - intersection.x,center.y - intersection.y) );
    
    CGSize offset = CGSizeMake((NSInteger)(direction.x * light.intensity) , (NSInteger)(direction.y * light.intensity) );
    [self setBorderShadowOffset:offset];
    
    return YES;
}


@end
