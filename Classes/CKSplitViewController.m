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

@implementation CKSplitViewConstraints
@synthesize type,size;

- (void)postInit{
    [super postInit];
    self.type = CKSplitViewConstraintsTypeFlexibleSize;
    self.size = -1;
}

+ (CKSplitViewConstraints*)constraints{
    CKSplitViewConstraints* constraints = [[[CKSplitViewConstraints alloc]init]autorelease];
    return constraints;
}

- (void)typeExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"CKSplitViewConstraintsType", 
                                                 CKSplitViewConstraintsTypeFlexibleSize,
                                                 CKSplitViewConstraintsTypeFixedSizeInPixels,
                                                 CKSplitViewConstraintsTypeFixedSizeRatio);
}

@end

@interface CKSplitView()
@property (nonatomic,retain)NSMutableArray* controllerViews;
@property (nonatomic, copy) void (^addOrRemoveBlock)(UIView* view, BOOL removing);
@end

@implementation CKSplitView
@synthesize delegate;
@synthesize controllerViews = _controllerViews;
@synthesize orientation;
@synthesize addOrRemoveBlock;

- (void)dealloc{
    [NSObject removeAllBindingsForContext:[NSString stringWithFormat:@"CKSplitView<%p>",self]];
    [_controllerViews release];
    _controllerViews = nil;
    self.addOrRemoveBlock = nil;
    [super dealloc];
}

- (void)reloadData{
    [NSObject beginBindingsContext:[NSString stringWithFormat:@"CKSplitView<%p>",self] policy:CKBindingsContextPolicyRemovePreviousBindings];
    NSInteger count = self.delegate ? [delegate numberOfViewsInSplitView:self] : 0;
    if(count && !_controllerViews){
        self.controllerViews = [NSMutableArray array];
    }
    else{
        [self.controllerViews removeAllObjects];
    }
    
    for(int i =0;i<count;++i){
        UIView* view = [self.delegate splitView:self viewAtIndex:i];
        __block CKSplitView* bself = self;
        CKSplitViewConstraints* constraints = [self.delegate splitView:self constraintsForViewAtIndex:i];
        [constraints bind:@"type" withBlock:^(id value) {
            [bself setNeedsLayout];
        }];
        [constraints bind:@"size" withBlock:^(id value) {
            [bself setNeedsLayout];
        }];
        
        [self addSubview:view];
        [self.controllerViews addObject:view];
    }
    [NSObject endBindingsContext];
    
    [self layoutSubviews];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat fixedSpace = 0;
    NSInteger numberOfFlexibleViews = 0;
    
    int i =0;
    for(UIView* view in self.controllerViews){
        CKSplitViewConstraints* constraints = [self.delegate splitView:self constraintsForViewAtIndex:i];
        switch(self.orientation){
            case CKSplitViewOrientationHorizontal:{
                switch(constraints.type){
                    case CKSplitViewConstraintsTypeFixedSizeInPixels:{
                        fixedSpace += constraints.size;
                        break;
                    }
                    case CKSplitViewConstraintsTypeFixedSizeRatio:{
                        fixedSpace += (self.bounds.size.width * constraints.size);
                        break;
                    }
                    case CKSplitViewConstraintsTypeFlexibleSize:{
                        ++numberOfFlexibleViews;
                        break;
                    }
                }
                break;
            }
            case CKSplitViewOrientationVertical:{
                switch(constraints.type){
                    case CKSplitViewConstraintsTypeFixedSizeInPixels:{
                        fixedSpace += constraints.size;
                        break;
                    }
                    case CKSplitViewConstraintsTypeFixedSizeRatio:{
                        fixedSpace += (self.bounds.size.height * constraints.size);
                        break;
                    }
                    case CKSplitViewConstraintsTypeFlexibleSize:{
                        ++numberOfFlexibleViews;
                        break;
                    }
                }
                break;
            }
        }
        ++i;
    }
    
    //compute flexible values
    
    CGFloat flexibleValue = 0.0;
    if(numberOfFlexibleViews > 0){
        switch(self.orientation){
            case CKSplitViewOrientationHorizontal:{
                CGFloat rest = self.bounds.size.width - fixedSpace;
                flexibleValue = (rest / (CGFloat)numberOfFlexibleViews);
                break;
            }
            case CKSplitViewOrientationVertical:{
                CGFloat rest = self.bounds.size.height - fixedSpace;
                flexibleValue = (rest / (CGFloat)numberOfFlexibleViews);
                break;
            }
        }
    }
    
    //set frames
    
    i = 0;
    CGRect newFrame = CGRectMake(0,0,0,0);
    for(UIView* view in self.controllerViews){
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        CKSplitViewConstraints* constraints = [self.delegate splitView:self constraintsForViewAtIndex:i];
        switch(self.orientation){
            case CKSplitViewOrientationHorizontal:{
                newFrame.origin.x += newFrame.size.width;
                newFrame.size.height = self.bounds.size.height;
                switch(constraints.type){
                    case CKSplitViewConstraintsTypeFixedSizeInPixels:{
                        newFrame.size.width = constraints.size;
                        break;
                    }
                    case CKSplitViewConstraintsTypeFixedSizeRatio:{
                        newFrame.size.width = (self.bounds.size.width * constraints.size);
                        break;
                    }
                    case CKSplitViewConstraintsTypeFlexibleSize:{
                        newFrame.size.width = flexibleValue;
                        break;
                    }
                }
                break;
            }
            case CKSplitViewOrientationVertical:{
                newFrame.origin.y += newFrame.size.height;
                newFrame.size.width = self.bounds.size.width;
                switch(constraints.type){
                    case CKSplitViewConstraintsTypeFixedSizeInPixels:{
                        newFrame.size.height = constraints.size;
                        break;
                    }
                    case CKSplitViewConstraintsTypeFixedSizeRatio:{
                        newFrame.size.height = (self.bounds.size.height * constraints.size);
                        break;
                    }
                    case CKSplitViewConstraintsTypeFlexibleSize:{
                        newFrame.size.height = flexibleValue;
                        break;
                    }
                }
                break;
            }
        }
        view.frame = CGRectIntegral(newFrame);
        
        ++i;
    }
}

