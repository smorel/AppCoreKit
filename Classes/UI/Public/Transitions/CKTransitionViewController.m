//
//  CKTransitionViewController.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-16.
//  Copyright (c) 2015 Sebastien Morel. All rights reserved.
//

#import "CKTransitionViewController.h"
#import "NSObject+Bindings.h"

@interface CKViewControllerTransitionContext : NSObject <UIViewControllerContextTransitioning>

- (instancetype)initWithFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController ;

@property (nonatomic, copy) void (^completionBlock)(BOOL didComplete);
@property (nonatomic, assign, getter=isAnimated) BOOL animated;
@property (nonatomic, assign, getter=isInteractive) BOOL interactive;

@end



@implementation CKTransitionViewController

- (void)dealloc{
    [self clearBindingsContextWithScope:@"CKTransitionViewController_Title"];
    [_viewController release];
    [super dealloc];
}

- (instancetype)initWithViewController:(UIViewController*)viewController{
    self = [super init];
    self.viewController = viewController;
    return self;
}

- (void)setViewController:(UIViewController *)viewController {
    UIViewController* oldViewController = self.viewController;
    _viewController = [viewController retain];
    
    [self _transitionFromViewController:oldViewController toViewController:viewController];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    if(self.viewController){
        [self _transitionFromViewController:nil toViewController:self.viewController];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if(self.viewController.state != CKViewControllerStateWillAppear){
        [self.viewController viewWillAppear:animated];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if(self.viewController.state != CKViewControllerStateDidAppear){
        [self.viewController viewDidAppear:animated];
    }
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self clearBindingsContextWithScope:@"CKTransitionViewController_Title"];
    
    if(self.viewController.state != CKViewControllerStateWillDisappear){
        [self.viewController viewWillDisappear:animated];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [self clearBindingsContextWithScope:@"CKTransitionViewController_Title"];
    
    if(self.viewController.state != CKViewControllerStateDidDisappear){
        [self.viewController viewDidDisappear:animated];
    }
}

- (void)_transitionFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController*)toViewController {
    if (toViewController == fromViewController || ![self isViewLoaded]) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector (transitionViewController:willPresentViewController:)]) {
         [self.delegate transitionViewController:self willPresentViewController:toViewController];
    }
    
    __block CKTransitionViewController* bself = self;
    
     [self beginBindingsContextWithScope:@"CKTransitionViewController_Title"];
     [toViewController bind:@"title" executeBlockImmediatly:YES withBlock:^(id value) {
         bself.title = [value isKindOfClass:[NSString class]] ? value : nil;
     }];
    [toViewController bind:@"rightButton" executeBlockImmediatly:YES withBlock:^(id value) {
        bself.rightButton = value;
    }];
    [toViewController bind:@"leftButton" executeBlockImmediatly:YES withBlock:^(id value) {
        bself.leftButton = value;
    }];
     [self endBindingsContext];
    
    UIView *toView = toViewController.view;
    toView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    toView.frame = self.view.bounds;
    
    [fromViewController willMoveToParentViewController:nil];
    [toViewController setContainerViewController:self];
    // [self addChildViewController:toViewController];
    
    // If this is the initial presentation, add the new child with no animation.
    if (!fromViewController) {
        [self.view addSubview:toViewController.view];
        [toViewController didMoveToParentViewController:self];
        
        if ([self.delegate respondsToSelector:@selector (transitionViewController:didPresentViewController:)]) {
            [self.delegate transitionViewController:self didPresentViewController:toViewController];
        }
        return;
    }
    
    id<UIViewControllerAnimatedTransitioning> animator = nil;
    if ([self.delegate respondsToSelector:@selector (transitionViewController:animationControllerForTransitionFromViewController:toViewController:)]) {
        animator = [self.delegate transitionViewController:self animationControllerForTransitionFromViewController:fromViewController toViewController:toViewController];
    }
    
    if(!animator){
        [self.view addSubview:toViewController.view];
        [toViewController didMoveToParentViewController:self];
        
        [fromViewController.view removeFromSuperview];
        [fromViewController removeFromParentViewController];
        [toViewController didMoveToParentViewController:self];
        
        if ([self.delegate respondsToSelector:@selector (transitionViewController:didPresentViewController:)]) {
            [self.delegate transitionViewController:self didPresentViewController:toViewController];
        }
        return;
    }
    
    CKViewControllerTransitionContext *transitionContext = [[[CKViewControllerTransitionContext alloc] initWithFromViewController:fromViewController toViewController:toViewController]autorelease];
    transitionContext.animated = YES;
    transitionContext.interactive = NO;
    transitionContext.completionBlock = ^(BOOL didComplete) {
        [fromViewController.view removeFromSuperview];
        [fromViewController removeFromParentViewController];
        [toViewController didMoveToParentViewController:self];
        
        if ([animator respondsToSelector:@selector (animationEnded:)]) {
            [animator animationEnded:didComplete];
        }
        
        if ([self.delegate respondsToSelector:@selector (transitionViewController:didPresentViewController:)]) {
            [self.delegate transitionViewController:self didPresentViewController:toViewController];
        }
    };
    
    if([animator conformsToProtocol:@protocol(UIViewControllerInteractiveTransitioning) ]){
        id<UIViewControllerInteractiveTransitioning> interactiveAnimator = ( id<UIViewControllerInteractiveTransitioning>)animator;
        [interactiveAnimator startInteractiveTransition:transitionContext];
    }else{
        [animator animateTransition:transitionContext];
    }
}

@end





@interface CKViewControllerTransitionContext ()
@property (nonatomic, strong) NSDictionary *privateViewControllers;
@property (nonatomic, assign) UIView *containerView;
@property (nonatomic, assign) UIModalPresentationStyle presentationStyle;
@end

@implementation CKViewControllerTransitionContext

- (void)dealloc{
    [_privateViewControllers release];
    [_completionBlock release];
    [super dealloc];
}

- (instancetype)initWithFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController{
    NSAssert ([fromViewController isViewLoaded] && fromViewController.view.superview, @"The fromViewController view must reside in the container view upon initializing the transition context.");
    
    if ((self = [super init])) {
        self.presentationStyle = UIModalPresentationCustom;
        self.containerView = fromViewController.view.superview;
        self.privateViewControllers = @{
            UITransitionContextFromViewControllerKey:fromViewController,
            UITransitionContextToViewControllerKey:toViewController,
        };
    }
    
    return self;
}

- (CGRect)initialFrameForViewController:(UIViewController *)viewController {
    return self.containerView.bounds;
}

- (CGRect)finalFrameForViewController:(UIViewController *)viewController {
    return self.containerView.bounds;
}

- (UIViewController *)viewControllerForKey:(NSString *)key {
    return self.privateViewControllers[key];
}

- (void)completeTransition:(BOOL)didComplete {
    if (self.completionBlock) {
        self.completionBlock (didComplete);
    }
}

- (BOOL)transitionWasCancelled { return NO; } // Our non-interactive transition can't be cancelled (it could be interrupted, though)

// Supress warnings by implementing empty interaction methods for the remainder of the protocol:

- (void)updateInteractiveTransition:(CGFloat)percentComplete {}
- (void)finishInteractiveTransition {}
- (void)cancelInteractiveTransition {}

@end

