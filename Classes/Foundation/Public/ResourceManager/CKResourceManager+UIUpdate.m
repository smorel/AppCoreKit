//
//  CKResourceManager+UIUpdate.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-07-17.
//  Copyright (c) 2013 Wherecloud. All rights reserved.
//

#import "CKResourceManager+UIUpdate.h"
#import "NSObject+Runtime.h"


@implementation CKResourceManager (UIUpdate)


+ (void)reloadViewController:(UIViewController*)controller controllerStack:(NSMutableSet*)controllerStack viewStack:(NSMutableSet*)viewStack{
    if(controller == nil || [controllerStack containsObject:controller])
        return;
    
    [controllerStack addObject:controller];
    
    [controller resourceManagerReloadUI];
    
    [self reloadViewController:[controller modalViewController] controllerStack:controllerStack viewStack:viewStack];
    
    
    if([NSObject isClass:[controller class] kindOfClassNamed:@"CKContainerViewController"]
       || [NSObject isClass:[controller class] kindOfClassNamed:@"CKSplitViewController"]
       || [NSObject isClass:[controller class] kindOfClassNamed:@"UINavigationController"]){
        
        NSArray* controllers = [controller performSelector:@selector(viewControllers)];
        for(UIViewController* c in controllers){
            [self reloadViewController:c controllerStack:controllerStack viewStack:viewStack];
        }
    }
}

+ (void)reloadUI{
    NSMutableSet* controllerStack = [NSMutableSet set];
    NSMutableSet* viewStack = [NSMutableSet set];
    NSArray* windows = [[UIApplication sharedApplication]windows];
    for(UIWindow* window in windows){
        UIViewController* c = [window rootViewController];
        [self reloadViewController:c controllerStack:controllerStack viewStack:viewStack];
    }
    
    [CKResourceManager setHudTitle:nil];
}

@end



@implementation UIViewController (CKResourceManager)

- (void)resourceManagerReloadUI{
    
    static dispatch_queue_t reloadQueue = nil;
    if(!reloadQueue){
        reloadQueue = dispatch_queue_create("com.wherecloud.CKStyleManager.reload", 0);
    }
    
    dispatch_async(reloadQueue, ^{
        NSString* name = nil;
        if([self respondsToSelector:@selector(name)]){
            name = [self performSelector:@selector(name)];
        }
        NSString* hudTitle = name ? [NSString stringWithFormat:@"Reloading '%@ : %@'",[self class],name] : [NSString stringWithFormat:@"Reloading '%@'",[self class]];
        [CKResourceManager setHudTitle:hudTitle];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(![self isViewLoaded] || [self.view window] == nil)
                return;
            
            [self invalidateStylesheetForAllViews];
            [self viewWillDisappear:NO];
            [self viewDidDisappear:NO];
            [self viewWillAppear:NO];
            [self viewDidAppear:NO];
            
            [CKResourceManager setHudTitle:nil];
            
        });
    });
}

- (void)invalidateStylesheetForAllViews{
    [self invalidateStylesheetForView:self.view];
    [self invalidateStylesheetForView:self.navigationItem.titleView];
    [self invalidateStylesheetForView:self.navigationItem.leftBarButtonItem.customView];
    [self invalidateStylesheetForView:self.navigationItem.rightBarButtonItem.customView];
    [self invalidateStylesheetForView:self.navigationController.navigationBar];
    [self invalidateStylesheetForView:self.navigationController.toolbar];
}

- (void)invalidateStylesheetForView:(UIView*)view{
    if(!view)
        return;
    
    if([view respondsToSelector:@selector(setAppliedStyle:)]){
        [view performSelector:@selector(setAppliedStyle:) withObject:nil];
    }
    
    for(UIView* v in view.subviews){
        [self invalidateStylesheetForView:v];
    }
}

@end