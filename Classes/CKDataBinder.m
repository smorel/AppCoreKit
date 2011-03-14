//
//  CKConnections.m
//  CloudKitApp
//
//  Created by Sebastien Morel on 11-01-22.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKDataBinder.h"
#import "CKValueTransformer.h"
#import "CKBindingsManager.h"
#import "CKNSObject+Introspection.h"


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
	CKObjectProperty* property = [NSObject property:instance2 forKeyPath:keyPath2];
	[instance2 setValue:[CKValueTransformer transformValue:value toClass:property.type] forKeyPath:keyPath2];
	
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
		//Unregister only when the binding is invalidated with weakRefs
		//[[CKBindingsManager defaultManager]unregister:self];
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
	{
		CKObjectProperty* property = [NSObject property:instance1 forKeyPath:keyPath1];
		id newValue1 = [CKValueTransformer transformValue:newValue toClass:property.type];
		if(![newValue1 isEqual:dataValue1]){
			[instance1 setValue:newValue1 forKeyPath:keyPath1];
		}
	}
	
	id dataValue2 = [instance2 valueForKeyPath:keyPath2];
	{
		CKObjectProperty* property = [NSObject property:instance2 forKeyPath:keyPath2];
		id newValue2 = [CKValueTransformer transformValue:newValue toClass:property.type];
		if(![newValue2 isEqual:dataValue2]){
			[instance2 setValue:newValue2 forKeyPath:keyPath2];
		}
	}
}

//Shallow copy for references in dictionaries
- (id) copyWithZone:(NSZone *)zone {
	return self;
}

@end
