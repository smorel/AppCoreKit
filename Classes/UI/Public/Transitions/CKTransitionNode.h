//
//  CKTransitionNode.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-20.
//  Copyright (c) 2015 Sebastien Morel. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CKViewTransitionContext.h"
#import "CKViewTransitionContext+ViewHierarchy.h"
#import "CKViewTransitionContext+Animation.h"
#import "CKViewTransitionContext+CollectionView.h"
#import "CKViewTransitionContext+TableView.h"


@interface CKTransitionNode : NSObject

@property(nonatomic,retain) NSString* name;
@property(nonatomic,retain,readonly) NSArray* nodes;
@property(nonatomic,retain,readonly) NSArray* viewTransitionContexts;

@property(nonatomic,assign) CGFloat duration;
@property(nonatomic,assign) CGFloat damping;
@property(nonatomic,assign) CGFloat delay;
@property(nonatomic,assign) CGFloat initialVelocity;
@property(nonatomic,assign) UIViewAnimationOptions options;

- (CGFloat)totalDuration;

+ (CKTransitionNode*)nodeWithName:(NSString*)name;

- (void)addChildNode:(CKTransitionNode*)node;
- (void)addChildrenNodes:(NSArray*)nodes;
- (CKTransitionNode*)nodeNamed:(NSString*)name;

- (void)addTransitionContext:(CKViewTransitionContext*)context;
- (void)addTransitionContexts:(NSArray*)contexts;
- (CKViewTransitionContext*)viewTransitionContextNamed:(NSString*)name;
- (void)removeAllViewTransitionContextsRecursive:(BOOL)recursive;

@end
