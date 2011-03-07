//
//  CKDataBlockBinder.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-02-17.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKDataBlockBinder.h"
#import "CKNSObject+Introspection.h"

@implementation CKDataBlockBinder

@synthesize instance;
@synthesize keyPath;
@synthesize executionBlock;

- (id)init{
	[super init];
	binded = NO;
	return self;
}

- (void) dealloc{
	[self unbind];
	self.instance = nil;
	self.keyPath = nil;
	self.executionBlock = nil;
	[super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context
{
	id newValue = [change objectForKey:NSKeyValueChangeNewKey];
	executionBlock(newValue);
}


- (void) bind{
	[self unbind];
	[instance addObserver:self
				forKeyPath:keyPath
				   options:(NSKeyValueObservingOptionNew)
				  context:nil];
	binded = YES;
}

-(void)unbind{
	if(binded){
		[instance removeObserver:self
					  forKeyPath:keyPath];
		binded = NO;
	}
}

+(CKDataBlockBinder*) dataBlockBinder:(id)instance keyPath:(NSString*)keyPath executionBlock:(CKDataExecutionBlock)executionBlock{
	CKDataBlockBinder* binder = [[[CKDataBlockBinder alloc]init]autorelease];
	binder.instance = instance;
	binder.keyPath = keyPath;
	binder.executionBlock = executionBlock;
	[binder bind];
	return binder;
}


@end