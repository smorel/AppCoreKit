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
    self.targetRef = [CKWeakRef weakRefWithObject:nil target:self action:@selector(releaseTarget:)];
    self.instanceRef = [CKWeakRef weakRefWithObject:nil target:self action:@selector(releaseInstance:)];
	return self;
}

- (void) dealloc{
	[self unbind];
	[self reset];
    self.instanceRef = nil;
    self.targetRef = nil;
	[super dealloc];
}

- (NSString*)description{
	return [NSString stringWithFormat:@"<CKDataBlockBinder : %p>{\ninstanceRef = %@\nkeyPath = %@}",
			self,instanceRef ? instanceRef.object : @"(null)",keyPath];
}

- (void)reset{
    [super reset];
	self.instanceRef.object = nil;
	self.keyPath = nil;
	self.block = nil;
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

- (id)releaseInstance:(CKWeakRef*)weakRef{
	[self unbindInstance:weakRef.object];
	[[CKBindingsManager defaultManager]unregister:self];
	return nil;
}

- (void)setInstance:(id)instance{
    self.instanceRef.object = instance;
}

- (id)retain{
	return [super retain];
}

- (void)executeWithValue:(id)value{
    if(block){
		block(value);
	}
	else if(targetRef.object && [targetRef.object respondsToSelector:self.selector]){
		[targetRef.object performSelector:self.selector withObject:value];
	}
	else{
		//NSAssert(NO,@"CKDataBlockBinder no action plugged");
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context
{
	id newValue = [change objectForKey:NSKeyValueChangeNewKey];
    
    if(self.contextOptions & CKBindingsContextPerformOnMainThread){
        [self performSelectorOnMainThread:@selector(executeWithValue:) withObject:newValue waitUntilDone:(self.contextOptions & CKBindingsContextWaitUntilDone)];
    }
    else {
        [self performSelector:@selector(executeWithValue:) onThread:[NSThread currentThread] withObject:newValue waitUntilDone:(self.contextOptions & CKBindingsContextWaitUntilDone)];
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