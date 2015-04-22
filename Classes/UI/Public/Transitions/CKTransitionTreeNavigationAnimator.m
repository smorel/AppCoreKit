//
//  CKTransitionTreeNavigationAnimator.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-21.
//  Copyright (c) 2015 Sebastien Morel. All rights reserved.
//

#import "CKTransitionTreeNavigationAnimator.h"

@interface CKTransitionTreeNavigationAnimator()

@property(nonatomic,retain,readwrite) CKTransitionTree* pushTransitionTree;
@property(nonatomic,retain,readwrite) CKTransitionTree* popTransitionTree;

@end

@implementation CKTransitionTreeNavigationAnimator

- (id)init{
    self = [super init];
    self.pushTransitionTree = [[[CKTransitionTree alloc]init]autorelease];
    self.popTransitionTree = [[[CKTransitionTree alloc]init]autorelease];
    return self;
}

- (void)dealloc{
    [_pushTransitionTree release];
    [_popTransitionTree release];
    [super dealloc];
}

- (CKTransitionTree*)transitionTree{
    return self.operation == UINavigationControllerOperationPop ? self.popTransitionTree : self.pushTransitionTree;
}

- (void)prepareTransitionTreeWithContext:(id<UIViewControllerContextTransitioning>)transitionContext {
    if(self.operation == UINavigationControllerOperationPush) {
        [self preparePushTransitionTreeWithContext:transitionContext];
    }else{
        [self preparePopTransitionTreeWithContext:transitionContext];
    }
}

- (void)preparePushTransitionTreeWithContext:(id<UIViewControllerContextTransitioning>)transitionContext{
}

- (void)preparePopTransitionTreeWithContext:(id<UIViewControllerContextTransitioning>)transitionContext{
}

@end
