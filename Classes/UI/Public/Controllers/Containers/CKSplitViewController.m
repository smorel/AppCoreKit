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
        
        [self.controllerViews addObject:view];
    }
    [NSObject endBindingsContext];
    
    
    [self preformLayoutOnSubViewControllers];
    
    for(UIView* v in self.controllerViews){
        //This calls viewWill appear on the view's controller
        //if subview controller is also a splitter, or whatever it needs to know its size in viewWillApear
        //preformLayoutOnSubViewControllers needs to get called before addSubview
        [self addSubview:v];
    }
}

- (NSMutableArray*)computeFramesForViewsWithConstraints:(NSArray*)allConstraints{
    CGFloat fixedSpace = 0;
    NSInteger numberOfFlexibleViews = 0;
    
    int i =0;
    for(CKSplitViewConstraints* constraints in allConstraints){
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
    NSMutableArray* frames = [NSMutableArray array];
    
    i = 0;
    CGRect newFrame = CGRectMake(0,0,0,0);
    for(CKSplitViewConstraints* constraints in allConstraints){
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
        
        [frames addObject:[NSValue valueWithCGRect:newFrame]];
        
        ++i;
    }
    
    return frames;
}

- (void)preformLayoutOnSubViewControllers{
    
    NSMutableArray* constraints = [NSMutableArray array];
    int i =0;
    for(UIView* view in self.controllerViews){
        CKSplitViewConstraints* constraint = [self.delegate splitView:self constraintsForViewAtIndex:i];
        [constraints addObject:constraint];
        ++i;
    }
    
    NSArray* frames = [self computeFramesForViewsWithConstraints:constraints];
    i =0;
    for(UIView* view in self.controllerViews){
        CGRect  newFrame = [[frames objectAtIndex:i]CGRectValue];
        view.frame = CGRectIntegral(newFrame);
        ++i;
    }
}

- (void)layoutSubviews{
    
    [super layoutSubviews];
    [self preformLayoutOnSubViewControllers];
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

+ (void)load{
    //FIXME: Removes this Transformer when split view controller will leverage CKLayout system
    
    [CKCascadingTree registerTransformer:^(NSString* containerKey, NSMutableDictionary *container, NSString *key, id value) {
        id sizeValue = [container objectForKey:@"fixedHeight"];
        if(!sizeValue){
            sizeValue = [container objectForKey:@"fixedWidth"];
        }
        
        [container removeObjectForKey:key];
        [container setObject:[NSMutableDictionary dictionaryWithDictionary:@{
                               @"type" : @(CKSplitViewConstraintsTypeFixedSizeInPixels),
                               @"size" : sizeValue
                               }]
                      forKey:@"splitViewConstraints"];
    } forPredicate:^BOOL(NSString* containerKey, NSMutableDictionary *container, NSString *key, id value) {
        if([key isEqualToString:@"fixedHeight"] || [key isEqualToString:@"fixedWidth"]){
            Class containerClass = NSClassFromString(containerKey);
            if(containerClass && [NSObject isClass:containerClass kindOfClass:[UIViewController class]]){
                return YES;
            }
        }
        return NO;
    }];
}

- (void)postInit{
    [super postInit];
    self.hasBeenReloaded = NO;
    self.orientation = CKSplitViewOrientationHorizontal;
    self.automaticallyAdjustInsetsToMatchNavigationControllerTransparency = NO;
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
        //Merging controllers to get those removed & added & kept
        NSMutableArray* oldAndNewViewControllers = [NSMutableArray arrayWithArray:theViewControllers];
        
        UIViewController* lastStillHere = nil;
        for(UIViewController* controller in oldViewControllers){
            if([theViewControllers indexOfObjectIdenticalTo:controller] == NSNotFound){//removing
                NSInteger indexOfPrevious = lastStillHere ? [oldAndNewViewControllers indexOfObjectIdenticalTo:lastStillHere] : 0;
                [oldAndNewViewControllers insertObject:controller atIndex:indexOfPrevious+1];
            }else{
                lastStillHere = controller;
            }
        }
        
        //Compute diffs
        
        NSMutableArray* beginConstraints = [NSMutableArray array];
        NSMutableArray* endConstraints = [NSMutableArray array];
        NSMutableArray* states = [NSMutableArray array];
        
        CKSplitViewConstraints* zeroConstraint = [[[CKSplitViewConstraints alloc]init]autorelease];
        zeroConstraint.type = CKSplitViewConstraintsTypeFixedSizeInPixels;
        zeroConstraint.size = 0;
        
        for(UIViewController* controller in oldAndNewViewControllers){
            if([theViewControllers indexOfObjectIdenticalTo:controller] == NSNotFound){//removing
                [states addObject:[NSNumber numberWithInt:CKSplitViewControllerAnimationStateRemoving]];
                [beginConstraints addObject:controller.splitViewConstraints];
                [endConstraints addObject:zeroConstraint];
            }
            else if([oldViewControllers indexOfObjectIdenticalTo:controller] == NSNotFound){//adding
                [states addObject:[NSNumber numberWithInt:CKSplitViewControllerAnimationStateAdding]];
                [beginConstraints addObject:zeroConstraint];
                [endConstraints addObject:controller.splitViewConstraints];
            }
            else{ //keeping
                [states addObject:[NSNumber numberWithInt:CKSplitViewControllerAnimationStateMoving]];
                [beginConstraints addObject:controller.splitViewConstraints];
                [endConstraints addObject:controller.splitViewConstraints];
            }
        }
        
        //Compute frames at begining and end of the animation
        
        NSMutableArray* beginFrames  = [self.splitView computeFramesForViewsWithConstraints:beginConstraints];
        NSArray* endFrames    = [self.splitView computeFramesForViewsWithConstraints:endConstraints];
        
        for(int i =0;i<oldAndNewViewControllers.count;++i){
            UIViewController* controller = [oldAndNewViewControllers objectAtIndex:i];
            
            CKSplitViewControllerAnimationState state = [[states objectAtIndex:i]intValue];
            switch(state){
                case CKSplitViewControllerAnimationStateMoving:
                case CKSplitViewControllerAnimationStateRemoving: {
                    [beginFrames replaceObjectAtIndex:i withObject:[NSValue valueWithCGRect:controller.view.frame]];
                    break;
                }
            }
        }
        
        //Animates View Controllers
        if(animationDuration > 0){
            
            [self.splitView reloadData];
            
            for(int i =0;i<oldAndNewViewControllers.count;++i){
                UIViewController* controller = [oldAndNewViewControllers objectAtIndex:i];
                
                CGRect beginFrame = [[beginFrames objectAtIndex:i ] CGRectValue];
                CGRect endFrame = [[endFrames objectAtIndex:i ] CGRectValue];
                CKSplitViewControllerAnimationState state = [[states objectAtIndex:i]intValue];

                controller.view.frame = beginFrame;
                if(startAnimationBlock){
                    startAnimationBlock(controller,beginFrame,endFrame,state);
                }
                
                switch(state){
                    case CKSplitViewControllerAnimationStateMoving: {
                        controller.view.layer.zPosition += 13;
                        break;
                    }
                    case CKSplitViewControllerAnimationStateAdding: {
                        if([CKOSVersion() floatValue] < 5){
                            [controller viewWillAppear:YES];
                        }
                        controller.view.layer.zPosition += 12;
                        break;
                    }
                    case CKSplitViewControllerAnimationStateRemoving: {
                        if([CKOSVersion() floatValue] < 5){
                            [controller viewWillDisappear:YES];
                        }
                        controller.view.layer.zPosition += 11;
                        break;
                    }
                }
            }
            
            //Keeping Controllers
            [UIView animateWithDuration:animationDuration animations:^{
                for(int i =0;i<oldAndNewViewControllers.count;++i){
                    UIViewController* controller = [oldAndNewViewControllers objectAtIndex:i];
                    
                    CGRect beginFrame = [[beginFrames objectAtIndex:i ] CGRectValue];
                    CGRect endFrame = [[endFrames objectAtIndex:i ] CGRectValue];
                    CKSplitViewControllerAnimationState state = [[states objectAtIndex:i]intValue];
                    
                    if(animationBlock){
                        animationBlock(controller,beginFrame,endFrame,state);
                    }else{
                        controller.view.frame = endFrame;
                    }
                }
            } completion:^(BOOL finished) {
                for(int i =0;i<oldAndNewViewControllers.count;++i){
                    UIViewController* controller = [oldAndNewViewControllers objectAtIndex:i];
                    
                    CGRect beginFrame = [[beginFrames objectAtIndex:i ] CGRectValue];
                    CGRect endFrame = [[endFrames objectAtIndex:i ] CGRectValue];
                    CKSplitViewControllerAnimationState state = [[states objectAtIndex:i]intValue];
                    
                    controller.view.frame = endFrame;
                    if(endAnimationBlock){
                        endAnimationBlock(controller,beginFrame,endFrame,CKSplitViewControllerAnimationStateMoving);
                    }
                    
                    switch(state){
                        case CKSplitViewControllerAnimationStateMoving: {
                            controller.view.layer.zPosition -= 13;
                            break;
                        }
                        case CKSplitViewControllerAnimationStateAdding: {
                            controller.view.layer.zPosition -= 12;
                            if([CKOSVersion() floatValue] < 5){
                                [controller viewDidAppear:YES];
                            }
                            break;
                        }
                        case CKSplitViewControllerAnimationStateRemoving: {
                            controller.view.layer.zPosition -= 11;
                            if([CKOSVersion() floatValue] < 5){
                                [controller viewDidDisappear:YES];
                            }
                            [controller.view removeFromSuperview];
                            [controller setContainerViewController:nil];
                            break;
                        }
                    }
                }
            }];
        }else{
            
            [self.splitView reloadData];
            
            for(int i =0;i<oldAndNewViewControllers.count;++i){
                UIViewController* controller = [oldAndNewViewControllers objectAtIndex:i];
                CKSplitViewControllerAnimationState state = [[states objectAtIndex:i]intValue];
                
                switch(state){
                    case CKSplitViewControllerAnimationStateMoving: {
                        break;
                    }
                    case CKSplitViewControllerAnimationStateAdding: {
                        if([CKOSVersion() floatValue] < 5){
                            [controller viewWillAppear:NO];
                            [controller viewDidAppear:NO];
                        }
                        break;
                    }
                    case CKSplitViewControllerAnimationStateRemoving: {
                        if([CKOSVersion() floatValue] < 5){
                            [controller viewWillDisappear:NO];
                            [controller viewDidDisappear:NO];
                        }
                        [controller.view removeFromSuperview];
                        [controller setContainerViewController:nil];
                        break;
                    }
                }
            }
        }
    }
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    if(self.automaticallyAdjustInsetsToMatchNavigationControllerTransparency){
        UIEdgeInsets insets = [self navigationControllerTransparencyInsets];
        self.splitView.frame = CGRectMake(insets.left,
                                          insets.top,
                                          self.view.bounds.size.width - (insets.left + insets.right),
                                          self.view.bounds.size.height - (insets.top + insets.bottom));
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


- (void)resourceManagerReloadUI{
    [self reapplyStylesheet];
    //do not update childrens as it's done by the ResourceManager itself
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    BOOL enable = [UIView areAnimationsEnabled];
    [UIView setAnimationsEnabled:NO];
    
    if(!self.hasBeenReloaded){
        self.hasBeenReloaded = YES;
        [_splitView reloadData];
    }
    
  //  [_splitView layoutSubviews];
    
    [UIView setAnimationsEnabled:enable];
    
    if([CKOSVersion() floatValue] < 5){
        for(UIViewController* controller in self.viewControllers){
            [controller viewWillAppear:animated];
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

/*
- (BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers{ return NO; }
- (BOOL)shouldAutomaticallyForwardRotationMethods{ return NO; }
- (BOOL)shouldAutomaticallyForwardAppearanceMethods{ return NO; }
*/

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