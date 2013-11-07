//
//  CKAnimationManager.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 12-03-28.
//  Copyright (c) 2012 WhereCloud Inc. All rights reserved.
//

#import "CKAnimationManager.h"
#import "CKAnimation.h"
#import <QuartzCore/QuartzCore.h>

//TEST
#import "CKAnimationInterpolator.h"

@interface CKAnimation()
- (void)updateUsingTimestamp:(NSTimeInterval)timestamp duration:(NSTimeInterval)duration;
@end

@interface CKAnimationManager()
@property(nonatomic,retain)CADisplayLink* displayLink;
@property(nonatomic,retain,readwrite) NSArray* animations;
@property(nonatomic,retain,readwrite) NSMutableSet* animationsToAdd;
@property(nonatomic,retain,readwrite) NSMutableSet* animationsToRemove;
@property(nonatomic,assign) NSTimeInterval startTime;
@property(nonatomic,assign) NSTimeInterval previousFrameTime;
@end

@implementation CKAnimationManager
@synthesize displayLink = _displayLink;
@synthesize animations = _animations;
@synthesize preUpdateBlock = _preUpdateBlock;
@synthesize postUpdateBlock = _postUpdateBlock;
@synthesize animationsToAdd = _animationsToAdd;
@synthesize animationsToRemove = _animationsToRemove;
@synthesize startTime = _startTime;
@synthesize previousFrameTime = _previousFrameTime;

- (void)dealloc{
    [self unregisterFromScreen];
    [_animations release];
    [_preUpdateBlock release];
    [_postUpdateBlock release];
    [_animationsToAdd release];
    [_animationsToRemove release];
    [super dealloc];
}

- (id)init{
    self = [super init];
    
    self.animations = [NSMutableArray array];
    self.startTime = -1;
    
    return self;
}

-(void)registerInScreen:(UIScreen*)screen{
    self.displayLink = [screen displayLinkWithTarget:self selector:@selector(update:)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)unregisterFromScreen{
    [_displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [_displayLink invalidate];
    [_displayLink release];
    _displayLink = nil;
}

- (void)registerAnimation:(CKAnimation*)animation{
    if(!_animationsToAdd){
        self.animationsToAdd = [NSMutableSet set];
    }
    [_animationsToAdd addObject:animation];
    
    NSInteger index = [_animations indexOfObjectIdenticalTo:animation];
    if(index == NSNotFound){
    }
}

- (void)unregisterAnimation:(CKAnimation*)animation{
    if(!_animationsToRemove){
        self.animationsToRemove = [NSMutableSet set];
    }
    [_animationsToRemove addObject:animation];
}

- (void)stopAllAnimations{
    [((NSMutableArray*)_animations) removeAllObjects];
}

- (void)update:(CADisplayLink *)sender{
    if(self.startTime == -1){
        self.startTime = sender.timestamp;
        self.previousFrameTime = self.startTime;
    }
    
    for(CKAnimation* animation in self.animationsToRemove){
        NSInteger index = [_animations indexOfObjectIdenticalTo:animation];
        if(index != NSNotFound){
            [(NSMutableArray*)_animations removeObjectAtIndex:index];
        }
        
        if([self.animationsToAdd containsObject:animation]){
            [(NSMutableSet*)self.animationsToAdd removeObject:animation];
        }
    }
    [self.animationsToRemove removeAllObjects];
    
    for(CKAnimation* animation in self.animationsToAdd){
        NSInteger index = [_animations indexOfObjectIdenticalTo:animation];
        if(index == NSNotFound){
            [(NSMutableArray*)_animations addObject:animation];
        }
    }
    [self.animationsToAdd removeAllObjects];
    
    CGFloat elapsedTime = sender.timestamp - self.previousFrameTime;
    self.previousFrameTime = sender.timestamp;
    
    if(_preUpdateBlock){
        _preUpdateBlock(self,sender.timestamp,elapsedTime);
    }
    for(CKAnimation* animation in _animations){
        [animation updateUsingTimestamp:sender.timestamp duration:elapsedTime];
    }
    if(_postUpdateBlock){
        _postUpdateBlock(self,sender.timestamp,elapsedTime);
    }
}

@end
