//
//  CKTransitionTree.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-01.
//  Copyright (c) 2015 Sebastien Morel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKViewTransitionContext.h"
#import "CKTransitionNode.h"
#import "CKReusableViewController+CKTransitionTree.h"


@interface CKTransitionTree : NSObject
@property(nonatomic,retain) NSArray* nodes;
@property(nonatomic,assign) CGFloat rate;

+ (CKTransitionTree*)treeWithNodes:(NSArray*)nodes;

- (CGFloat)totalDuration;

- (CKTransitionNode*)nodeNamed:(NSString*)name;

- (CKViewTransitionContext*)viewTransitionContextNamed:(NSString*)name;
- (void)removeAllViewTransitionContexts;

- (void)prepareForTransitionWithContext:(id <UIViewControllerContextTransitioning>)transitionContext;

- (void)performTransitionWithContext:(id <UIViewControllerContextTransitioning>)transitionContext
                     percentComplete:(void(^)(CGFloat percentComplete))percentComplete
                          completion:(void(^)(BOOL finished))completion;

- (void)endTransition;


@end

