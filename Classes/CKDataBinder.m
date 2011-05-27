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
#import "CKNSValueTransformer+Additions.h"


@interface CKDataBinder ()
@property (nonatomic, retain) MAZeroingWeakRef *instance1Ref;
@property (nonatomic, retain) MAZeroingWeakRef *instance2Ref;
- (void)unbindInstance:(id)instance1 instance2:(id)instance2;
@end

@implementation CKDataBinder
@synthesize instance1Ref;
@synthesize keyPath1;
@synthesize instance2Ref;
@synthesize keyPath2;

- (id)init{
	[super init];
	binded = NO;
	return self;
}

- (void)dealloc{
	[self unbind];
	[self reset];
	[super dealloc];
}

- (NSString*)description{
	return [NSString stringWithFormat:@"<CKDataBinder : %p>{\ninstance1Ref = %@\nkeyPath1 = %@\ninstance2Ref = %@\nkeyPath2 = %@}",
			self,instance1Ref ? instance1Ref.target : @"(null)",keyPath1,instance2Ref ? instance2Ref.target : @"(null)",keyPath2];
}

- (void)reset{
	self.instance1Ref = nil;
	self.keyPath1 = nil;
	self.instance2Ref = nil;
	self.keyPath2 = nil;
}

- (void)releaseInstance1:(id)sender target:(id)target{
	[self unbindInstance:target instance2:instance2Ref.target];
	[[CKBindingsManager defaultManager]unregister:self];
}

- (void)setInstance1:(id)instance{
	if(instance){
		self.instance1Ref = [[[MAZeroingWeakRef alloc] initWithTarget:instance]autorelease];
		[instance1Ref setDelegate:self action:@selector(releaseInstance1:target:)];
	}
	else{
		self.instance1Ref = nil;
	}
}

- (void)releaseInstance2:(id)sender target:(id)target{
	[self unbindInstance:instance1Ref.target instance2:target];
	[[CKBindingsManager defaultManager]unregister:self];
}

- (void)setInstance2:(id)instance{
	if(instance){
		self.instance2Ref = [[[MAZeroingWeakRef alloc] initWithTarget:instance]autorelease];
		[instance2Ref setDelegate:self action:@selector(releaseInstance2:target:)];
	}
	else{
		self.instance2Ref = nil;
	}
}

-(void)bind{
	[self unbind];
	
	CKClassPropertyDescriptor* property = [NSObject propertyDescriptor:instance2Ref.target forKeyPath:keyPath2];
	if(property == nil){
		//cannot bind unfound property
		return;
	}
	
	[NSValueTransformer transform:[instance1Ref.target valueForKeyPath:keyPath1]
							   inProperty:[CKObjectProperty propertyWithObject:instance2Ref.target keyPath:keyPath2]];
	
	[instance1Ref.target addObserver:self
				forKeyPath:keyPath1
				   options:(NSKeyValueObservingOptionNew)
				   context:nil];
	binded = YES;
}

- (void)unbind{
	[self unbindInstance:instance1Ref.target instance2:instance2Ref.target];
}

- (void)unbindInstance:(id)instance1 instance2:(id)instance2{
	if(binded){
		[instance1 removeObserver:self
								 forKeyPath:keyPath1];
		binded = NO;
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context
{
	id newValue = [change objectForKey:NSKeyValueChangeNewKey];
	[NSValueTransformer transform:newValue inProperty:[CKObjectProperty propertyWithObject:instance2Ref.target keyPath:keyPath2] ];
}

@end
