//
//  CKTransitionTreeAnimator.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-17.
//  Copyright (c) 2015 Sebastien Morel. All rights reserved.
//

#import "CKTransitionTreeAnimator.h"
#import "CKTransitionViewController.h"

@interface CKTransitionTreeAnimator()
@property(nonatomic,retain,readwrite) CKTransitionTree* transitionTree;
@property(nonatomic,assign,readwrite) id<UIViewControllerContextTransitioning> transitioningContext;
@property(nonatomic,retain,readwrite) NSDate* startDate;
@property(nonatomic,retain,readwrite) NSDate* computeTransitionDate;
@property(nonatomic,retain,readwrite) NSDate* afterPrepareDate;
@property(nonatomic,retain,readwrite) NSDate* beforePrepareTransitionDate;
@property(nonatomic,retain,readwrite) NSDate* afterPrepareTransitionDate;
@end

@implementation CKTransitionTreeAnimator

- (void)dealloc{
    [_transitionTree release];
    [super dealloc];
}

- (CKTransitionTree*)transitionTree{
    if(!_transitionTree){
        self.transitionTree = [[[CKTransitionTree alloc]init]autorelease];
    }
    return _transitionTree;
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext{
    return [self.transitionTree totalDuration];
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    //startInteractiveTransition is doing the job
}

- (void)animationEnded:(BOOL) transitionCompleted{
}

- (void)prepareTransitionTreeWithContext:(id<UIViewControllerContextTransitioning>)transitionContext {
}

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    self.startDate = [NSDate date];
    
    CKCollectionViewController* toCollectionViewController = [self toCollectionViewControllerWithTransitioningContext:transitionContext];
    if(toCollectionViewController){
        [toCollectionViewController.collectionView layoutIfNeeded];
    }
    
    CKTableViewController* toTableViewController = [self toTableViewControllerWithTransitioningContext:transitionContext];
    if(toTableViewController){
        [toTableViewController.tableView layoutIfNeeded];
    }
    
    self.computeTransitionDate = [NSDate date];
    
    [self.transitionTree removeAllViewTransitionContexts];
    self.transitioningContext = transitionContext;
    
    UIViewController* from = (UIViewController*)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController* to = (UIViewController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGRect finalRect   = [transitionContext finalFrameForViewController:to];
    to.view.frame = finalRect;
    
    [[transitionContext containerView]addSubview:to.view];
    
    [self prepareTransitionTreeWithContext:transitionContext];
    
    self.afterPrepareDate = [NSDate date];
    
    to.view.hidden = YES;
    
    __unsafe_unretained UIViewController* bfrom = from;
    
     dispatch_async(dispatch_get_main_queue(), ^{
        self.beforePrepareTransitionDate = [NSDate date];
        [self.transitionTree prepareForTransitionWithContext:transitionContext ];
        self.afterPrepareTransitionDate = [NSDate date];
        
        if(!self.interactive){
            [self completeTransitionWithTransitioningContext:transitionContext];
        }
        bfrom.view.hidden = YES;
     });
}

- (UIViewController*)rootViewControllerFromController:(UIViewController*)controller{
    UIViewController* c = controller;
    while (c.containerViewController || (![c isKindOfClass:[UINavigationController class]] && c.navigationController )) {
        if( c.containerViewController) c = c.containerViewController;
        if(!c.containerViewController) c = c.navigationController;
    }
    return c;
}


- (void)completeTransitionWithTransitioningContext:(id<UIViewControllerContextTransitioning>)transitionContext{
    UIViewController* to = (UIViewController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
     UIViewController* root = [self rootViewControllerFromController:to];
    
    [root.view setUserInteractionEnabled:NO];
    
    [transitionContext finishInteractiveTransition];
    
    __unsafe_unretained UIViewController* broot = root;
    __unsafe_unretained UIViewController* bto = to;
    
    [self.transitionTree performTransitionWithContext:transitionContext percentComplete:^(CGFloat percentComplete){
        [transitionContext updateInteractiveTransition:percentComplete];
    }
                                           completion:^(BOOL finished) {
                                               if(finished){
                                                   
                                                   [broot.view setUserInteractionEnabled:YES];
                                                   bto.view.hidden = NO;
                                                   
                                                   [self.transitionTree endTransition];
                                                   [self didCompleteTransitionWithTransitioningContext:transitionContext];
                                                   
                                                   [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
                                               }
                                           }];
    
    NSDate* now = [NSDate date];
    NSTimeInterval diff = [now timeIntervalSinceDate:self.startDate];
    NSTimeInterval diff2 = [self.computeTransitionDate timeIntervalSinceDate:self.startDate];
    NSTimeInterval diff3 = [self.afterPrepareDate timeIntervalSinceDate:self.computeTransitionDate];
    NSTimeInterval diff4 = [self.beforePrepareTransitionDate timeIntervalSinceDate:self.afterPrepareDate];
    NSTimeInterval diff5 = [self.afterPrepareTransitionDate timeIntervalSinceDate:self.beforePrepareTransitionDate];
    NSLog(@"[TOTAL] %f (s) [TARGET LAYOUT] %ld%% [PREPARE TREE] %ld%% [DISPATCH] %ld%% [PREPARE TRANSITION] %ld%%",
          diff,
          (long)(diff2 / diff * 100),
          (long)(diff3 / diff * 100),
          (long)(diff4 / diff * 100),
          (long)(diff5 / diff * 100));
}

- (void)didCompleteTransitionWithTransitioningContext:(id<UIViewControllerContextTransitioning>)transitionContext{
    [self.transitionTree removeAllViewTransitionContexts];
    
    CKCollectionViewController* toCollectionViewController = [self toCollectionViewControllerWithTransitioningContext:transitionContext];
    if(toCollectionViewController){
        [toCollectionViewController.collectionView.collectionViewLayout invalidateLayout];
        [toCollectionViewController.collectionView setNeedsLayout];
        [toCollectionViewController.collectionView layoutIfNeeded];
    }
}


- (CKCollectionViewController*)fromCollectionViewControllerWithTransitioningContext:(id<UIViewControllerContextTransitioning>)transitionContext{
    return (CKCollectionViewController*)[self viewControllerWithKey:UITransitionContextFromViewControllerKey class:[CKCollectionViewController class] transitioningContext:transitionContext];
}

- (CKCollectionViewController*)toCollectionViewControllerWithTransitioningContext:(id<UIViewControllerContextTransitioning>)transitionContext{
    return (CKCollectionViewController*)[self viewControllerWithKey:UITransitionContextToViewControllerKey class:[CKCollectionViewController class] transitioningContext:transitionContext];
}

- (CKTableViewController*)fromTableViewControllerWithTransitioningContext:(id<UIViewControllerContextTransitioning>)transitionContext{
    return (CKTableViewController*)[self viewControllerWithKey:UITransitionContextFromViewControllerKey class:[CKTableViewController class] transitioningContext:transitionContext];
}

- (CKTableViewController*)toTableViewControllerWithTransitioningContext:(id<UIViewControllerContextTransitioning>)transitionContext{
    return (CKTableViewController*)[self viewControllerWithKey:UITransitionContextToViewControllerKey class:[CKTableViewController class] transitioningContext:transitionContext];
}

- (UIViewController*)viewControllerWithKey:(NSString*)key class:(Class)type transitioningContext:(id<UIViewControllerContextTransitioning>)transitionContext{
    UIViewController* controller = (UIViewController*)[transitionContext viewControllerForKey:key];
    
    if([controller isKindOfClass:[CKTransitionViewController class]]){
        CKTransitionViewController* transitionVC = (CKTransitionViewController*)controller;
        if([transitionVC.viewController isKindOfClass:type]){
            return transitionVC.viewController;
        }
    }else if([controller isKindOfClass:type]){
        return controller;
    }
    
    return nil;
}

- (UIViewController*)viewControllerWithClass:(Class)type transitioningContext:(id<UIViewControllerContextTransitioning>)transitionContext{
    UIViewController* from = [self viewControllerWithKey:UITransitionContextFromViewControllerKey class:type transitioningContext:transitionContext];
    if(from)
        return from;
    
    return [self viewControllerWithKey:UITransitionContextToViewControllerKey class:type transitioningContext:transitionContext];
}

@end
