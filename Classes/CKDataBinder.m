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

- (void)setInstance1:(id)instance{
	if(instance){
		self.instance1Ref = [[[MAZeroingWeakRef alloc] initWithTarget:instance]autorelease];
		__block CKDataBinder* bself = self;
		[instance1Ref setCleanupBlock: ^(id target) {
			[self unbindInstance:target instance2:instance2Ref.target];
			[[CKBindingsManager defaultManager]unregister:bself];
		}];
	}
	else{
		self.instance1Ref = nil;
	}
}

- (void)setInstance2:(id)instance{
	if(instance){
		self.instance2Ref = [[[MAZeroingWeakRef alloc] initWithTarget:instance]autorelease];
		__block CKDataBinder* bself = self;
		[instance2Ref setCleanupBlock: ^(id target) {
			[self unbindInstance:instance1Ref.target instance2:target];
			[[CKBindingsManager defaultManager]unregister:bself];
		}];
	}
	else{
		self.instance2Ref = nil;
	}
}

-(void)bind{
	[self unbind];
	
	id value = [instance1Ref.target valueForKeyPath:keyPath1];
	CKObjectProperty* property = [NSObject property:instance2Ref.target forKeyPath:keyPath2];
	[instance2Ref.target setValue:[CKValueTransformer transformValue:value toClass:property.type] forKeyPath:keyPath2];
	
	[instance1Ref.target addObserver:self
				forKeyPath:keyPath1
				   options:(NSKeyValueObservingOptionNew)
				   context:nil];
	/*[instance2Ref.target addObserver:self
				forKeyPath:keyPath2
				   options:(NSKeyValueObservingOptionNew)
				   context:nil];*/
	binded = YES;
}

- (void)unbind{
	[self unbindInstance:instance1Ref.target instance2:instance2Ref.target];
}

- (void)unbindInstance:(id)instance1 instance2:(id)instance2{
	if(binded){
		[instance1 removeObserver:self
								 forKeyPath:keyPath1];
		/*[instance2 removeObserver:self
								 forKeyPath:keyPath2];*/
		binded = NO;
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context
{
	id newValue = [change objectForKey:NSKeyValueChangeNewKey];
	
	/*id dataValue1 = [instance1Ref.target valueForKeyPath:keyPath1];
	{
		CKObjectProperty* property = [NSObject property:instance1Ref.target forKeyPath:keyPath1];
		id newValue1 = [CKValueTransformer transformValue:newValue toClass:property.type];
		if(![newValue1 isEqual:dataValue1]){
			[instance1Ref.target removeObserver:self
									 forKeyPath:keyPath1];
			[instance1Ref.target setValue:newValue1 forKeyPath:keyPath1];
			[instance1Ref.target addObserver:self
								  forKeyPath:keyPath1
									 options:(NSKeyValueObservingOptionNew)
									 context:nil];
		}
	}*/
	
	id dataValue2 = [instance2Ref.target valueForKeyPath:keyPath2];
	{
		CKObjectProperty* property = [NSObject property:instance2Ref.target forKeyPath:keyPath2];
		id newValue2 = [CKValueTransformer transformValue:newValue toClass:property.type];
		if(![newValue2 isEqual:dataValue2]){
			/*[instance2Ref.target removeObserver:self
									 forKeyPath:keyPath2];*/
			[instance2Ref.target setValue:newValue2 forKeyPath:keyPath2];
			/*[instance2Ref.target addObserver:self
								  forKeyPath:keyPath2
									 options:(NSKeyValueObservingOptionNew)
									 context:nil];*/
		}
	}
}

@end
