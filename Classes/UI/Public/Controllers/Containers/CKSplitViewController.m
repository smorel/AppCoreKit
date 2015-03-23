//
//  CKSplitViewController.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import "CKSplitViewController.h"
#import "CKContainerViewController.h"
#import "NSObject+Bindings.h"
#import "CKVersion.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import "NSObject+Invocation.h"
#import "UIView+Positioning.h"
#import "UIView+Name.h"
#import "UIView+CKLayout.h"
#import "CKVerticalBoxLayout.h"
#import "CKHorizontalBoxLayout.h"


@interface CKSplitViewController()
@end


@implementation CKSplitViewController
@synthesize viewControllers = _viewControllers;
@synthesize orientation;


- (void)postInit{
    [super postInit];
    self.orientation = CKSplitViewOrientationVertical;
    self.automaticallyAdjustInsetsToMatchNavigationControllerTransparency = NO;
}

- (void)dealloc{
    [_viewControllers release];
    _viewControllers = nil;
    [super dealloc];
}

+ (CKSplitViewController*)splitViewControllerWithOrientation:(CKSplitViewOrientation)orientation{
    CKSplitViewController* controller = [CKSplitViewController controller];
    controller.orientation = orientation;
    return controller;
}

+ (CKSplitViewController*)splitViewControllerWithViewControllers:(NSArray*)viewControllers{
    return [[[CKSplitViewController alloc]initWithViewControllers:viewControllers]autorelease];
}

+ (CKSplitViewController*)splitViewControllerWithViewControllers:(NSArray*)viewControllers orientation:(CKSplitViewOrientation)orientation{
    return [[[CKSplitViewController alloc]initWithViewControllers:viewControllers orientation:orientation]autorelease];
}

- (id)initWithViewControllers:(NSArray*)theViewControllers{
    self = [super init];
    self.viewControllers = theViewControllers;
    return self;
}

- (id)initWithViewControllers:(NSArray*)viewControllers orientation:(CKSplitViewOrientation)theorientation{
    self = [self initWithViewControllers:viewControllers];
    self.orientation = theorientation;
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    id<CKLayoutBoxProtocol> layout = nil;
    switch(self.orientation){
        case CKSplitViewOrientationVertical:{
            layout = [[[CKVerticalBoxLayout alloc]init]autorelease];
            break;
        }
        case CKSplitViewOrientationHorizontal:{
            layout = [[[CKHorizontalBoxLayout alloc]init]autorelease];
            break;
        }
    }
    
    layout.name = @"SplitViewLayout";
    
    if(self.viewControllers){
        layout.layoutBoxes = [CKArrayCollection collectionWithObjectsFromArray:self.viewControllers];
    }

    self.view.layoutBoxes = [CKArrayCollection collectionWithObjectsFromArray:@[layout]];
}

- (void)setViewControllers:(NSArray *)viewControllers {
    id<CKLayoutBoxProtocol> layout = [self.view layoutWithName:@"SplitViewLayout"];
    if(layout){
        [layout removeAllLayoutBoxes];
    }
    
    [_viewControllers release];
    _viewControllers = [viewControllers retain];
    
    if(!viewControllers)
        return;
    
    if(layout){
        layout.layoutBoxes = [CKArrayCollection collectionWithObjectsFromArray:viewControllers];
    }
}

- (void)resourceManagerReloadUI{
    [self reapplyStylesheet];
    //do not update childrens as it's done by the ResourceManager itself
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    for(UIViewController* controller in self.viewControllers){
        if([controller hasPropertyNamed:@"state"]){
            if(controller.state != CKViewControllerStateDidAppear || controller.state != CKViewControllerStateWillAppear){
                [controller viewWillAppear:animated];
            }
        }
    }
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    for(UIViewController* controller in self.viewControllers){
        if([controller hasPropertyNamed:@"state"]){
            if(controller.state != CKViewControllerStateDidAppear){
                [controller viewDidAppear:animated];
            }
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    for(UIViewController* controller in self.viewControllers){
        if([controller hasPropertyNamed:@"state"]){
            if(controller.state != CKViewControllerStateWillDisappear){
                [controller viewWillDisappear:animated];
            }
        }
    }
}


- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    for(UIViewController* controller in self.viewControllers){
        if([controller hasPropertyNamed:@"state"]){
            if(controller.state != CKViewControllerStateDidDisappear){
                [controller viewDidDisappear:animated];
            }
        }
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    if([CKOSVersion() floatValue] < 5){
        for(UIViewController* controller in _viewControllers){
            [controller willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
        }
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    if([CKOSVersion() floatValue] < 5){
        for(UIViewController* controller in _viewControllers){
            [controller didRotateFromInterfaceOrientation:fromInterfaceOrientation];
        }
    }
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration{
    [super willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:duration];
    
    if([CKOSVersion() floatValue] < 5){
        for(UIViewController* controller in _viewControllers){
            [controller  willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:duration];
        }
    }
}

/*
- (BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers{ return NO; }
- (BOOL)shouldAutomaticallyForwardRotationMethods{ return NO; }
- (BOOL)shouldAutomaticallyForwardAppearanceMethods{ return NO; }
*/

@end
