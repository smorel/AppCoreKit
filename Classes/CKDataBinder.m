//
//  CKConnections.m
//  CloudKitApp
//
//  Created by Sebastien Morel on 11-01-22.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKDataBinder.h"
#import "CKBindingsManager.h"
#import "CKNSObject+CKRuntime.h"
#import "CKNSValueTransformer+Additions.h"


@interface CKDataBinder ()
#ifdef ENABLE_WEAK_REF_PROTECTION
@property (nonatomic, retain) CKWeakRef *instance1Ref;
@property (nonatomic, retain) CKWeakRef *instance2Ref;
#endif

- (void)unbindInstance:(id)instance1 instance2:(id)instance2;
@end

@implementation CKDataBinder

#ifdef ENABLE_WEAK_REF_PROTECTION
@synthesize instance1Ref;
@synthesize instance2Ref;
#endif

@synthesize instance1;
@synthesize instance2;
@synthesize keyPath1;
@synthesize keyPath2;

- (id)init{
	[super init];
	binded = NO;
    
#ifdef ENABLE_WEAK_REF_PROTECTION
    self.instance1Ref = [CKWeakRef weakRefWithObject:nil target:self action:@selector(releaseInstance1:)];
    self.instance2Ref = [CKWeakRef weakRefWithObject:nil target:self action:@selector(releaseInstance2:)];
#endif
	return self;
}

- (void)dealloc{
	[self unbind];
	[self reset];
    
#ifdef ENABLE_WEAK_REF_PROTECTION
    self.instance1Ref = nil;
    self.instance2Ref = nil;
#endif
    
	[super dealloc];
}

- (NSString*)description{
    return [NSString stringWithFormat:@"<CKDataBinder : %p>{\ninstance1 = %@\nkeyPath1 = %@\ninstance2 = %@\nkeyPath2 = %@}",
			self,instance1 ? instance1 : @"(null)",keyPath1,instance2 ? instance2 : @"(null)",keyPath2];
}

- (void)reset{
    [super reset];
    
	self.instance1 = nil;
	self.instance2 = nil;
	self.keyPath1 = nil;
	self.keyPath2 = nil;
}

#ifdef ENABLE_WEAK_REF_PROTECTION
- (id)releaseInstance1:(CKWeakRef*)weakRef{
    [self unbindInstance:weakRef.object instance2:instance2Ref.object];
    [[CKBindingsManager defaultManager]unregister:self];
	return nil;
}

- (id)releaseInstance2:(CKWeakRef*)weakRef{
    [self unbindInstance:instance1Ref.object instance2:weakRef.object];
    [[CKBindingsManager defaultManager]unregister:self];
	return nil;
}

- (void)setInstance1:(id)theinstance{
	self.instance1Ref.object = theinstance;
}

- (id)instance1{
    return self.instance1Ref.object;
}

- (void)setInstance2:(id)theinstance{
	self.instance2Ref.object = theinstance;
}

- (id)instance2{
    return self.instance2Ref.object;
}
#endif

-(void)bind{
	[self unbind];
	
	CKClassPropertyDescriptor* property = [NSObject propertyDescriptorForObject:self.instance2 keyPath:self.keyPath2];
	if(property == nil){
		return;
	}
	
	[NSValueTransformer transform:[self.instance1 valueForKeyPath:self.keyPath1]
							   inProperty:[CKProperty propertyWithObject:self.instance2 keyPath:self.keyPath2]];
	
	[self.instance1 addObserver:self
				forKeyPath:self.keyPath1
				   options:(NSKeyValueObservingOptionNew)
				   context:nil];
	binded = YES;
}

- (void)unbind{
	[self unbindInstance:self.instance1 instance2:self.instance2];
}

- (void)unbindInstance:(id)theinstance1 instance2:(id)theinstance2{
	if(binded){
		[theinstance1 removeObserver:self forKeyPath:self.keyPath1];
		binded = NO;
	}
}

- (void)executeWithValue:(id)value{
	[NSValueTransformer transform:value inProperty:[CKProperty propertyWithObject:self.instance2 keyPath:self.keyPath2] ];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context
{
	id newValue = [change objectForKey:NSKeyValueChangeNewKey];
	if ([newValue isKindOfClass:[NSNull class]]) {
		newValue = nil;
	}
    
    if(self.contextOptions & CKBindingsContextPerformOnMainThread){
        [self performSelectorOnMainThread:@selector(executeWithValue:) withObject:newValue waitUntilDone:(self.contextOptions & CKBindingsContextWaitUntilDone)];
    }
    else {
        [self performSelector:@selector(executeWithValue:) onThread:[NSThread currentThread] withObject:newValue waitUntilDone:(self.contextOptions & CKBindingsContextWaitUntilDone)];
    }
}

@end
