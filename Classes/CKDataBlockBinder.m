//
//  CKDataBlockBinder.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-02-17.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKDataBlockBinder.h"
#import "CKNSObject+Introspection.h"
#import "CKBindingsManager.h"

@interface CKDataBlockBinder ()
@property (nonatomic, retain) MAZeroingWeakRef* instanceRef;
@property (nonatomic, retain) MAZeroingWeakRef* targetRef;
- (void)unbindInstance:(id)instance;
@end

@implementation CKDataBlockBinder

@synthesize instanceRef;
@synthesize keyPath;
@synthesize block;
@synthesize targetRef;
@synthesize selector;

- (id)init{
	[super init];
	binded = NO;
	
	return self;
}

- (void) dealloc{
	[self unbind];
	[self reset];
	[super dealloc];
}

- (NSString*)description{
	return [NSString stringWithFormat:@"<CKDataBlockBinder : %p>{\ninstanceRef = %@\nkeyPath = %@}",
			self,instanceRef ? instanceRef.target : @"(null)",keyPath];
}

- (void)reset{
	self.instanceRef = nil;
	self.keyPath = nil;
	self.block = nil;
	self.targetRef = nil;
	self.selector = nil;
}

- (void)releaseTarget:(id)sender target:(id)target{
	[self unbindInstance:instanceRef.target];
	[[CKBindingsManager defaultManager]unregister:self];
}

- (void)setTarget:(id)instance{
	if(instance){
		self.targetRef = [[[MAZeroingWeakRef alloc] initWithTarget:instance]autorelease];
		[targetRef setDelegate:self action:@selector(releaseTarget:target:)];
	}
	else{
		self.targetRef = nil;
	}
}

- (void)releaseInstance:(id)sender target:(id)target{
	[self unbindInstance:target];
	[[CKBindingsManager defaultManager]unregister:self];
}

- (void)setInstance:(id)instance{
	if(instance){
		self.instanceRef = [[[MAZeroingWeakRef alloc] initWithTarget:instance]autorelease];
		[instanceRef setDelegate:self action:@selector(releaseInstance:target:)];
	}
	else{
		self.instanceRef = nil;
	}
}

- (id)retain{
	return [super retain];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context
{
	id newValue = [change objectForKey:NSKeyValueChangeNewKey];
	if(block){
		block(newValue);
	}
	else if(targetRef.target && [targetRef.target respondsToSelector:self.selector]){
		[targetRef.target performSelector:self.selector withObject:newValue];
	}
	else{
		NSAssert(NO,@"CKDataBlockBinder no action plugged");
	}
	
}


- (void) bind{
	[self unbind];
	if(instanceRef.target){
		[instanceRef.target addObserver:self
				   forKeyPath:keyPath
					  options:(NSKeyValueObservingOptionNew)
					  context:nil];
		binded = YES;
	}
}

-(void)unbind{
	[self unbindInstance:instanceRef.target];
}

- (void)unbindInstance:(id)instance{
	if(binded){
		[instance removeObserver:self
								forKeyPath:keyPath];
		binded = NO;
	}
}

@end