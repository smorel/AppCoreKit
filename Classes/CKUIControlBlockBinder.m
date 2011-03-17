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
	return self;
}

-(void)dealloc{
	[self unbind];
	[self reset];
	[super dealloc];
}

- (NSString*)description{
	return [NSString stringWithFormat:@"<CKUIControlBlockBinder : %p>{\ncontrolRef = %@\ncontrolEvents = %d}",
			self,controlRef ? controlRef.target : @"(null)",controlEvents];
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
		__block CKUIControlBlockBinder* bself = self;
		[targetRef setCleanupBlock: ^(id target) {
			[self unbindInstance:controlRef.target];
			[[CKBindingsManager defaultManager]unregister:bself];
		}];
	}
	else{
		self.targetRef = nil;
	}
}

- (void)setControl:(UIControl*)control{
	if(control){
		self.controlRef = [[[MAZeroingWeakRef alloc] initWithTarget:control]autorelease];
		__block CKUIControlBlockBinder* bself = self;
		[controlRef setCleanupBlock: ^(id target) {
			[self unbindInstance:target];
			[[CKBindingsManager defaultManager]unregister:bself];
		}];
	}
	else{
		self.controlRef = nil;
	}
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
	[self unbindInstance:controlRef.target];
}

- (void)unbindInstance:(id)instance{
	if(binded){
		if(instance){
			[(UIControl*)instance removeTarget:self action:@selector(execute) forControlEvents:controlEvents];
		}
		binded = NO;
	}
}

@end


