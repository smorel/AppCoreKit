//
//  CKTransitionTreeAnimator.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-17.
//  Copyright (c) 2015 Sebastien Morel. All rights reserved.
//

#import "CKTransitionTree.h"
#import "CKCollectionViewController.h"
#import "CKTableViewController.h"

//Documentation about transitions:
//http://initwithfunk.com/blog/2014/05/22/interactive-animated-transitions-on-ios/
//http://stackoverflow.com/questions/18968629/proper-way-to-implement-a-custom-uiviewcontroller-interactive-transition-using-u


/** This object provides the mechanic to setup a transition tree for transition between two view controllers
 Implements prepareTransitionTreeWithContext in your subclass where you can create and populate nodes in your tree.
 The rest is managed for you.
 */
@interface CKTransitionTreeAnimator :  NSObject<UIViewControllerAnimatedTransitioning,UIViewControllerInteractiveTransitioning>

@property(nonatomic,assign,readonly) id<UIViewControllerContextTransitioning> transitioningContext;

@property(nonatomic,assign) BOOL interactive;

@property(nonatomic,retain,readonly) CKTransitionTree* transitionTree;

- (void)prepareTransitionTreeWithContext:(id<UIViewControllerContextTransitioning>)transitionContext;
- (void)completeTransitionWithTransitioningContext:(id<UIViewControllerContextTransitioning>)transitionContext;
- (void)didCompleteTransitionWithTransitioningContext:(id<UIViewControllerContextTransitioning>)transitionContext;

//querying from and to view controllers by type

- (UIViewController*)viewControllerWithKey:(NSString*)key class:(Class)type transitioningContext:(id<UIViewControllerContextTransitioning>)transitionContext;
- (UIViewController*)viewControllerWithClass:(Class)type transitioningContext:(id<UIViewControllerContextTransitioning>)transitionContext;

- (CKCollectionViewController*)fromCollectionViewControllerWithTransitioningContext:(id<UIViewControllerContextTransitioning>)transitionContext;
- (CKCollectionViewController*)toCollectionViewControllerWithTransitioningContext:(id<UIViewControllerContextTransitioning>)transitionContext;

- (CKTableViewController*)fromTableViewControllerWithTransitioningContext:(id<UIViewControllerContextTransitioning>)transitionContext;
- (CKTableViewController*)toTableViewControllerWithTransitioningContext:(id<UIViewControllerContextTransitioning>)transitionContext;


@end
