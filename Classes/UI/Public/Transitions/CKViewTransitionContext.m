//
//  CKViewTransitionContext.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-20.
//  Copyright (c) 2015 Sebastien Morel. All rights reserved.
//

#import "CKViewTransitionContext.h"
#import "UIView+Snapshot.h"
#import "CKStyleView.h"
#import "UIView+Transition.h"

@interface CKViewTransitionContext()
@property(nonatomic,retain) NSArray* viewsToHideDuringTransition;
@property(nonatomic,retain,readwrite) NSArray* viewTransitionContexts;
@property(nonatomic,retain) UIView* viewBeforeSnapshot;
@end


@implementation CKViewTransitionContext

- (void)dealloc{
    [_viewBeforeSnapshot release];
    [_viewsToHideDuringTransition release];
    [_viewTransitionContexts release];
    [_name release];
    [_snapshot release];
    [_startAttributes release];
    [_endAttributes release];
    [_additionalAnimations release];
    [super dealloc];
}

- (id)init{
    self = [super init];
    self.visibility = CKViewTransitionContextVisibilityAlways;
    self.viewTransitionContexts = [NSMutableArray array];
    return self;
}


- (void)addTransitionContext:(CKViewTransitionContext*)context{
    [(NSMutableArray*)self.viewTransitionContexts addObject:context];
}

- (void)addTransitionContexts:(NSArray*)contexts{
    [(NSMutableArray*)self.viewTransitionContexts addObjectsFromArray:contexts];
}

- (CKViewTransitionContext*)viewTransitionContextNamed:(NSString*)name{
    if([self.name isEqualToString:name])
        return self;
        
    for(CKViewTransitionContext* context in self.viewTransitionContexts){
        CKViewTransitionContext* result = [context viewTransitionContextNamed:name];
        if(result)
            return result;
    }
    return nil;
}

- (void)removeAllViewTransitionContextsRecursive:(BOOL)recursive{
    if(recursive){
        for(CKViewTransitionContext* context in self.viewTransitionContexts){
            [context removeAllViewTransitionContextsRecursive:recursive];
        }
    }
    [(NSMutableArray*)self.viewTransitionContexts removeAllObjects];
}

- (CKViewTransitionContext*)reverseContext{
    return [CKViewTransitionContext contextByReversingContext:self];
}

+ (CKViewTransitionContext*)contextByReversingContext:(CKViewTransitionContext*)other{
    if(other == nil)
        return nil;
    
    CKViewTransitionContext* context = [[[CKViewTransitionContext alloc]init]autorelease];
    context.snapshot = other.snapshot;
    context.startAttributes = [[other.endAttributes copy]autorelease];
    context.endAttributes = [[other.startAttributes copy]autorelease];
    context.viewsToHideDuringTransition = [[other.viewsToHideDuringTransition copy]autorelease];
    context.viewBeforeSnapshot = other.viewBeforeSnapshot;
    context.additionalAnimations = other.additionalAnimations;
    
    NSMutableArray* reversedChildren = [NSMutableArray array];
    for(CKViewTransitionContext* child in other.viewTransitionContexts){
        [reversedChildren addObject:[CKViewTransitionContext contextByReversingContext:child]];
    }
    [context addTransitionContexts:reversedChildren];
    
    CKViewTransitionContextVisibility v = 0;
    if(other.visibility & CKViewTransitionContextVisibilityDuringAnimation){
        v = v | CKViewTransitionContextVisibilityDuringAnimation;
    }
    if(other.visibility & CKViewTransitionContextVisibilityBeforeAnimation){
        v = v | CKViewTransitionContextVisibilityAfterAnimation;
    }
    if(other.visibility & CKViewTransitionContextVisibilityAfterAnimation){
        v = v | CKViewTransitionContextVisibilityBeforeAnimation;
    }
    context.visibility = v;
    
    return context;
}


- (void)prepareForTransitionWithContext:(id <UIViewControllerContextTransitioning>)transitionContext preparedViews:(NSMutableSet*)preparedViews{
    if([preparedViews containsObject: self.snapshot])
        return;
    
    for(CKViewTransitionContext* child in self.viewTransitionContexts){
        [child prepareForTransitionWithContext:transitionContext preparedViews:preparedViews];
        [self.snapshot addSubview:child.snapshot];
    }
    
    [preparedViews addObject:self.snapshot];
    
    self.snapshot.hidden = !(self.visibility & CKViewTransitionContextVisibilityBeforeAnimation);
    
    if(!self.snapshot.hidden){
        for(UIView* view in self.viewsToHideDuringTransition){
            view.hidden = YES;
        }
        self.snapshot.center = self.startAttributes.center;
        self.snapshot.bounds = self.startAttributes.bounds;
        self.snapshot.alpha = self.startAttributes.alpha ;
        self.snapshot.layer.transform =  self.startAttributes.transform3D ;
    }
    
    if(self.snapshot.superview)
        return;
    
    [[transitionContext containerView]addSubview:self.snapshot];
}

- (void)willPerfomTransitionWithContext:(id <UIViewControllerContextTransitioning>)transitionContext{
    for(CKViewTransitionContext* child in self.viewTransitionContexts){
        [child willPerfomTransitionWithContext:transitionContext];
    }
    
    self.snapshot.hidden = !(self.visibility & CKViewTransitionContextVisibilityDuringAnimation);
    if(!self.snapshot.hidden){
        for(UIView* view in self.viewsToHideDuringTransition){
            view.hidden = YES;
        }
        self.snapshot.center = self.startAttributes.center;
        self.snapshot.bounds = self.startAttributes.bounds;
        self.snapshot.alpha = self.startAttributes.alpha ;
        self.snapshot.layer.transform =  self.startAttributes.transform3D ;
    }
}


- (void)didPerfomTransitionWithContext:(id <UIViewControllerContextTransitioning>)transitionContext{
    for(CKViewTransitionContext* child in self.viewTransitionContexts){
        [child didPerfomTransitionWithContext:transitionContext];
    }
    
    self.snapshot.hidden = !(self.visibility & CKViewTransitionContextVisibilityAfterAnimation);
}

- (void)performTransitionWithContext:(id <UIViewControllerContextTransitioning>)transitionContext{
    for(CKViewTransitionContext* child in self.viewTransitionContexts){
        [child performTransitionWithContext:transitionContext];
    }
    
    self.snapshot.center = self.endAttributes.center;
    self.snapshot.bounds = self.endAttributes.bounds;
    self.snapshot.alpha =  self.endAttributes.alpha;
    self.snapshot.layer.transform =  self.endAttributes.transform3D ;
    
    if(self.additionalAnimations){
        self.additionalAnimations();
    }
}

- (void)endTransition{
    for(CKViewTransitionContext* child in self.viewTransitionContexts){
        [child endTransition];
    }
    
    for(UIView* view in self.viewsToHideDuringTransition){
        view.hidden = NO;
    }
    [self.snapshot removeFromSuperview];
}



+ (UIView*)snapshotView:(UIView*)view withHierarchy:(BOOL)withHierarchy context:(CKViewTransitionContext*)context{
    context.viewBeforeSnapshot = view;
    
    UIView* snapshot = nil;
    if(withHierarchy){
        snapshot = [view transitionSnapshotWithViewHierarchy];
    }
    else {
        snapshot = [view transitionSnapshotWithoutViewHierarchy];
    }
    
    return snapshot;
}

@end
