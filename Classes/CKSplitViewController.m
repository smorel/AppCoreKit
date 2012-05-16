//
//  CKSplitViewController.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-10-25.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import "CKSplitViewController.h"
#import "CKContainerViewController.h"
#import "CKNSObject+Bindings.h"
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
@end

@implementation CKSplitView
@synthesize delegate;
@synthesize controllerViews = _controllerViews;
@synthesize orientation;

- (void)dealloc{
    [NSObject removeAllBindingsForContext:[NSString stringWithFormat:@"CKSplitView<%p>",self]];
    [_controllerViews release];
    _controllerViews = nil;
    [super dealloc];
}

- (void)reloadData{
    [NSObject beginBindingsContext:[NSString stringWithFormat:@"CKSplitView<%p>",self] policy:CKBindingsContextPolicyRemovePreviousBindings];
    NSInteger count = self.delegate ? [delegate numberOfViewsInSplitView:self] : 0;
    if(count && !_controllerViews){
        self.controllerViews = [NSMutableArray array];
    }
    else{
        for(UIView* view in _controllerViews){
            [view removeFromSuperview];
        }
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

- (void)postInit{
    [super postInit];
    self.hasBeenReloaded = NO;
}

- (void)dealloc{
    [_splitView release];
    _splitView = nil;
    [_viewControllers release];
    _viewControllers = nil;
    [super dealloc];
}


- (id)initWithViewControllers:(NSArray*)theViewControllers{
    self = [super init];
     self.viewControllers = theViewControllers;
     return self;
}

- (void)setViewControllers:(NSArray *)theViewControllers{
    for(UIViewController* controller in _viewControllers){
        [controller setContainerViewController:nil];
        if([CKOSVersion() floatValue] >= 5){
            [controller removeFromParentViewController];
        }
    }
    
    [_viewControllers release];
    _viewControllers = [theViewControllers retain];
    
    for(UIViewController* controller in _viewControllers){
        [controller setContainerViewController:self];
        if([CKOSVersion() floatValue] >= 5){
            [self addChildViewController:controller];
        }
    }
    
    if(_splitView){
        [_splitView reloadData];
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
    
    [UIView setAnimationsEnabled:NO];
    
    if(!self.hasBeenReloaded){
        self.hasBeenReloaded = YES;
        [_splitView reloadData];
    }
    
    for(UIViewController* controller in self.viewControllers){
        [controller viewWillAppear:animated];
    }
    
    [_splitView setNeedsLayout];
    
    [UIView setAnimationsEnabled:YES];
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

@end

//UIViewController(CKSplitView)

@implementation UIViewController(CKSplitView)
static char CKUIViewControllerSplitViewConstraintsKey;

- (void)setSplitViewConstraints:(CKSplitViewConstraints *)constraints {
    objc_setAssociatedObject(self, 
                             &CKUIViewControllerSplitViewConstraintsKey,
                             constraints,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CKSplitViewConstraints *)splitViewConstraints {
    CKSplitViewConstraints* constraints = objc_getAssociatedObject(self, &CKUIViewControllerSplitViewConstraintsKey);
    if(constraints == nil){
        constraints = [CKSplitViewConstraints constraints];
        [self setSplitViewConstraints:constraints];
    }
    return constraints;
}

@end