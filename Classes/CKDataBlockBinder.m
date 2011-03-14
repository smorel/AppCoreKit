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

@implementation CKDataBlockBinder

@synthesize instance;
@synthesize keyPath;
@synthesize block;
@synthesize target;
@synthesize selector;

- (id)init{
	[super init];
	binded = NO;
	return self;
}

- (void) dealloc{
	[self unbind];
	self.instance = nil;
	self.keyPath = nil;
	self.block = nil;
	self.target = nil;
	self.selector = nil;
	[super dealloc];
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
	else if(target && [target respondsToSelector:self.selector]){
		[target performSelector:self.selector withObject:newValue];
	}
	else{
		NSAssert(NO,@"CKDataBlockBinder no action plugged");
	}
	
}


- (void) bind{
	[self unbind];
	if(instance){
		[instance addObserver:self
				   forKeyPath:keyPath
					  options:(NSKeyValueObservingOptionNew)
					  context:nil];
		binded = YES;
	}
}

-(void)unbind{
	if(binded){
		[instance removeObserver:self
					  forKeyPath:keyPath];
		//Unregister only when the binding is invalidated with weakRefs
		//[[CKBindingsManager defaultManager]unregister:self];
		binded = NO;
	}
}

//Shallow copy for references in dictionaries
- (id) copyWithZone:(NSZone *)zone {
	return self;
}

@end