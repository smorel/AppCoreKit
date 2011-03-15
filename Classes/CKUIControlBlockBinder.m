//
//  CKViewExecutionBlock.m
//  NFB
//
//  Created by Sebastien Morel on 11-01-26.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKUIControlBlockBinder.h"
#import "CKNSObject+Introspection.h"
#import "CKImageView.h"
#import "CKBindingsManager.h"

@interface CKUIControlBlockBinder ()
@property (nonatomic, retain) MAZeroingWeakRef *controlRef;
@property (nonatomic, retain) MAZeroingWeakRef* targetRef;
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
	return self;
}

-(void)dealloc{
	[self unbind];
	[self reset];
	[super dealloc];
}

- (void)reset{
	self.controlEvents = UIControlEventTouchUpInside;//UIControlEventValueChanged;
	self.block = nil;
	self.controlRef = nil;
	self.targetRef = nil;
	self.selector = nil;
}

- (void)setTarget:(id)instance{
	if(instance){
		self.targetRef = [[[MAZeroingWeakRef alloc] initWithTarget:instance]autorelease];
		[targetRef setCleanupBlock: ^(id target) {
			[[CKBindingsManager defaultManager]unbind:self];
		}];
	}
	else{
		self.targetRef = nil;
	}
}

- (void)setControl:(UIControl*)control{
	if(control){
		self.controlRef = [[[MAZeroingWeakRef alloc] initWithTarget:control]autorelease];
		[controlRef setCleanupBlock: ^(id target) {
			[[CKBindingsManager defaultManager]unbind:self];
		}];
	}
	else{
		self.controlRef = nil;
	}
}

-(NSString*)description{
	return [NSString stringWithFormat:@"CKUIControlBlockBinder count=%d",[self retainCount]];
}

//Update data in model
-(void)controlChange{
	if(block){
		block();
	}
	else if(targetRef.target && [targetRef.target respondsToSelector:self.selector]){
		[targetRef.target performSelector:self.selector];
	}
	else{
		NSAssert(NO,@"CKUIControlBlockBinder no action plugged");
	}
}

#pragma mark Public API
- (void)bind{
	[self unbind];

	if(self.controlRef.target){
		[(UIControl*)self.controlRef.target addTarget:self action:@selector(controlChange) forControlEvents:controlEvents];
	}
	binded = YES;
}

-(void)unbind{
	if(binded){
		if(self.controlRef.target){
			[(UIControl*)self.controlRef.target removeTarget:self action:@selector(execute) forControlEvents:controlEvents];
		}
		binded = NO;
	}
}

@end


