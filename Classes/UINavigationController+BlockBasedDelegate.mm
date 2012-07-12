//
//  UINavigationController+BlockBasedDelegate.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2012 WhereCloud Inc. All rights reserved.
//

#import "UINavigationController+BlockBasedDelegate.h"
#import <objc/runtime.h>
#import "CKRuntime.h"

bool swizzle_UINavigationController();

static char UINavigationControllerWillPushViewControllerBlockBlockKey;
static char UINavigationControllerWillPopViewControllerBlockBlockKey;
static char UINavigationControllerDidPushViewControllerBlockBlockKey;
static char UINavigationControllerDidPopViewControllerBlockBlockKey;

@implementation UINavigationController (CKBlockBasedDelegate)
@dynamic willPushViewControllerBlock;
@dynamic willPopViewControllerBlock;
@dynamic didPushViewControllerBlock;
@dynamic didPopViewControllerBlock;

- (void)setWillPopViewControllerBlock:(UINavigationControllerBlock)block{
    objc_setAssociatedObject(self, 
                             &UINavigationControllerWillPopViewControllerBlockBlockKey,
                             block,
                             OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (UINavigationControllerBlock)willPopViewControllerBlock{
    return objc_getAssociatedObject(self, &UINavigationControllerWillPopViewControllerBlockBlockKey);
}

- (void)setWillPushViewControllerBlock:(UINavigationControllerBlock)block{
    objc_setAssociatedObject(self, 
                             &UINavigationControllerWillPushViewControllerBlockBlockKey,
                             block,
                             OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (UINavigationControllerBlock)willPushViewControllerBlock{
    return objc_getAssociatedObject(self, &UINavigationControllerWillPushViewControllerBlockBlockKey);
}

- (void)setDidPopViewControllerBlock:(UINavigationControllerBlock)block{
    objc_setAssociatedObject(self, 
                             &UINavigationControllerDidPopViewControllerBlockBlockKey,
                             block,
                             OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (UINavigationControllerBlock)didPopViewControllerBlock{
    return objc_getAssociatedObject(self, &UINavigationControllerDidPopViewControllerBlockBlockKey);
}

- (void)setDidPushViewControllerBlock:(UINavigationControllerBlock)block{
    objc_setAssociatedObject(self, 
                             &UINavigationControllerDidPushViewControllerBlockBlockKey,
                             block,
                             OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (UINavigationControllerBlock)didPushViewControllerBlock{
    return objc_getAssociatedObject(self, &UINavigationControllerDidPushViewControllerBlockBlockKey);
}

- (void)CKBlockBasedDelegate_pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if([self willPushViewControllerBlock]){
        [self willPushViewControllerBlock](self,viewController,animated);
    }
    [self CKBlockBasedDelegate_pushViewController:viewController animated:animated];
    if([self didPushViewControllerBlock]){
        [self didPushViewControllerBlock](self,viewController,animated);
    }
}

- (UIViewController *)CKBlockBasedDelegate_popViewControllerAnimated:(BOOL)animated{
    if([self willPopViewControllerBlock]){
        [self willPopViewControllerBlock](self,[self topViewController],animated);
    }
    UIViewController* controller = [self CKBlockBasedDelegate_popViewControllerAnimated:animated];
    if([self didPopViewControllerBlock]){
        [self didPopViewControllerBlock](self,[self topViewController],animated);
    }
    return controller;
}

- (NSArray *)CKBlockBasedDelegate_popToViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if([self willPopViewControllerBlock]){
        [self willPopViewControllerBlock](self,[self topViewController],animated);
    }
    NSArray* result = [self CKBlockBasedDelegate_popToViewController:viewController animated:animated];
    if([self didPopViewControllerBlock]){
        [self didPopViewControllerBlock](self,[self topViewController],animated);
    }
    return result;
}

- (NSArray *)CKBlockBasedDelegate_popToRootViewControllerAnimated:(BOOL)animated{
    if([self willPopViewControllerBlock]){
        [self willPopViewControllerBlock](self,[self topViewController],animated);
    }
    NSArray* result =  [self CKBlockBasedDelegate_popToRootViewControllerAnimated:animated];
    if([self didPopViewControllerBlock]){
        [self didPopViewControllerBlock](self,[self topViewController],animated);
    }
    return result;
}

//This avoid keyboard to stay on screen in controllers presented as UIModalPresentationFormSheet 
- (BOOL)disablesAutomaticKeyboardDismissal {
    return NO;
}

@end


bool swizzle_UINavigationController(){
    CKSwizzleSelector([UINavigationController class],@selector(pushViewController:animated:),@selector(CKBlockBasedDelegate_pushViewController:animated:));
    CKSwizzleSelector([UINavigationController class],@selector(popViewControllerAnimated:),@selector(CKBlockBasedDelegate_popViewControllerAnimated:));
    CKSwizzleSelector([UINavigationController class],@selector(popToViewController:animated:),@selector(CKBlockBasedDelegate_popToViewController:animated:));
    CKSwizzleSelector([UINavigationController class],@selector(popToRootViewControllerAnimated:),@selector(CKBlockBasedDelegate_popToRootViewControllerAnimated:));
    return 1;
}

static bool bo_swizzle_UINavigationController = swizzle_UINavigationController();
