//
//  CKTransitionNode.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-20.
//  Copyright (c) 2015 Sebastien Morel. All rights reserved.
//

#import "CKTransitionNode.h"
#import "CKPropertyExtendedAttributes.h"
#import "NSObject+Invocation.h"

@interface CKViewTransitionContext()

- (void)prepareForTransitionWithContext:(id <UIViewControllerContextTransitioning>)transitionContext preparedViews:(NSMutableSet*)preparedViews;
- (void)willPerfomTransitionWithContext:(id <UIViewControllerContextTransitioning>)transitionContext;
- (void)didPerfomTransitionWithContext:(id <UIViewControllerContextTransitioning>)transitionContext;
- (void)performTransitionWithContext:(id <UIViewControllerContextTransitioning>)transitionContext;
- (void)endTransition;

@end

@interface CKTransitionNode()
@property(nonatomic,retain) NSArray* viewTransitionContexts;
@property(nonatomic,retain) NSArray* nodes;
@end

@implementation CKTransitionNode

- (void)dealloc{
    [_viewTransitionContexts release];
    [_nodes release];
    [_name release];
    [super dealloc];
}

- (id)init{
    self = [super init];
    self.viewTransitionContexts = [NSMutableArray array];
    self.nodes = [NSMutableArray array];
    self.duration = .25f;
    self.options = UIViewAnimationOptionCurveEaseInOut;
    return self;
}

+ (CKTransitionNode*)nodeWithName:(NSString*)name{
    CKTransitionNode* node = [[[CKTransitionNode alloc]init]autorelease];
    node.name = name;
    return node;
}

- (CKTransitionNode*)nodeNamed:(NSString*)name{
    if([self.name isEqualToString:name])
        return self;
    
    for(CKTransitionNode* child in self.nodes){
        CKTransitionNode* n = [child nodeNamed:name];
        if(n){
            return n;
        }
    }
    
    return nil;
}

- (CKViewTransitionContext*)viewTransitionContextNamed:(NSString*)name{
    for(CKViewTransitionContext* context in self.viewTransitionContexts){
        CKViewTransitionContext* n = [context viewTransitionContextNamed:name];
        if(n){
            return n;
        }
    }
    
    for(CKTransitionNode* child in self.nodes){
        CKViewTransitionContext* n = [child viewTransitionContextNamed:name];
        if(n){
            return n;
        }
    }
    
    return nil;
}


- (void)optionsExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKBitMaskDefinition(@"UIViewAnimationOptions",
                                                    UIViewAnimationOptionLayoutSubviews,
                                                    UIViewAnimationOptionAllowUserInteraction,
                                                    UIViewAnimationOptionBeginFromCurrentState     ,
                                                    UIViewAnimationOptionRepeat                    ,
                                                    UIViewAnimationOptionAutoreverse               ,
                                                    UIViewAnimationOptionOverrideInheritedDuration ,
                                                    UIViewAnimationOptionOverrideInheritedCurve ,
                                                    UIViewAnimationOptionAllowAnimatedContent    ,
                                                    UIViewAnimationOptionShowHideTransitionViews  ,
                                                    UIViewAnimationOptionOverrideInheritedOptions ,
                                                    
                                                    UIViewAnimationOptionCurveEaseInOut      ,
                                                    UIViewAnimationOptionCurveEaseIn    ,
                                                    UIViewAnimationOptionCurveEaseOut   ,
                                                    UIViewAnimationOptionCurveLinear   ,
                                                    
                                                    UIViewAnimationOptionTransitionNone      ,
                                                    UIViewAnimationOptionTransitionFlipFromLeft ,
                                                    UIViewAnimationOptionTransitionFlipFromRight  ,
                                                    UIViewAnimationOptionTransitionCurlUp      ,
                                                    UIViewAnimationOptionTransitionCurlDown  ,
                                                    UIViewAnimationOptionTransitionCrossDissolve   ,
                                                    UIViewAnimationOptionTransitionFlipFromTop,
                                                    UIViewAnimationOptionTransitionFlipFromBottom
                                                    );
}

- (void)addTransitionContext:(CKViewTransitionContext*)context{
    [(NSMutableArray*)self.viewTransitionContexts addObject:context];
}

- (void)addTransitionContexts:(NSArray*)contexts{
    [(NSMutableArray*)self.viewTransitionContexts addObjectsFromArray:contexts];
}

