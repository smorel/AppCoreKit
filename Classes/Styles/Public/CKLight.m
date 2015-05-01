//
//  UIWindow+Light.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-30.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKLight.h"
#import "CKLightMotionEffect.h"

NSString* CKLightDidChangeNotification = @"CKLightDidChangeNotification";

@interface CKLight()
@property (nonatomic, assign) CGPoint motionEffectOffset;
@property (nonatomic, retain) CKLightMotionEffect* motionEffect;
@end

@implementation CKLight

- (instancetype)init{
    self = [super init];
    
    self.origin = CGPointMake(0,0);
    self.intensity = 20;
    self.end = CGPointMake(0.5,0.5);
    self.motionEffectScale = CGPointMake(1,1);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]postNotificationName:CKLightDidChangeNotification object:self];
    });
    
    return self;
}

- (void)setOrigin:(CGPoint)lightOrigin{
    if(CGPointEqualToPoint(_origin, lightOrigin))
        return;
    
    _origin = lightOrigin;
    [[NSNotificationCenter defaultCenter]postNotificationName:CKLightDidChangeNotification object:self];
}

- (void)setIntensity:(CGFloat)lightIntensity{
    if(_intensity == lightIntensity)
        return;
    
    _intensity = lightIntensity;
    [[NSNotificationCenter defaultCenter]postNotificationName:CKLightDidChangeNotification object:self];
}

- (void)setEnd:(CGPoint)lightEnd{
    if(CGPointEqualToPoint(_end, lightEnd))
        return;
    
    _end = lightEnd;
    [[NSNotificationCenter defaultCenter]postNotificationName:CKLightDidChangeNotification object:self];
}

- (void)setMotionEffectOffset:(CGPoint)motionEffectOffset{
    if(CGPointEqualToPoint(_motionEffectOffset, motionEffectOffset))
        return;
    
    _motionEffectOffset = motionEffectOffset;
    [[NSNotificationCenter defaultCenter]postNotificationName:CKLightDidChangeNotification object:self];
}

- (void)setMotionEffectEnabled:(BOOL)motionEffectEnabled{
    if(motionEffectEnabled){
        if(self.motionEffect)
            return;
        
        self.motionEffect = [[[CKLightMotionEffect alloc]init]autorelease];
        for(UIWindow* window in [[UIApplication sharedApplication]windows]){
            [window addMotionEffect:self.motionEffect];
        }
    }else{
        if(!self.motionEffect)
            return;
        
        for(UIWindow* window in [[UIApplication sharedApplication]windows]){
            [window removeMotionEffect:self.motionEffect];
        }
        self.motionEffect = nil;
    }
}

- (BOOL)motionEffectEnabled{
    return self.motionEffect != nil;
}

- (void)setMotionEffectScale:(CGPoint)motionEffectScale{
    _motionEffectScale = motionEffectScale;
    if(self.motionEffect){
        self.motionEffect.scale = motionEffectScale;
    }
}

@end
