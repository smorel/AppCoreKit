//
//  CKResourceManager+UIUpdate.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-07-17.
//  Copyright (c) 2013 Wherecloud. All rights reserved.
//

#import "CKResourceManager+UIUpdate.h"
#import "NSObject+Runtime.h"
#import "CKLayoutBoxProtocol.h"
#import "UIView+CKLayout.h"


@implementation CKResourceManager (UIUpdate)

+ (void)refreshView:(UIView*)view viewStack:(NSMutableSet*)viewStack{
    if(view == nil || [viewStack containsObject:view])
        return;
    
    [viewStack addObject:view];
    
    for(UIView* v in [view subviews]){
        [self refreshView:v viewStack:viewStack];
    }
    
    [view invalidateLayout];
    [view setNeedsDisplay];
    [view setNeedsLayout];
}

+ (void)refreshViewController:(UIViewController*)controller controllerStack:(NSMutableSet*)controllerStack viewStack:(NSMutableSet*)viewStack{
    if(controller == nil || [controllerStack containsObject:controller])
        return;
    
    [controllerStack addObject:controller];
    
    [self refreshViewController:[controller modalViewController] controllerStack:controllerStack viewStack:viewStack];
    
    [self refreshView:[controller view] viewStack:viewStack];
    
    if([NSObject isClass:[controller class] kindOfClassNamed:@"CKContainerViewController"]
       || [NSObject isClass:[controller class] kindOfClassNamed:@"CKSplitViewController"]
       || [NSObject isClass:[controller class] kindOfClassNamed:@"UINavigationController"]){
        
        NSArray* controllers = [controller performSelector:@selector(viewControllers)];
        for(UIViewController* c in controllers){
            [self refreshViewController:c controllerStack:controllerStack viewStack:viewStack];
        }
    }
}

+ (void)reloadViewController:(UIViewController*)controller controllerStack:(NSMutableSet*)controllerStack viewStack:(NSMutableSet*)viewStack{
    if(controller == nil || [controllerStack containsObject:controller])
        return;
    
    [controllerStack addObject:controller];
    
    [controller resourceManagerReloadUI];
    [self reloadViewController:[controller modalViewController] controllerStack:controllerStack viewStack:viewStack];
    
  //  [self refreshView:[controller view] viewStack:viewStack];
    
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
    //TODO : if only localization change, we don't need to re-setup all the view controllers !
    
    //we offen modify 1 file at a time :
    //if we could have 1 stylesheet manager per view controller
    //we could reload only this stylesheet (with imports/dependencies (color palettes) ...) and this view controller !
    //we could store references to images too and reload only the controllers that loaded particular images.
    //we could auto load the controller's class named .stylesheet file at launch.
    
    NSLog(@"Reloading UI");
    NSMutableSet* controllerStack = [NSMutableSet set];
    NSMutableSet* viewStack = [NSMutableSet set];
    NSArray* windows = [[UIApplication sharedApplication]windows];
    for(UIWindow* window in windows){
        UIViewController* c = [window rootViewController];
        [self reloadViewController:c controllerStack:controllerStack viewStack:viewStack];
       // [self refreshView:window viewStack:viewStack];
    }
}

+ (void)refreshUI{
    [self reloadUI];
    
    return;
    
    //tried to optimize but very few elements get updated.
    NSLog(@"Refreshing UI");
    NSMutableSet* controllerStack = [NSMutableSet set];
    NSMutableSet* viewStack = [NSMutableSet set];
    NSArray* windows = [[UIApplication sharedApplication]windows];
    for(UIWindow* window in windows){
        UIViewController* c = [window rootViewController];
        [self refreshViewController:c controllerStack:controllerStack viewStack:viewStack];
        [self refreshView:window viewStack:viewStack];
    }
}

@end



@implementation UIViewController (CKResourceManager)

- (void)resourceManagerReloadUI{
    //self.title = self.title;
    //if([self respondsToSelector:@selector(reload)]){
    //    [self performSelector:@selector(reload)];
    //}
    
    if(![self isViewLoaded] || [self.view window] == nil)
        return;
    
    [self viewWillDisappear:NO];
    [self viewDidDisappear:NO];
    [self viewWillAppear:NO];
    [self viewDidAppear:NO];
}

@end