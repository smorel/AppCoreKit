//
//  CKAnimation.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 12-03-28.
//  Copyright (c) 2012 WhereCloud Inc. All rights reserved.
//

#import "CKAnimation.h"
#import "CKAnimationPrivate.h"
#import "CKAnimationManager.h"
#import "CKWeakRef.h"


@interface CKAnimation()
@property(nonatomic,retain)CKWeakRef* animationManagerRef;
@property(nonatomic,assign,readwrite) CKAnimationManager* animationManager;
@end

@implementation CKAnimation
@synthesize duration = _duration;
@synthesize options = _options;
@synthesize updateBlock = _updateBlock;
@synthesize cumulatedTime = _cumulatedTime;
@synthesize animationManagerRef = _animationManagerRef;
@synthesize animationManager = _animationManager;
@synthesize eventBlock = _eventBlock;

- (void)dealloc{
    [_eventBlock release];
    [_updateBlock release];
    [_animationManagerRef release];
    [super dealloc];
}

+ (CKAnimation*)animation{
    return [[[CKAnimation alloc]init]autorelease];
}

- (void)setAnimationManager:(CKAnimationManager *)animationManager{
    if(self.animationManager){
        [self.animationManager unregisterAnimation:self];
    }
    self.animationManagerRef = [CKWeakRef weakRefWithObject:animationManager];
}

- (CKAnimationManager*)animationManager{
    return [_animationManagerRef object];
}

- (id)init{
    self = [super init];
    _duration = 0;
    return self;
}


- (CGFloat)applyModifierstoRatio:(CGFloat)ratio{
    if(self.cumulatedTime >= _duration && !(_options & CKAnimationOptionLoop)){
        ratio = 1;
    }
    
    if(_options & CKAnimationOptionAutoReverse){
        if(ratio >= 0.5){
            ratio = 1 - (2 * (ratio - 0.5));
        }else{
            ratio = 2 * ratio;
        }
    }
    
    if(_options & CKAnimationOptionBackwards){
        ratio = 1 - ratio;
    }
    return ratio;
}

- (void)updateUsingTimestamp:(NSTimeInterval)timestamp duration:(NSTimeInterval)frameDuration{
    if(_duration == 0)
        return;
    
    
    CGFloat d = _duration;
    if(_options & CKAnimationOptionAutoReverse){
        d *= 2;
    }
    
    CGFloat previousRelativeTime = fmod(_cumulatedTime,d);
    
    self.cumulatedTime += frameDuration;
    
    CGFloat relativeTime = fmod(_cumulatedTime,d);
    
    if(relativeTime < previousRelativeTime && (_options & CKAnimationOptionLoop)){
        if(_eventBlock){
            _eventBlock(self,CKAnimationEventLoop);
        }
    }
    
    CGFloat ratio = relativeTime / d;
    ratio = [self applyModifierstoRatio:ratio];
    [self updateUsingRatio:ratio];
    
    if(self.cumulatedTime >= d && !(_options & CKAnimationOptionLoop)){
        [self.animationManager unregisterAnimation:self];
        if(_eventBlock){
            _eventBlock(self,CKAnimationEventEnd);
        }
    }
}

- (void)updateUsingRatio:(CGFloat)ratio{
    //Implements in inherited classes
}

- (void)startInManager:(CKAnimationManager*)manager{
    self.animationManager = manager;
    _cumulatedTime = 0;
    
    [self.animationManager registerAnimation:self];
    if(_eventBlock){
        _eventBlock(self,CKAnimationEventStart);
    }
    [self updateUsingRatio:[self applyModifierstoRatio:0]];
}


- (void)stop{
    [self.animationManager unregisterAnimation:self];
    if(_eventBlock){
        _eventBlock(self,CKAnimationEventCancelled);
    }
}

@end
