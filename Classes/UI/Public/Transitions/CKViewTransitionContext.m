//
//  CKViewTransitionContext.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-20.
//  Copyright (c) 2015 Sebastien Morel. All rights reserved.
//

#import "CKViewTransitionContext.h"
#import "UIView+Snapshot.h"

@interface CKViewTransitionContext()
@property(nonatomic,retain) NSArray* viewsToHideDuringTransition;
@property(nonatomic,retain,readwrite) NSArray* viewTransitionContexts;
@end


@implementation CKViewTransitionContext

- (void)dealloc{
    [_viewsToHideDuringTransition release];
    [_viewTransitionContexts release];
    [_name release];
    [_snapshot release];
    [_startAttributes release];
    [_endAttributes release];
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
    context.startAttributes = [other.endAttributes copy];
    context.endAttributes = [other.startAttributes copy];
    context.viewsToHideDuringTransition = [other.viewsToHideDuringTransition copy];
    
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
        self.snapshot.frame = self.startAttributes.frame ;
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
        self.snapshot.frame = self.startAttributes.frame ;
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
    
    self.snapshot.frame = self.endAttributes.frame;
    self.snapshot.alpha =  self.endAttributes.alpha;
    self.snapshot.layer.transform =  self.endAttributes.transform3D ;
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

+ (UIView*)snapshotView:(UIView*)view withLayerAttributesAfterUpdate:(BOOL)afterUpdate{
    
    UIView* snapshot = nil;
    if(afterUpdate){
        snapshot = [view snapshotViewAfterScreenUpdates:YES];
    }
    else {
        snapshot = [[[UIImageView alloc]initWithImage:[view snapshotWithoutSubviews]]autorelease];
    }
    
    /*
    snapshot.layer.cornerRadius = view.layer.cornerRadius;
    snapshot.layer.borderColor = view.layer.borderColor;
    snapshot.layer.borderWidth = view.layer.borderWidth;
    snapshot.layer.shadowColor = view.layer.shadowColor;
    snapshot.layer.shadowOffset = view.layer.shadowOffset;
    snapshot.layer.shadowOpacity = view.layer.shadowOpacity;
    snapshot.layer.shadowRadius = view.layer.shadowRadius;
    snapshot.backgroundColor = view.backgroundColor;
    snapshot.clipsToBounds = view.clipsToBounds;
     */
    
    return snapshot;
}

@end
