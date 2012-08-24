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
@synthesize addOrRemoveAnimationBlock;
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
    self.addOrRemoveBlock = nil;
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
    [self setViewControllers:viewControllers animated:NO];
}

- (void)setViewControllers:(NSArray *)theViewControllers animated:(BOOL)animated {
    NSArray * oldViewControllers = [[_viewControllers retain] autorelease];
    for(UIViewController* controller in _viewControllers){
        if (![theViewControllers containsObject:controller] && controller.view.frame.size.width > 2) {
            __block UIViewController* bController = controller;
            
            CGFloat beginAlpha = controller.view.alpha;
            __block CKSplitViewController* bself = self;
            [UIView animateWithDuration:0.4 animations:^{
                if (bself.addOrRemoveAnimationBlock)
                    bself.addOrRemoveAnimationBlock(controller.view, YES);
                else
                    bController.view.alpha = 0.0;
            } completion:^(BOOL finished) {
                bController.view.alpha = beginAlpha;
                [bController setContainerViewController:nil];
            }];
        }
    }
    
    [_viewControllers release];
    _viewControllers = [theViewControllers retain];
    
    for(UIViewController* controller in _viewControllers){
        if (![oldViewControllers containsObject:controller]) {
            __block UIViewController* bController = controller;
            [controller setContainerViewController:self];
            
            CGFloat beginAlpha = controller.view.alpha;
            
            controller.view.alpha = 0.0;
            [UIView animateWithDuration:animated ? 0.4 : 0.0 animations:^{
                if (self.addOrRemoveAnimationBlock)
                    self.addOrRemoveAnimationBlock(bController.view, NO);
                else
                    bController.view.alpha = beginAlpha;
            } completion:^(BOOL finished) {
                
            }];
        }
    }
    
    if(self.isViewDisplayed){
        if([CKOSVersion() floatValue] < 5){
            for(UIViewController* controller in _viewControllers){
                [controller view];//force to load view now
                [controller viewWillAppear:NO];
            }
        }
        
        if(animated){
            [UIView beginAnimations:@"SplitViewControllerChanges" context:nil];
            [UIView setAnimationDuration:0.4];
        }
        [_splitView reloadData];
        if(animated){
            [UIView commitAnimations];
        }
        
        if([CKOSVersion() floatValue] < 5){
            for(UIViewController* controller in _viewControllers){
                [controller viewDidAppear:NO];
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
        _splitView.addOrRemoveBlock = self.addOrRemoveAnimationBlock;
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

- (void)setAddOrRemoveBlock:(void (^)(UIView *, BOOL))anAddOrRemoveBlock {
    addOrRemoveAnimationBlock = anAddOrRemoveBlock;
    self.splitView.addOrRemoveBlock = anAddOrRemoveBlock;
}

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