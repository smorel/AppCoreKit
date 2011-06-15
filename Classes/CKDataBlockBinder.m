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
@property (nonatomic, retain) CKWeakRef* instanceRef;
@property (nonatomic, retain) CKWeakRef* targetRef;
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
			self,instanceRef ? instanceRef.object : @"(null)",keyPath];
}

- (void)reset{
	self.instanceRef = nil;
	self.keyPath = nil;
	self.block = nil;
	self.targetRef = nil;
	self.selector = nil;
}

- (id)releaseTarget:(CKWeakRef*)weakRef{
	[self unbindInstance:weakRef.object];
	[[CKBindingsManager defaultManager]unregister:self];
	return nil;
}

- (void)setTarget:(id)instance{
	if(instance){
		self.targetRef = [CKWeakRef weakRefWithObject:instance target:self action:@selector(releaseTarget:)];
	}
	else{
		self.targetRef = nil;
	}
}

- (id)releaseInstance:(CKWeakRef*)weakRef{
	[self unbindInstance:weakRef.object];
	[[CKBindingsManager defaultManager]unregister:self];
	return nil;
}

- (void)setInstance:(id)instance{
	if(instance){
		self.instanceRef = [CKWeakRef weakRefWithObject:instance target:self action:@selector(releaseInstance:)];
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
	else if(targetRef.object && [targetRef.object respondsToSelector:self.selector]){
		[targetRef.object performSelector:self.selector withObject:newValue];
	}
	else{
		NSAssert(NO,@"CKDataBlockBinder no action plugged");
	}
	
}


- (void) bind{
	[self unbind];
	if(instanceRef.object){
		[instanceRef.object addObserver:self
				   forKeyPath:keyPath
					  options:(NSKeyValueObservingOptionNew)
					  context:nil];
		binded = YES;
	}
}

-(void)unbind{
	[self unbindInstance:instanceRef.object];
}

- (void)unbindInstance:(id)instance{
	if(binded){
		[instance removeObserver:self
								forKeyPath:keyPath];
		binded = NO;
	}
}

@end