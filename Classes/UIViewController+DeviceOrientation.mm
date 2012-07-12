//
//  UIViewController+DeviceOrientation.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "UIViewController+DeviceOrientation.h"
#import "CKRuntime.h"

NSString* CKUIDeviceOrientationWillChangeNotification = @"CKUIDeviceOrientationWillChangeNotification";

@implementation UIViewController (CKDeviceOrientation)

- (void)swizzle_UIViewController_willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    UIViewController* rootViewController = [self.view.window rootViewController];
    if(rootViewController == self){
        NSDictionary* infos = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:toInterfaceOrientation],@"orientation",[NSNumber numberWithFloat:duration],@"duration", nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:CKUIDeviceOrientationWillChangeNotification object:self userInfo:infos];
    }
    [self swizzle_UIViewController_willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

@end



bool swizzle_UIViewController(){
    CKSwizzleSelector([UIViewController class],@selector(willRotateToInterfaceOrientation:duration:),@selector(swizzle_UIViewController_willRotateToInterfaceOrientation:duration:));
    return 1;
}

static bool bo_swizzle_UIViewController = swizzle_UIViewController();