@end


@interface CKSplitViewController()
@property (nonatomic, retain, readwrite) CKSplitView* splitView;
@property (nonatomic, assign) BOOL hasBeenReloaded;
@end


@implementation CKSplitViewController
@synthesize viewControllers = _viewControllers;
@synthesize splitView = _splitView;
@synthesize hasBeenReloaded;
@synthesize orientation;

- (void)postInit{
    [super postInit];
    self.hasBeenReloaded = NO;
    self.orientation = CKSplitViewOrientationHorizontal;
}

- (void)dealloc{
    [_splitView release];
    _splitView = nil;
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

- (void)setViewControllers:(NSArray *)viewControllers {
    [self setViewControllers:viewControllers animationDuration:0 startAnimationBlock:nil animationBlock:nil endAnimationBlock:nil];
}

- (void)setViewControllers:(NSArray *)theViewControllers 
         animationDuration:(NSTimeInterval)animationDuration
       startAnimationBlock:(void(^)(UIViewController* controller, CGRect beginFrame, CGRect endFrame, CKSplitViewControllerAnimationState state))startAnimationBlock
            animationBlock:(void(^)(UIViewController* controller, CGRect beginFrame, CGRect endFrame, CKSplitViewControllerAnimationState state))animationBlock
            endAnimationBlock:(void(^)(UIViewController* controller, CGRect beginFrame, CGRect endFrame, CKSplitViewControllerAnimationState state))endAnimationBlock{
    
    NSArray* oldViewControllers = [NSArray arrayWithArray:self.viewControllers];
    
    //Sets the new viewControllers
    [_viewControllers release];
    _viewControllers = [theViewControllers retain];
    
    for(UIViewController* controller in theViewControllers){
        [controller setContainerViewController:self];
    }
    
    if(self.isViewDisplayed){
        NSMutableSet* removedController = [NSMutableSet set];
        NSMutableSet* addedController = [NSMutableSet set];
        NSMutableSet* keepingController = [NSMutableSet set];
        
        NSMutableDictionary* beginFrames = [NSMutableDictionary dictionary];
        NSMutableDictionary* endFrames = [NSMutableDictionary dictionary];
        
        //Finds the removedController, addedController and keepingController and store initial frame
        for(UIViewController* controller in theViewControllers){
            if([oldViewControllers indexOfObjectIdenticalTo:controller] != NSNotFound){
                [keepingController addObject:controller];
                [beginFrames setObject:[NSValue valueWithCGRect:controller.view.frame] forKey:[NSValue valueWithNonretainedObject:controller]];
            }else{
                [addedController addObject:controller];
            }
        }
        
        for(UIViewController* controller in oldViewControllers){
            if([theViewControllers indexOfObjectIdenticalTo:controller] == NSNotFound){
                [removedController addObject:controller];
                [beginFrames setObject:[NSValue valueWithCGRect:controller.view.frame] forKey:[NSValue valueWithNonretainedObject:controller]];
            }
        }
        
        //Creates views if need and store final frame
        [_splitView reloadData];
        
        for(UIViewController* controller in theViewControllers){
            [endFrames setObject:[NSValue valueWithCGRect:controller.view.frame] forKey:[NSValue valueWithNonretainedObject:controller]];
        }
        
        //Animates View Controllers
        if(animationDuration > 0){
            //Animates Keeping Controllers
            for(UIViewController* controller in keepingController){
                CGRect beginFrame = [[beginFrames objectForKey:[NSValue valueWithNonretainedObject:controller]]CGRectValue];
                CGRect endFrame = [[endFrames objectForKey:[NSValue valueWithNonretainedObject:controller]]CGRectValue];
                
                if(startAnimationBlock){
                    startAnimationBlock(controller,beginFrame,endFrame,CKSplitViewControllerAnimationStateMoving);
                    
                    if(animationBlock){
                        controller.view.layer.zPosition += 10;
                        
                        __block UIViewController* bController = controller;
                        [UIView animateWithDuration:animationDuration animations:^{
                            animationBlock(bController,beginFrame,endFrame,CKSplitViewControllerAnimationStateMoving);
                        } completion:^(BOOL finished) {
                            bController.view.layer.zPosition -= 10;
                            if(endAnimationBlock){
                                endAnimationBlock(bController,beginFrame,endFrame,CKSplitViewControllerAnimationStateMoving);
                            }
                        }];
                    }else if(endAnimationBlock){
                        endAnimationBlock(controller,beginFrame,endFrame,CKSplitViewControllerAnimationStateMoving);
                    }
                }
            }
            
            
            for(UIViewController* controller in addedController){
                if([CKOSVersion() floatValue] < 5){
                    [controller viewWillAppear:YES];
                }
                
                CGRect beginFrame = [[beginFrames objectForKey:[NSValue valueWithNonretainedObject:controller]]CGRectValue];
                CGRect endFrame = [[endFrames objectForKey:[NSValue valueWithNonretainedObject:controller]]CGRectValue];
                
                if(startAnimationBlock){
                    startAnimationBlock(controller,beginFrame,endFrame,CKSplitViewControllerAnimationStateAdding);
                    
                    if(animationBlock){
                        controller.view.layer.zPosition += 10;
                        
                        __block UIViewController* bController = controller;
                        [UIView animateWithDuration:animationDuration animations:^{
                            animationBlock(bController,beginFrame,endFrame,CKSplitViewControllerAnimationStateAdding);
                        } completion:^(BOOL finished) {
                            bController.view.layer.zPosition -= 10;
                            if(endAnimationBlock){
                                endAnimationBlock(bController,beginFrame,endFrame,CKSplitViewControllerAnimationStateAdding);
                            }
                        }];
                        
                        
                        if([CKOSVersion() floatValue] < 5){
                        [self performBlock:^{
                            [bController viewDidAppear:YES];
                        } afterDelay:animationDuration];
                    }
                    }else if(endAnimationBlock){
                        endAnimationBlock(controller,beginFrame,endFrame,CKSplitViewControllerAnimationStateAdding);
                        
                        if([CKOSVersion() floatValue] < 5){
                            [controller viewDidAppear:YES];
                        }
                    }
                }
            }
            
            for(UIViewController* controller in removedController){
                if([CKOSVersion() floatValue] < 5){
                    [controller viewWillDisappear:YES];
                }                    
                
                CGRect beginFrame = [[beginFrames objectForKey:[NSValue valueWithNonretainedObject:controller]]CGRectValue];
                CGRect endFrame = [[endFrames objectForKey:[NSValue valueWithNonretainedObject:controller]]CGRectValue];
                
                if(startAnimationBlock){
                    startAnimationBlock(controller,beginFrame,endFrame,CKSplitViewControllerAnimationStateAdding);
                    
                    if(animationBlock){
                        controller.view.layer.zPosition += 10;
                        
                        __block UIViewController* bController = controller;
                        [UIView animateWithDuration:animationDuration animations:^{
                            animationBlock(bController,beginFrame,endFrame,CKSplitViewControllerAnimationStateAdding);
                        } completion:^(BOOL finished) {
                            bController.view.layer.zPosition -= 10;
                            if(endAnimationBlock){
                                endAnimationBlock(bController,beginFrame,endFrame,CKSplitViewControllerAnimationStateAdding);
                            }
                        }];
                        
                        [self performBlock:^{
                            [bController.view removeFromSuperview];
                            [bController setContainerViewController:nil];
                        } afterDelay:animationDuration];
                    }else if(endAnimationBlock){
                        endAnimationBlock(controller,beginFrame,endFrame,CKSplitViewControllerAnimationStateAdding);
                        [controller.view removeFromSuperview];
                        [controller setContainerViewController:nil];
                    }
                }
            }
        }else{
            if([CKOSVersion() floatValue] < 5){
                for(UIViewController* controller in addedController){
                    [controller viewWillAppear:NO];
                    [controller viewDidAppear:NO];
                }
            }
            for(UIViewController* controller in removedController){
                [controller.view removeFromSuperview];
                [controller setContainerViewController:nil];
            }
        }
    }
}

- (void)loadView{
    [super loadView];
    
    if(_splitView == nil){
        self.splitView = [[[CKSplitView alloc]initWithFrame:self.view.bounds]autorelease];
        _splitView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _splitView.clipsToBounds = YES;
        [self.view addSubview:_splitView];
    }
    
    _splitView.orientation = self.orientation;
    
    if(_splitView.delegate == nil){
        _splitView.delegate = self;
    }
}

- (void)viewDidUnload{
    [_splitView release];
    _splitView = nil;
    
    self.hasBeenReloaded = NO;
    
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    BOOL enable = [UIView areAnimationsEnabled];
    [UIView setAnimationsEnabled:NO];
    
    if(!self.hasBeenReloaded){
        self.hasBeenReloaded = YES;
        [_splitView reloadData];
    }
    
    [_splitView layoutSubviews];
    
    [UIView setAnimationsEnabled:enable];
    
    for(UIViewController* controller in self.viewControllers){
        [controller viewWillAppear:animated];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    for(UIViewController* controller in self.viewControllers){
        [controller viewDidAppear:animated];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    for(UIViewController* controller in self.viewControllers){
        [controller viewWillDisappear:animated];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    for(UIViewController* controller in self.viewControllers){
        [controller viewDidDisappear:animated];
    }
}

- (NSInteger)numberOfViewsInSplitView:(CKSplitView*)view{
    return [_viewControllers count];
}

- (UIView*)splitView:(CKSplitView*)view viewAtIndex:(NSInteger)index{
    return [[_viewControllers objectAtIndex:index]view];
}

- (CKSplitViewConstraints*)splitView:(CKSplitView*)view constraintsForViewAtIndex:(NSInteger)index{
    return [[_viewControllers objectAtIndex:index]splitViewConstraints];
}

- (NSArray*)toolbarItems{
    NSMutableArray* items = [NSMutableArray array];
    for(UIViewController* controller in self.viewControllers){
        if(controller.toolbarItems){
            [items addObjectsFromArray:controller.toolbarItems];
        }
    }
    return items;
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

- (BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers{ return NO; }
- (BOOL)shouldAutomaticallyForwardRotationMethods{ return NO; }
- (BOOL)shouldAutomaticallyForwardAppearanceMethods{ return NO; }

@end

//UIViewController(CKSplitView)

@implementation UIViewController(CKSplitView)
static char CKViewControllerSplitViewConstraintsKey;

- (void)setSplitViewConstraints:(CKSplitViewConstraints *)constraints {
    objc_setAssociatedObject(self, 
                             &CKViewControllerSplitViewConstraintsKey,
                             constraints,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CKSplitViewConstraints *)splitViewConstraints {
    CKSplitViewConstraints* constraints = objc_getAssociatedObject(self, &CKViewControllerSplitViewConstraintsKey);
    if(constraints == nil){
        constraints = [CKSplitViewConstraints constraints];
        [self setSplitViewConstraints:constraints];
    }
    return constraints;
}

@end