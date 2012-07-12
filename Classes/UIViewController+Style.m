//
//  UIViewController+Style.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "UIViewController+Style.h"
#import "CKStyleManager.h"
#import "CKStyle+Parsing.h"
#import "CKDebug.h"
#import "CKVersion.h"
#import <objc/runtime.h>


static char UIViewControllerDataDrivenViewsKey;

@interface UIViewController(CKDataDriven)
@property(nonatomic,retain) NSArray* dataDrivenViews;
@end

@implementation UIViewController (CKDataDriven)
@dynamic dataDrivenViews;

- (void)setDataDrivenViews:(NSArray*)dataDrivenViews{
    objc_setAssociatedObject(self, 
                             &UIViewControllerDataDrivenViewsKey,
                             dataDrivenViews,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray*)dataDrivenViews{
    return objc_getAssociatedObject(self, &UIViewControllerDataDrivenViewsKey);
}
@end


@implementation UIViewController (CKStyle)

- (NSMutableDictionary*)controllerStyle{
    NSMutableDictionary* previousControllerStyle = nil;
    NSInteger index = [self.navigationController.viewControllers indexOfObjectIdenticalTo:self];
    if(index != NSNotFound && index >= 1){
        UIViewController* previousViewController = [self.navigationController.viewControllers objectAtIndex:index - 1];
        previousControllerStyle = [[CKStyleManager defaultManager] styleForObject:previousViewController  propertyName:nil];
    }
    
    NSMutableArray* controllerStack = [NSMutableArray array];
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
        previousControllerStyle = previousControllerStyle ? [previousControllerStyle styleForObject:controller  propertyName:nil] : [[CKStyleManager defaultManager] styleForObject:controller  propertyName:nil];
    }
    
    return previousControllerStyle ? [previousControllerStyle styleForObject:self  propertyName:nil] : [[CKStyleManager defaultManager] styleForObject:self  propertyName:nil];
}

- (NSMutableDictionary* )applyStyle{
    NSMutableDictionary* controllerStyle = [self controllerStyle];
    
    NSMutableDictionary* style = [self controllerStyle];
    
#ifdef __IPHONE_6_0
    if([CKOSVersion() floatValue] >= 6){
        [self.view removeConstraints:[self.view constraints]];
    }
#endif
    
    for(UIView* subview in self.dataDrivenViews){
        [subview removeFromSuperview];
    }
    
    NSArray* views = [style instanceOfViews];
    if(views){
        for(UIView* subview in views){
            [self.view addSubview:subview];
        }
    }
    self.dataDrivenViews = views;
    
    
#ifdef __IPHONE_6_0
    if([CKOSVersion() floatValue] >= 6){
        NSMutableDictionary* viewsDictionary = [NSMutableDictionary dictionary];
        [self.view populateViewDictionaryForVisualFormat:viewsDictionary];
                
        NSArray* constraints = [style autoLayoutConstraintsUsingViews:viewsDictionary];
        if(constraints && [constraints count] > 0){
            for(UIView* subview in views){
                [subview setTranslatesAutoresizingMaskIntoConstraints:NO recursive:YES];
            }

            [self.view addConstraints:constraints];
        }
        [self.view setNeedsUpdateConstraints];
    }
#endif
    
    NSMutableSet* appliedStack = [NSMutableSet set];
	[self applySubViewsStyle:controllerStyle appliedStack:appliedStack delegate:nil];

    return controllerStyle;
}

- (NSMutableDictionary*)applyStyleWithParentStyle:(NSMutableDictionary*)style{
    NSMutableDictionary* controllerStyle = style ? [style styleForObject:self  propertyName:nil] : [[CKStyleManager defaultManager] styleForObject:self  propertyName:nil];
	
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
