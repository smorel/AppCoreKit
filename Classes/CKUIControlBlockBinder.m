//
//  CKUIControlBlockBinder.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-01-26.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKUIControlBlockBinder.h"
#import "CKNSObject+CKRuntime.h"
#import "CKImageView.h"
#import "CKBindingsManager.h"

@interface CKUIControlBlockBinder ()
#ifdef ENABLE_WEAK_REF_PROTECTION
@property (nonatomic, retain) CKWeakRef *controlRef;
@property (nonatomic, retain) CKWeakRef* targetRef;
#endif
- (void)unbindInstance:(id)instance;
@end


@implementation CKUIControlBlockBinder
#ifdef ENABLE_WEAK_REF_PROTECTION
@synthesize controlRef;
@synthesize targetRef;
#endif
@synthesize controlEvents;
@synthesize block;
@synthesize selector;
@synthesize target;
@synthesize control;

#pragma mark Initialization

-(id)init{
    if (self = [super init]) {
        binded = NO;
        self.controlEvents = UIControlEventTouchUpInside;//UIControlEventValueChanged;
#ifdef ENABLE_WEAK_REF_PROTECTION
        self.targetRef = [CKWeakRef weakRefWithObject:nil target:self action:@selector(releaseTarget:)];
        self.controlRef = [CKWeakRef weakRefWithObject:nil target:self action:@selector(releaseControl:)];
#endif
    }
    return self;
}

-(void)dealloc{
	[self unbind];
	[self reset];
#ifdef ENABLE_WEAK_REF_PROTECTION
	self.controlRef = nil;
	self.targetRef = nil;
#endif
	[super dealloc];
}

- (NSString*)description{
	return [NSString stringWithFormat:@"<CKUIControlBlockBinder : %p>{\ncontrolRef = %@\ncontrolEvents = %d}",
			self,self.control ? self.control : @"(null)",controlEvents];
}

- (void)reset{
    [super reset];
	self.controlEvents = UIControlEventTouchUpInside;//UIControlEventValueChanged;
	self.block = nil;
	self.control = nil;
	self.target = nil;
	self.selector = nil;
}

#ifdef ENABLE_WEAK_REF_PROTECTION
- (id)releaseTarget:(CKWeakRef*)weakRef{
    [self unbindInstance:self.control];
    [[CKBindingsManager defaultManager]unregister:self];
	return nil;
}

- (void)setTarget:(id)theinstance{
	self.targetRef.object = theinstance;
}

- (id)target{
    return self.targetRef.object;
}

- (id)releaseControl:(CKWeakRef*)weakRef{
    //[self unbindInstance:weakRef.object];
    [[CKBindingsManager defaultManager]unregister:self];
	return nil;
}

- (void)setControl:(UIControl*)thecontrol{
    self.controlRef.object = thecontrol;
}

- (id)control{
    return self.controlRef.object;
}
#endif

- (void)execute{
	if(block){
		block();
	}
	else if(self.target && [self.target respondsToSelector:self.selector]){
		[self.target performSelector:self.selector];
	}
	else{
		//NSAssert(NO,@"CKUIControlBlockBinder no action plugged");
	}
}

//Update data in model
-(void)controlChange{
    if(self.contextOptions & CKBindingsContextPerformOnMainThread){
        [self performSelectorOnMainThread:@selector(execute) withObject:nil waitUntilDone:(self.contextOptions & CKBindingsContextWaitUntilDone)];
    }
    else {
        [self performSelector:@selector(execute) onThread:[NSThread currentThread] withObject:nil waitUntilDone:(self.contextOptions & CKBindingsContextWaitUntilDone)];
    }
}

#pragma mark Public API
- (void)bind{
	[self unbind];

	if(self.control){
		[(UIControl*)self.control addTarget:self action:@selector(controlChange) forControlEvents:controlEvents];
	}
	binded = YES;
}

-(void)unbind{
	[self unbindInstance:self.control];
}

- (void)unbindInstance:(id)theinstance{
	if(binded){
		if(theinstance){
			[(UIControl*)theinstance removeTarget:self action:@selector(controlChange) forControlEvents:controlEvents];
		}
		binded = NO;
	}
}

@end