- (void)removeAllViewTransitionContextsRecursive:(BOOL)recursive{
    for(CKViewTransitionContext* context in self.viewTransitionContexts){
        [context removeAllViewTransitionContextsRecursive:YES];
    }
    
    [(NSMutableArray*)self.viewTransitionContexts removeAllObjects];
    
    if(!recursive)
        return;
    
    for(CKTransitionNode* child in self.nodes){
        [child removeAllViewTransitionContextsRecursive:recursive];
    }
}

- (void)addChildNode:(CKTransitionNode*)node{
    [(NSMutableArray*)self.nodes addObject:node];
}

- (void)addChildrenNodes:(NSArray*)nodes{
    [(NSMutableArray*)self.nodes addObjectsFromArray:nodes];
}

- (void)nodesExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.contentType = [CKTransitionNode class];
}

- (void)prepareForTransitionWithContext:(id <UIViewControllerContextTransitioning>)transitionContext preparedViews:(NSMutableSet*)preparedViews{
    for(CKViewTransitionContext* context in self.viewTransitionContexts){
        [context prepareForTransitionWithContext:transitionContext preparedViews:preparedViews];
    }
    
    // dispatch_async(dispatch_get_main_queue(), ^{
        for(CKTransitionNode* child in self.nodes){
            [child prepareForTransitionWithContext:transitionContext preparedViews:preparedViews];
        }
    // });
}

- (void)performViewContextsTransitionWithContext:(id <UIViewControllerContextTransitioning>)transitionContext{
    for(CKViewTransitionContext* context in self.viewTransitionContexts){
        [context performTransitionWithContext:transitionContext];
    }
}

- (void)performChildNodesTransitionWithContext:(id <UIViewControllerContextTransitioning>)transitionContext
                                          rate:(CGFloat)rate
                                    completion:(void(^)(BOOL finished))completion{
    
    for(CKViewTransitionContext* context in self.viewTransitionContexts){
        [context didPerfomTransitionWithContext:transitionContext];
    }
    
    if(self.nodes.count == 0){
        completion(TRUE);
        return;
    }
    
    __block NSInteger finishedCount = 0;
    
    for(CKTransitionNode* child in self.nodes){
        __block BOOL allFinished = YES;
        [child performTransitionWithContext:transitionContext rate:rate completion:^(BOOL finished) {
            allFinished = allFinished && finished;
            ++finishedCount;
            
            if(finishedCount == self.nodes.count){
                if(completion){
                    completion(allFinished);
                }
            }
        }];
    }
}

- (void)performTransitionWithContext:(id <UIViewControllerContextTransitioning>)transitionContext
                                rate:(CGFloat)rate
                          completion:(void(^)(BOOL finished))completion{
                              
    __block CKTransitionNode* node = self;
    void(^animation)() = ^(){
        [node performViewContextsTransitionWithContext:transitionContext];
    };
    
    void(^animateChildren)(BOOL finished) = ^(BOOL finished){
        [node performChildNodesTransitionWithContext:transitionContext rate:rate completion:completion];
    };
    
    for(CKViewTransitionContext* context in self.viewTransitionContexts){
        [context willPerfomTransitionWithContext:transitionContext];
    }
    
    if(self.damping == 0){
        [UIView animateWithDuration:self.duration * rate delay:self.delay * rate options:self.options | UIViewAnimationOptionLayoutSubviews animations:animation completion:animateChildren];
    }else{
        [UIView animateWithDuration:self.duration * rate delay:self.delay * rate usingSpringWithDamping:self.damping initialSpringVelocity:self.initialVelocity options:self.options | UIViewAnimationOptionLayoutSubviews animations:animation completion:animateChildren];
    }
}

- (void)endTransition{
    for(CKViewTransitionContext* context in self.viewTransitionContexts){
        [context endTransition];
    }
    
    for(CKTransitionNode* child in self.nodes){
        [child endTransition];
    }
}

- (CGFloat)totalDuration{
    CGFloat d = self.duration + self.delay;
    
    CGFloat max = 0;
    for(CKTransitionNode* child in self.nodes){
        CGFloat dd = [child totalDuration];
        if(dd > max) max = dd;
    }
    d += max;
    
    return d;
}

@end
