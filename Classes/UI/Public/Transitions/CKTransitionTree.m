//
//  CKTransitionTree.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-01.
//  Copyright (c) 2015 Sebastien Morel. All rights reserved.
//

#import "CKTransitionTree.h"

@interface CKTransitionNode()

- (void)prepareForTransitionWithContext:(id <UIViewControllerContextTransitioning>)transitionContext preparedViews:(NSMutableSet*)preparedViews;

- (void)performTransitionWithContext:(id <UIViewControllerContextTransitioning>)transitionContext
                                rate:(CGFloat)rate
                          completion:(void(^)(BOOL finished))completion;
- (void)endTransition;

@end


@interface CKTransitionTree()
@property(nonatomic,assign) NSTimeInterval startTime;
@property(nonatomic,copy) void(^percentCompleteBlock)(CGFloat percentComplete);
@property(nonatomic,retain) CADisplayLink* displayLink;
@end

@implementation CKTransitionTree

- (void)dealloc{
    [_percentCompleteBlock release];
    [_displayLink release];
    [_nodes release];
    [super dealloc];
}

+ (CKTransitionTree*)treeWithNodes:(NSArray*)nodes{
    CKTransitionTree* tree =  [[[CKTransitionTree alloc]init]autorelease];
    tree.nodes = nodes;
    return tree;
}

- (id)init{
    self = [super init];
    self.nodes = [NSMutableArray array];
    self.rate = 1.0f;
    return self;
}

- (void)nodesExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.contentType = [CKTransitionNode class];
}

- (void)prepareForTransitionWithContext:(id <UIViewControllerContextTransitioning>)transitionContext{
    NSMutableSet* preparedViews = [NSMutableSet set];
    
    for(CKTransitionNode* child in self.nodes){
        [child prepareForTransitionWithContext:transitionContext preparedViews:preparedViews];
    }
}

- (void)performTransitionWithContext:(id <UIViewControllerContextTransitioning>)transitionContext
                     percentComplete:(void(^)(CGFloat percentComplete))percentComplete
                          completion:(void(^)(BOOL finished))completion{
    
    if(self.nodes.count == 0){
        percentComplete(1.0f);
        completion(TRUE);
        return;
    }
    
    if(percentComplete){
        percentComplete(0.0f);
        self.percentCompleteBlock = percentComplete;
        [self setupDisplayLink];
    }
    
    __block NSInteger finishedCount = 0;
    
    for(CKTransitionNode* child in self.nodes){
        __block BOOL allFinished = YES;
        [child performTransitionWithContext:transitionContext rate:self.rate completion:^(BOOL finished) {
            allFinished = allFinished && finished;
            ++finishedCount;
            if(finishedCount == self.nodes.count){
                if(self.percentCompleteBlock){
                    self.percentCompleteBlock(1.0f);
                    self.percentCompleteBlock = nil;
                    [self cancelDisplayLink];
                }
                if(completion){
                    completion(allFinished);
                }
            }
        }];
    }
}

- (void)endTransition{
    for(CKTransitionNode* child in self.nodes){
        [child endTransition];
    }
}

- (CGFloat)totalDuration{
    CGFloat d = 0;
    
    for(CKTransitionNode* child in self.nodes){
        CGFloat dd = [child totalDuration];
        if(dd > d) d = dd;
    }
    
    return d * self.rate;
}

- (CKTransitionNode*)nodeNamed:(NSString*)name{
    for(CKTransitionNode* child in self.nodes){
        CKTransitionNode* n = [child nodeNamed:name];
        if(n){
            return n;
        }
    }
    
    return nil;
}

- (CKViewTransitionContext*)viewTransitionContextNamed:(NSString*)name{
    for(CKTransitionNode* child in self.nodes){
        CKViewTransitionContext* n = [child viewTransitionContextNamed:name];
        if(n){
            return n;
        }
    }
    
    return nil;
}

- (void)removeAllViewTransitionContexts{
    for(CKTransitionNode* child in self.nodes){
        [child removeAllViewTransitionContextsRecursive:YES];
    }
}

- (void)setupDisplayLink{
    self.startTime = CACurrentMediaTime();
    
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)cancelDisplayLink{
    [self.displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    [self.displayLink invalidate];
    self.displayLink = nil;
}

- (void)tick:(CADisplayLink *)link
{
    NSTimeInterval elapedTime = link.timestamp - self.startTime;
    NSTimeInterval duration = [self totalDuration];
    
    CGFloat percentComplete = MIN(1.0, elapedTime / duration);
    self.percentCompleteBlock(percentComplete);
}

@end

