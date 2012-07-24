//
//  UIGestureRecognizer+BlockBasedInterface.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "UIGestureRecognizer+BlockBasedInterface.h"
#import <objc/runtime.h>

#import "CKDebug.h"

static char UIGestureRecognizerBlockKey;
static char UIGestureRecognizerShouldBeginBlockKey;
static char UIGestureRecognizerAllowedSimultaneousRecognizersKey;

typedef void(^UIGestureRecognizerBlock)(UIGestureRecognizer* gestureRecognizer);
typedef BOOL(^UIGestureRecognizerShouldBeginBlock)(UIGestureRecognizer* gestureRecognizer);


@implementation UIGestureRecognizer (CKBlockBasedInterface)
@dynamic allowedSimultaneousRecognizers;

- (void)executeGesture:(UIGestureRecognizer*)recognizer{
    UIGestureRecognizerBlock b = [self block];
    if(b){
        b(recognizer);
    }
}

- (void)setBlock:(UIGestureRecognizerBlock)block{
    objc_setAssociatedObject(self, 
                             &UIGestureRecognizerBlockKey,
                             block,
                             OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (UIGestureRecognizerBlock)block{
    return objc_getAssociatedObject(self, &UIGestureRecognizerBlockKey);
}

- (void)setShouldBeginBlock:(UIGestureRecognizerShouldBeginBlock)block{
    objc_setAssociatedObject(self, 
                             &UIGestureRecognizerShouldBeginBlockKey,
                             block,
                             OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    CKAssert(self.delegate == nil || self.delegate == self,@"We need to be our own delegate to manage this property");
    self.delegate = self;
}

- (UIGestureRecognizerShouldBeginBlock)shouldBeginBlock{
    return objc_getAssociatedObject(self, &UIGestureRecognizerShouldBeginBlockKey);
}

- (id)initWithBlock:(void(^)(UIGestureRecognizer* gestureRecognizer))block{
    self = [self initWithTarget:self action:@selector(executeGesture:)];
    [self setBlock:block];
    return self;
}

- (id)initWithBlock:(void(^)(UIGestureRecognizer* gestureRecognizer))block shouldBeginBlock:(BOOL(^)(UIGestureRecognizer* gestureRecognizer))shouldBeginBlock{
    self = [self initWithTarget:self action:@selector(executeGesture:)];
    [self setBlock:block];
    [self setShouldBeginBlock:shouldBeginBlock];
    return self;
}

- (void)setAllowedSimultaneousRecognizers:(NSArray *)allowedSimultaneousRecognizers{
    objc_setAssociatedObject(self, 
                             &UIGestureRecognizerAllowedSimultaneousRecognizersKey,
                             allowedSimultaneousRecognizers,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    CKAssert(self.delegate == nil || self.delegate == self,@"We need to be our own delegate to manage this property");
    self.delegate = self;
}

- (NSArray*)allowedSimultaneousRecognizers{
    return objc_getAssociatedObject(self, &UIGestureRecognizerAllowedSimultaneousRecognizersKey);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    if([[self allowedSimultaneousRecognizers]indexOfObjectIdenticalTo:otherGestureRecognizer] != NSNotFound){
        return YES;
    }
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    UIGestureRecognizerShouldBeginBlock b = [self shouldBeginBlock];
    if(b){
        return b(gestureRecognizer);
    }
    return YES;
}

- (void)cancel{
    self.enabled = NO;
    self.enabled = YES;
}

@end
