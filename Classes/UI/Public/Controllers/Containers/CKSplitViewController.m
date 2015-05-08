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
    self.automaticallyAdjustInsetsToMatchNavigationControllerTransparency = YES;
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
    
    if(self.automaticallyAdjustInsetsToMatchNavigationControllerTransparency){
        self.view.padding = [self navigationControllerTransparencyInsets];
    }
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

@end
