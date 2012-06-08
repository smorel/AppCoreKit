//
//  UINavigationController+Style.m
//  CloudKit
//
//  Created by Guillaume Campagna on 12-05-24.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "UINavigationController+Style.h"
#import <QuartzCore/QuartzCore.h>
#import "CloudKit.h"


bool swizzle_UINavigationControllerStyle();

@implementation UINavigationController (Style)

- (void)UINavigationControllerStyle_setToolbarHidden:(BOOL)hidden animated:(BOOL)animated {
    [self UINavigationControllerStyle_setToolbarHidden:hidden animated:animated];
    
    if (hidden == NO) {
        [CATransaction begin];
        [CATransaction 
         setValue: [NSNumber numberWithBool: YES]
         forKey: kCATransactionDisableActions];
        
        NSMutableDictionary* controllerStyle = [self.topViewController controllerStyle];
        
        NSMutableDictionary* navControllerStyle = [controllerStyle styleForObject:self  propertyName:@"navigationController"];
        [self.toolbar applyStyle:navControllerStyle propertyName:@"toolbar"];
                
        [CATransaction commit];  
    }
}

@end

bool swizzle_UINavigationControllerStyle(){
    CKSwizzleSelector([UINavigationController class],@selector(setToolbarHidden:animated:),@selector(UINavigationControllerStyle_setToolbarHidden:animated:));
    return 1;
}

static bool bo_swizzle_UINavigationController = swizzle_UINavigationControllerStyle();
