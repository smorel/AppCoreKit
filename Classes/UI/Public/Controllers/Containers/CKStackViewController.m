//
//  CKStackViewController.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-10-29.
//  Copyright (c) 2013 Wherecloud. All rights reserved.
//

#import "CKStackViewController.h"
#import "CKContainerViewController.h"

@interface CKStackViewController ()

@end

@implementation CKStackViewController

- (void)dealloc{
    [_viewControllers release];
    _viewControllers = nil;
    [super dealloc];
}

+ (CKStackViewController*)stackViewControllerWithViewControllers:(NSArray*)viewControllers{
    return [[[CKStackViewController alloc]initWithViewControllers:viewControllers]autorelease];
}

- (id)initWithViewControllers:(NSArray*)theViewControllers{
    self = [super init];
    self.viewControllers = theViewControllers;
    return self;
}

- (void)setViewControllers:(NSArray *)theViewController{
    for(UIViewController* controller in self.viewControllers){
        if(controller.isViewLoaded){
            if([CKOSVersion() floatValue] < 5){
                [controller viewWillDisappear:NO];
                [controller viewDidDisappear:NO];
            }
            
            [controller.view removeFromSuperview];
            
            [controller setContainerViewController:nil];
        }
    }
    
    _viewControllers = [theViewController copy];
    
    for(UIViewController* controller in self.viewControllers){
        [controller setContainerViewController:self];
    }
    
    if(self.isViewLoaded){
        for(UIViewController* controller in self.viewControllers){
            
            UIView* view = controller.view;
            view.frame = self.view.bounds;
            view.autoresizingMask = UIViewAutoresizingFlexibleSize;
            [self.view addSubview:view];
            
            if([CKOSVersion() floatValue] < 5){
                [controller viewWillAppear:NO];
                [controller viewDidAppear:NO];
            }
            
            [controller setContainerViewController:self];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    for(UIViewController* controller in self.viewControllers){
        
        UIView* view = controller.view;
        if([view superview] != self.view){
            view.frame = self.view.bounds;
            view.autoresizingMask = UIViewAutoresizingFlexibleSize;
            [self.view addSubview:view];
        }
        
        if([CKOSVersion() floatValue] < 5){
            [controller viewWillAppear:NO];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if([CKOSVersion() floatValue] < 5){
        for(UIViewController* controller in self.viewControllers){
            [controller viewDidAppear:animated];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    if([CKOSVersion() floatValue] < 5){
        for(UIViewController* controller in self.viewControllers){
            [controller viewWillDisappear:animated];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    if([CKOSVersion() floatValue] < 5){
        for(UIViewController* controller in self.viewControllers){
            [controller viewDidDisappear:animated];
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


@end
