//
//  UINavigationController+Style.m
//  AppCoreKit
//
//  Created by Guillaume Campagna.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "UINavigationController+Style.h"
#import "UIViewController+Style.h"
#import <QuartzCore/QuartzCore.h>
#import "CKRuntime.h"
#import "CKStyleManager.h"

NSString* UINavigationControllerWillDisplayToolbar = @"UINavigationControllerWillDisplayToolbar";
NSString* UINavigationControllerWillHideToolbar = @"UINavigationControllerWillHideToolbar";

bool swizzle_UINavigationControllerStyle();

@implementation UINavigationController (Style)

- (void)UINavigationControllerStyle_setToolbarHidden:(BOOL)hidden animated:(BOOL)animated {
    [self UINavigationControllerStyle_setToolbarHidden:hidden animated:animated];
    
    if (hidden == NO) {
        //[CATransaction begin];
        //[CATransaction 
        // setValue: [NSNumber numberWithBool: YES]
         //forKey: kCATransactionDisableActions];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:UINavigationControllerWillDisplayToolbar object:self];
        
        NSMutableDictionary* controllerStyle = [self.topViewController controllerStyle];
        
        NSMutableDictionary* navControllerStyle = [controllerStyle styleForObject:self  propertyName:@"navigationController"];
        [self.toolbar applyStyle:navControllerStyle propertyName:@"toolbar"];
                
       // [CATransaction commit];  
    }else{
        [[NSNotificationCenter defaultCenter]postNotificationName:UINavigationControllerWillHideToolbar object:self];
    }
}

- (void)UINavigationControllerStyle_setToolbarHidden:(BOOL)hidden{
    [self UINavigationControllerStyle_setToolbarHidden:hidden];
    
    if (hidden == NO) {
        //[CATransaction begin];
        //[CATransaction 
        // setValue: [NSNumber numberWithBool: YES]
        //forKey: kCATransactionDisableActions];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:UINavigationControllerWillDisplayToolbar object:self];
        
        NSMutableDictionary* controllerStyle = [self.topViewController controllerStyle];
        
        NSMutableDictionary* navControllerStyle = [controllerStyle styleForObject:self  propertyName:@"navigationController"];
        [self.toolbar applyStyle:navControllerStyle propertyName:@"toolbar"];
        
        // [CATransaction commit];  
    }else{
        [[NSNotificationCenter defaultCenter]postNotificationName:UINavigationControllerWillHideToolbar object:self];
    }

}

@end

bool swizzle_UINavigationControllerStyle(){
    CKSwizzleSelector([UINavigationController class],@selector(setToolbarHidden:animated:),@selector(UINavigationControllerStyle_setToolbarHidden:animated:));
    CKSwizzleSelector([UINavigationController class],@selector(setToolbarHidden:),@selector(UINavigationControllerStyle_setToolbarHidden:));
    return 1;
}

static bool bo_swizzle_UINavigationController = swizzle_UINavigationControllerStyle();
