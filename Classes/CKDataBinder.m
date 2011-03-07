//
//  CKConnections.m
//  CloudKitApp
//
//  Created by Sebastien Morel on 11-01-22.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKDataBinder.h"
#import "CKValueTransformer.h"


@implementation CKDataBinder
@synthesize instance1;
@synthesize keyPath1;
@synthesize instance2;
@synthesize keyPath2;

- (id)init{
	[super init];
	binded = NO;
	return self;
}

- (void)dealloc{
	[self unbind];
	self.instance1 = nil;
	self.keyPath1 = nil;
	self.instance2 = nil;
	self.keyPath2 = nil;
	[super dealloc];
}

-(void)bind{
	[self unbind];
	
	id value = [instance1 valueForKey:keyPath1];
	[instance2 setValue:value forKeyPath:keyPath2];
	
	[instance1 addObserver:self
				forKeyPath:keyPath1
				   options:(NSKeyValueObservingOptionNew)
				   context:nil];
	[instance2 addObserver:self
				forKeyPath:keyPath2
				   options:(NSKeyValueObservingOptionNew)
				   context:nil];
	binded = YES;
}

- (void)unbind{
	if(binded){
		[instance1 removeObserver:self
					   forKeyPath:keyPath1];
		[instance2 removeObserver:self
					   forKeyPath:keyPath2];
		binded = NO;
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context
{
	id newValue = [change objectForKey:NSKeyValueChangeNewKey];
	
	id dataValue1 = [instance1 valueForKeyPath:keyPath1];
	if(![newValue isEqual:dataValue1]){
		[instance1 setValue:[CKValueTransformer transformValue:newValue toClass:[dataValue1 class]] forKeyPath:keyPath1];
	}
	
	id dataValue2 = [instance2 valueForKeyPath:keyPath2];
	if(![newValue isEqual:dataValue2]){
		[instance2 setValue:[CKValueTransformer transformValue:newValue toClass:[dataValue2 class]] forKeyPath:keyPath2];
	}
}

+(CKDataBinder*)binderForObject:(id)object1 keyPath:(NSString*)keyPath object2:(id)object2 keyPath2:(NSString*)keyPath2{
	CKDataBinder* binder = [[[CKDataBinder alloc]init]autorelease];
	binder.instance1 = object1;
	binder.keyPath1 = keyPath;
	binder.instance2 = object2;
	binder.keyPath2 = keyPath2;
	[binder bind];
	return binder;
}


@end
