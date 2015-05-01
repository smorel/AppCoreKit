//
//  CKLightMotionEffect.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-30.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKLightMotionEffect.h"

@interface CKLight()
@property (nonatomic, assign) CGPoint motionEffectOffset;
@end


@interface CKLightMotionEffect()
@property(nonatomic,assign) UIOffset calibration;
@end



@implementation CKLightMotionEffect

- (id)init{
    self = [super init];
    self.scale = CGPointMake(1,1);
    return self;
}

- (NSDictionary *)keyPathsAndRelativeValuesForViewerOffset:(UIOffset)viewerOffset
{
    if(self.calibration.horizontal == 0 && self.calibration.vertical == 0){
        self.calibration = viewerOffset;
        return @{};
    }
    
    CGPoint p = CGPointMake(-self.scale.x * (viewerOffset.horizontal - self.calibration.horizontal ),
                            -self.scale.y * (viewerOffset.vertical - self.calibration.vertical ));
    self.light.motionEffectOffset = p;
    
    return @{};
}

- (CKLight*)light{
    return [CKLight sharedInstance];
}


@end

