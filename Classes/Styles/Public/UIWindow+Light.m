//
//  UIWindow+Light.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-30.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "UIWindow+Light.h"
#import "CKPropertyExtendedAttributes.h"
#import <objc/runtime.h>

NSString* CKLightDidChangeNotification = @"CKLightDidChangeNotification";

@interface CKLight()
@property (nonatomic, assign) CGPoint motionEffectOffset;
@end

@implementation CKLight

- (instancetype)init{
    self = [super init];
    
    self.origin = CGPointMake(0,0);
    self.intensity = 20;
    self.end = CGPointMake(0.5,0.5);
    
    return self;
}

- (void)setOrigin:(CGPoint)lightOrigin{
    _origin = lightOrigin;
    [[NSNotificationCenter defaultCenter]postNotificationName:CKLightDidChangeNotification object:self];
}

- (void)setIntensity:(CGFloat)lightIntensity{
    _intensity = lightIntensity;
    [[NSNotificationCenter defaultCenter]postNotificationName:CKLightDidChangeNotification object:self];
}

- (void)setEnd:(CGPoint)lightEnd{
    _end = lightEnd;
    [[NSNotificationCenter defaultCenter]postNotificationName:CKLightDidChangeNotification object:self];
}

- (void)setMotionEffectOffset:(CGPoint)motionEffectOffset{
    _motionEffectOffset = motionEffectOffset;
    [[NSNotificationCenter defaultCenter]postNotificationName:CKLightDidChangeNotification object:self];
}

@end

@implementation UIWindow (Light)
@dynamic light;

- (void)lightExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.contentType = [CKLight class];
}

static char UIWindowLightKey;
- (void)setLight:(CKLight *)light{
    objc_setAssociatedObject(self, &UIWindowLightKey, light, OBJC_ASSOCIATION_RETAIN);
    [[NSNotificationCenter defaultCenter]postNotificationName:CKLightDidChangeNotification object:light];
}

- (CKLight*)light{
    return objc_getAssociatedObject(self, &UIWindowLightKey);
}

@end
