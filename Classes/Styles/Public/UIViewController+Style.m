//
//  UIViewController+Style.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "UIViewController+Style.h"
#import "UIView+Style.h"
#import "CKStyleManager.h"
#import "CKStyle+Parsing.h"
#import "CKDebug.h"
#import "CKVersion.h"
#import <objc/runtime.h>
#import "CKResourceManager.h"
#import "CKWeakRef.h"
#import "CKRuntime.h"


static char UIViewControllerStyleManagerKey;
static char UIViewControllerStylesheetFileNameKey;

@implementation UIViewController (CKStyle)
@dynamic stylesheetFileName, styleManager;

- (BOOL)isLayoutDefinedInStylesheet{
    NSMutableDictionary* style = [self controllerStyle];
    if([style containsObjectForKey:@"layoutBoxes"])
        return YES;
    
    NSMutableDictionary* viewDictionary = [style objectForKey:@"view"];
    if([viewDictionary containsObjectForKey:@"layoutBoxes"])
        return YES;
    
    return NO;
}

- (void)setStylesheetFileName:(NSString *)stylesheetFileName{
    objc_setAssociatedObject(self,
                             &UIViewControllerStylesheetFileNameKey,
                             stylesheetFileName,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString*)stylesheetFileName{
    return objc_getAssociatedObject(self, &UIViewControllerStylesheetFileNameKey);
}

- (void)setStyleManager:(CKStyleManager *)styleManager{
    objc_setAssociatedObject(self,
                             &UIViewControllerStyleManagerKey,
                             styleManager,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CKStyleManager*)styleManager{
    CKStyleManager* manager = objc_getAssociatedObject(self, &UIViewControllerStyleManagerKey);
    if(manager)
        return manager;
    
    //BACKWARD COMPATIBILITY :
    //check if default bundle has a style for this controller.
    //if so, uses the default manager.
    NSMutableDictionary* styleInDefaultManager = [[CKStyleManager defaultManager] styleForObject:self  propertyName:nil];
    if(styleInDefaultManager && ![styleInDefaultManager isEmpty]){
        [self setStyleManager:[CKStyleManager defaultManager]];
        return [CKStyleManager defaultManager];
    }
    
    //TODO : register on updates for this file as it can be created from dropbox ...
    //If this file or one of its dependencies refreshes, only update this view controller.
    
    if(self.stylesheetFileName){
        manager = [CKStyleManager styleManagerWithContentOfFileNamed:self.stylesheetFileName];
    }else{
        //Hierarchically search .style file with class name of super class.
        Class c = [self class];
        NSString* filePath = [CKResourceManager pathForResource:[c description] ofType:@".style"];
        
        while(!filePath && c){
            c = [c superclass];
            if(c){
                filePath = [CKResourceManager pathForResource:[c description] ofType:@".style"];
            }
        }
        
        if(!filePath){
            UIViewController* containerViewController = nil;
            if([self respondsToSelector:@selector(containerViewController)]){
                containerViewController = [self performSelector:@selector(containerViewController)];
            }
            
            if(containerViewController){
                self.stylesheetFileName = containerViewController.stylesheetFileName;
                manager = [containerViewController styleManager];
            }else{
                
                NSMutableArray* controllerStack = [NSMutableArray array];
                
                NSInteger index = [self.navigationController.viewControllers indexOfObjectIdenticalTo:self];
                if(index != NSNotFound && index >= 1){
                    UIViewController* previousViewController = [self.navigationController.viewControllers objectAtIndex:index - 1];
                    [controllerStack addObject:previousViewController];
                }
                
                UIViewController* c = self;
                while(c){
                    if([c respondsToSelector:@selector(containerViewController)]){
                        c = [c performSelector:@selector(containerViewController)];
                        if(c){
                            [controllerStack insertObject:c atIndex:0];
                        }
                    }
                    else{
                        c = nil;
                    }
                }
                
                if([controllerStack count] > 0){
                    manager = [[controllerStack objectAtIndex:0]styleManager];
                }else{
                    manager = [CKStyleManager defaultManager];
                }
            }
        }else{
            self.stylesheetFileName = [c description];
            manager = [CKStyleManager styleManagerWithContentOfFileNamed:[c description]];
        }
    }
    
    [self setStyleManager:manager ];
    return manager;
}

- (NSMutableDictionary*)controllerStyle{
    //First try to get a style in its own stylemanager
    NSMutableDictionary* s = [[self styleManager] styleForObject:self  propertyName:nil];
    if(s && ![s isEmpty]){
        return s;
    }
    
    //Returns the more specific style taking care of navigation and container hierarchy
    NSMutableArray* controllerStack = [NSMutableArray array];
    
    NSInteger index = [self.navigationController.viewControllers indexOfObjectIdenticalTo:self];
    if(index != NSNotFound && index >= 1){
        UIViewController* previousViewController = [self.navigationController.viewControllers objectAtIndex:index - 1];
        [controllerStack addObject:previousViewController];
    }
    
    UIViewController* c = self;
    while(c){
        if([c respondsToSelector:@selector(containerViewController)]){
            c = [c performSelector:@selector(containerViewController)];
            if(c){
                [controllerStack insertObject:c atIndex:0];
            }
        }
        else{
            c = nil;
        }
    }
    
    for(UIViewController* controller in controllerStack){
        NSMutableDictionary* styleInContainer = [controller.stylesheet styleForObject:self propertyName:nil];
        if(styleInContainer && ![styleInContainer isEmpty]){
            return styleInContainer;
        }
    }
    
    return nil;
}

- (NSMutableDictionary* )applyStyle{
    NSMutableDictionary* controllerStyle = [self controllerStyle];
    
    NSMutableSet* appliedStack = [NSMutableSet set];
	[self applySubViewsStyle:controllerStyle appliedStack:appliedStack delegate:nil];

    return controllerStyle;
}

- (NSMutableDictionary*)applyStyleWithParentStyle:(NSMutableDictionary*)style{
    NSMutableDictionary* controllerStyle = style ? [style styleForObject:self  propertyName:nil] : [[self styleManager] styleForObject:self  propertyName:nil];
	
    if([CKStyleManager logEnabled]){
        if([controllerStyle isEmpty]){
            CKDebugLog(@"did not find style for controller %@",self);
        }
        else{
            CKDebugLog(@"found style for controller %@",self);
        }
    }
    
	NSMutableSet* appliedStack = [NSMutableSet set];
	[self applySubViewsStyle:controllerStyle appliedStack:appliedStack delegate:nil];
    
    return controllerStyle;
}

@end


#pragma mark - UIViewController Additions
@interface UIViewController ()
@property (nonatomic,retain)CKWeakRef* containerViewControllerRef;
@end

@implementation UIViewController (CKContainerViewController)

static char UIViewControllerNameKey;


- (void)setName:(NSString *)name{
    objc_setAssociatedObject(self, &UIViewControllerNameKey, name, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString*)name{
    return objc_getAssociatedObject(self, &UIViewControllerNameKey);
}

static char CKViewControllerContainerViewControllerKey;

- (void)setContainerViewControllerRef:(CKWeakRef *)ref {
    objc_setAssociatedObject(self,
                             &CKViewControllerContainerViewControllerKey,
                             ref,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CKWeakRef *)containerViewControllerRef {
    return objc_getAssociatedObject(self, &CKViewControllerContainerViewControllerKey);
}



- (void)setContainerViewController:(UIViewController *)viewController {
    CKWeakRef* ref = self.containerViewControllerRef;
    if(!ref){
        ref = [CKWeakRef weakRefWithObject:viewController];
        objc_setAssociatedObject(self,
                                 &CKViewControllerContainerViewControllerKey,
                                 ref,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    else{
        ref.object = viewController;
    }
    
    
    if([CKOSVersion() floatValue] >= 5){
        if(viewController == nil){
            [self removeFromParentViewController];
        }else{
            Class CKReusableViewControllerClass = NSClassFromString(@"CKReusableViewController");
            if(/*[self isKindOfClass:CKReusableViewControllerClass] && */ [viewController isKindOfClass:CKReusableViewControllerClass])
                return;
            
            [viewController addChildViewController:self];
        }
    }
}

- (UIViewController *)containerViewController {
    CKWeakRef* ref = self.containerViewControllerRef;
    return [ref object];
}

- (UIViewController*)containerViewControllerOfClass:(Class)type{
    UIViewController* controller = [self containerViewController];
    while(controller){
        if([controller isKindOfClass:type])
            return controller;
        controller = [controller containerViewController];
    }
    return nil;
}


- (UIViewController*)containerViewControllerConformsToProtocol:(Protocol*)protocol{
    UIViewController* controller = [self containerViewController];
    while(controller){
        if([controller conformsToProtocol:protocol])
            return controller;
        controller = [controller containerViewController];
    }
    return nil;
}

- (UINavigationController*)appcorekit_navigationController{
    if(self.containerViewController == nil)
        return [self appcorekit_navigationController];
    
    UIViewController* controller = [self containerViewController];
    while(controller){
        if(controller.navigationController)
            return controller.navigationController;
        controller = [controller containerViewController];
    }
    return nil;
}

+ (void)load{
    CKSwizzleSelector([UIViewController class], @selector(navigationController), @selector(appcorekit_navigationController));
}

@end