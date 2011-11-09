//
//  CKPopoverController.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-10.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKPopoverController.h"
#import "CKNSObject+Bindings.h"

@implementation CKPopoverController
@synthesize autoDismissOnInterfaceOrientation;

- (void)postInit{
    self.autoDismissOnInterfaceOrientation = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (id)initWithContentViewController:(UIViewController *)viewController{
    self = [super initWithContentViewController:viewController];
    [self postInit];
    return self;
}

- (id)initWithContentViewController:(UIViewController *)viewController contentSize:(CGSize)contentSize{
    viewController.contentSizeForViewInPopover = contentSize;
    self = [super initWithContentViewController:viewController];
    [self postInit];
    return self;
}

- (id)initWithContentViewController:(UIViewController *)viewController inNavigationController:(BOOL)navigationController{
    UIViewController* content = viewController;
    if(navigationController){
        content = [[[UINavigationController alloc]initWithRootViewController:viewController]autorelease];
    }
    self = [super initWithContentViewController:content];
    [self postInit];
    return self;
}

- (id)initWithContentViewController:(UIViewController *)viewController contentSize:(CGSize)contentSize inNavigationController:(BOOL)navigationController{
    viewController.contentSizeForViewInPopover = contentSize;
    UIViewController* content = viewController;
    if(navigationController){
        content = [[[UINavigationController alloc]initWithRootViewController:viewController]autorelease];
    }
    self = [super initWithContentViewController:content];
    [self postInit];
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [self clearBindingsContext];
    [super dealloc];
}

- (void)presentPopoverFromRect:(CGRect)rect inView:(UIView *)view permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated{
    self.delegate = self;
    [self retain];
    [super presentPopoverFromRect:rect inView:view permittedArrowDirections:arrowDirections animated:animated];
}

- (void)presentPopoverFromBarButtonItem:(UIBarButtonItem *)item permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated{
    self.delegate = self;
    [self retain];
    [super presentPopoverFromBarButtonItem:item permittedArrowDirections:arrowDirections animated:animated];
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController{
    return YES;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    [self autorelease];
}

- (void)orientationChanged:(NSNotification*)notif{
    if(autoDismissOnInterfaceOrientation){
        [self dismissPopoverAnimated:YES];
    }
}

@end
