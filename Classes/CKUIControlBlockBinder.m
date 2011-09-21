//
//  CKUIControlBlockBinder.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-01-26.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKUIControlBlockBinder.h"
#import "CKNSObject+Introspection.h"
#import "CKImageView.h"
#import "CKBindingsManager.h"

@interface CKUIControlBlockBinder ()
@property (nonatomic, retain) CKWeakRef *controlRef;
@property (nonatomic, retain) CKWeakRef* targetRef;
- (void)unbindInstance:(id)instance;
@end


@implementation CKUIControlBlockBinder
@synthesize controlEvents;
@synthesize block;
@synthesize controlRef;
@synthesize targetRef;
@synthesize selector;

#pragma mark Initialization

-(id)init{
	[super init];
	binded = NO;
	self.controlEvents = UIControlEventTouchUpInside;//UIControlEventValueChanged;
    self.targetRef = [CKWeakRef weakRefWithObject:nil target:self action:@selector(releaseTarget:)];
    self.controlRef = [CKWeakRef weakRefWithObject:nil target:self action:@selector(releaseControl:)];
	return self;
}

-(void)dealloc{
	[self unbind];
	[self reset];
	self.controlRef = nil;
	self.targetRef = nil;
	[super dealloc];
}

- (NSString*)description{
	return [NSString stringWithFormat:@"<CKUIControlBlockBinder : %p>{\ncontrolRef = %@\ncontrolEvents = %d}",
			self,controlRef ? controlRef.object : @"(null)",controlEvents];
}

- (void)reset{
	self.controlEvents = UIControlEventTouchUpInside;//UIControlEventValueChanged;
	self.block = nil;
	self.controlRef.object = nil;
	self.targetRef.object = nil;
	self.selector = nil;
}

- (id)releaseTarget:(CKWeakRef*)weakRef{
	[self unbindInstance:weakRef.object];
	[[CKBindingsManager defaultManager]unregister:self];
	return nil;
}

- (void)setTarget:(id)instance{
	self.targetRef.object = instance;
}

- (id)releaseControl:(CKWeakRef*)weakRef{
	//[self unbindInstance:weakRef.object];
	[[CKBindingsManager defaultManager]unregister:self];
	return nil;
}

- (void)setControl:(UIControl*)control{
    self.controlRef.object = control;
}

//Update data in model
-(void)controlChange{
	if(block){
		block();
	}
	else if(targetRef.object && [targetRef.object respondsToSelector:self.selector]){
		[targetRef.object performSelector:self.selector];
	}
	else{
		NSAssert(NO,@"CKUIControlBlockBinder no action plugged");
	}
}

#pragma mark Public API
- (void)bind{
	[self unbind];

	if(self.controlRef.object){
		[(UIControl*)self.controlRef.object addTarget:self action:@selector(controlChange) forControlEvents:controlEvents];
	}
	binded = YES;
}

-(void)unbind{
	[self unbindInstance:controlRef.object];
}

- (void)unbindInstance:(id)instance{
	if(binded){
		if(instance){
			[(UIControl*)instance removeTarget:self action:@selector(controlChange) forControlEvents:controlEvents];
		}
		binded = NO;
	}
}

@end


