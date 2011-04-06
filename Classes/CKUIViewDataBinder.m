//
//  CKViewDataBinder.m
//  CloudKitApp
//
//  Created by Sebastien Morel on 11-01-26.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKUIViewDataBinder.h"
#import "CKNSObject+Introspection.h"
#import "CKValueTransformer.h"
#import "CKBindingsManager.h"


@implementation CKUIViewDataBinder
@synthesize keyPath;
@synthesize target;
@synthesize targetKeyPath;
@synthesize control;
@synthesize controlEvents;

#pragma mark Initialization

-(id)init{
	[super init];
	controlEvents = UIControlEventValueChanged;
	binded = NO;
	return self;
}

-(void)dealloc{
	[self unbind];
	self.target = nil;
	self.targetKeyPath = nil;
	self.control = nil;
	self.keyPath = nil;
	[super dealloc];
}

-(NSString*)description{
	return [NSString stringWithFormat:@"CKUIViewDataBinder count=%d %@ %@",[self retainCount],target,targetKeyPath];
}

#pragma mark Private API

//Update data in model
-(void)controlChange{
	id newValue = [self.control valueForKeyPath:keyPath];
	id dataValue = [target valueForKeyPath:targetKeyPath];
	if(![newValue isEqual:dataValue]){
		[target setValue:[CKValueTransformer transformValue:newValue toClass:[dataValue class]] forKeyPath:targetKeyPath];
	}
}


//update data in control
- (void)observeValueForKeyPath:(NSString *)theKeyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context
{
	id newValue = [change objectForKey:NSKeyValueChangeNewKey];

	if(self.control){
		CKObjectProperty* propertyDescriptor = [NSObject property:self.control forKeyPath:keyPath];
		[self.control setValue:[CKValueTransformer transformValue:newValue toClass:propertyDescriptor.type] forKeyPath:keyPath];
	}
}

#pragma mark Public API
- (void)bind{
	[self unbind];
	if(self.control){
		id dataValue = [target valueForKeyPath:targetKeyPath];
		
		CKObjectProperty* propertyDescriptor = [NSObject property:self.control forKeyPath:keyPath];
		id transformedValue = [CKValueTransformer transformValue:dataValue toClass:propertyDescriptor.type];
		[self.control setValue:transformedValue forKeyPath:keyPath];
		
		UIControl* control = (UIControl*)subView;
		[control addTarget:self action:@selector(controlChange) forControlEvents:controlEvents];
		
		[target addObserver:self
				 forKeyPath:targetKeyPath
					options:(NSKeyValueObservingOptionNew)
					context:nil];
		
		binded = YES;
	}
}

-(void)unbind{
	if(binded){
		if(self.control){
			[self.control removeTarget:self action:@selector(controlChange) forControlEvents:controlEvents];
			[self.target removeObserver:self forKeyPath:targetKeyPath];
		}
		
		[[CKBindingsManager defaultManager]unbind:self];
		binded = NO;
	}
}


@end
