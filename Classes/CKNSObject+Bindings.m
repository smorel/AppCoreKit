//
//  CKBindings.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-03-11.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKNSObject+Bindings.h"
#import "CKBindingsManager.h"
#import "CKUIControlBlockBinder.h"
#import "CKDataBinder.h"
#import "CKNotificationBlockBinder.h"
#import "CKDataBlockBinder.h"


static NSMutableArray* CKBindingsContextStack = nil;
static NSString* CKBindingsNoContext = @"CKBindingsNoContext";


@implementation NSObject (CKBindings)

+ (id)currentBindingContext{
	if(CKBindingsContextStack && [CKBindingsContextStack count] > 0){
		return [CKBindingsContextStack lastObject];
	}
	return CKBindingsNoContext;
}

+ (NSString *)allBindingsDescription{
	return [[CKBindingsManager defaultManager]description];
}

+ (void)beginBindingsContext:(id)context{
	[NSObject beginBindingsContext:context policy:CKBindingsContextPolicyAdd];
}

+ (void)beginBindingsContext:(id)context policy:(CKBindingsContextPolicy)policy{
	if(CKBindingsContextStack == nil){
		CKBindingsContextStack = [[NSMutableArray alloc]init];
	}
	
	[CKBindingsContextStack addObject:context];
	
	if(policy == CKBindingsContextPolicyRemovePreviousBindings){
		[[CKBindingsManager defaultManager] unbindAllBindingsWithContext:context];
	}
}

+ (void)endBindingsContext{
	NSAssert(CKBindingsContextStack != nil && [CKBindingsContextStack count] > 0,@"No context opened");
	[CKBindingsContextStack removeLastObject];
}

+ (void)removeAllBindingsForContext:(id)context{
	[[CKBindingsManager defaultManager]unbindAllBindingsWithContext:context];
}

- (void)removeAllBindings{
	[[CKBindingsManager defaultManager]unbindAllBindingsWithContext:self];
}

- (void)bind:(NSString *)keyPath toObject:(id)object withKeyPath:(NSString *)keyPath2{
	CKDataBinder* binder = (CKDataBinder*)[[CKBindingsManager defaultManager]dequeueReusableBindingWithClass:[CKDataBinder class]];
	[binder setInstance1:self];
	binder.keyPath1 = keyPath;
	[binder setInstance2:object];
	binder.keyPath2 = keyPath2;
	[[CKBindingsManager defaultManager]bind:binder withContext:[NSObject currentBindingContext]];
	[binder release];
}

- (void)bind:(NSString *)keyPath withBlock:(void (^)(id value))block{
	CKDataBlockBinder* binder = (CKDataBlockBinder*)[[CKBindingsManager defaultManager]dequeueReusableBindingWithClass:[CKDataBlockBinder class]];
	[binder setInstance:self];
	binder.keyPath = keyPath;
	binder.block = block;
	[[CKBindingsManager defaultManager]bind:binder withContext:[NSObject currentBindingContext]];
	[binder release];
}

- (void)bind:(NSString *)keyPath target:(id)target action:(SEL)selector{
	CKDataBlockBinder* binder = (CKDataBlockBinder*)[[CKBindingsManager defaultManager]dequeueReusableBindingWithClass:[CKDataBlockBinder class]];
	[binder setInstance:self];
	binder.keyPath = keyPath;
	[binder setTarget:target];
	binder.selector = selector;
	[[CKBindingsManager defaultManager]bind:binder withContext:[NSObject currentBindingContext]];
	[binder release];
}

@end

//

@implementation UIControl (CKBindings)

- (void)bindEvent:(UIControlEvents)controlEvents withBlock:(void (^)())block{
	CKUIControlBlockBinder* binder = (CKUIControlBlockBinder*)[[CKBindingsManager defaultManager]dequeueReusableBindingWithClass:[CKUIControlBlockBinder class]];
	binder.controlEvents = controlEvents;
	binder.block = block;
	[binder setControl:self];
	[[CKBindingsManager defaultManager]bind:binder withContext:[NSObject currentBindingContext]];
	[binder release];
}

- (void)bindEvent:(UIControlEvents)controlEvents target:(id)target action:(SEL)selector{
	CKUIControlBlockBinder* binder = (CKUIControlBlockBinder*)[[CKBindingsManager defaultManager]dequeueReusableBindingWithClass:[CKUIControlBlockBinder class]];
	binder.controlEvents = controlEvents;
	[binder setControl:self];
	[binder setTarget:target];
	binder.selector = selector;
	[[CKBindingsManager defaultManager]bind:binder withContext:[NSObject currentBindingContext]];
	[binder release];
}

@end

//

@implementation NSNotificationCenter (CKBindings)

- (void)bindNotificationName:(NSString *)notification object:(id)notificationSender withBlock:(void (^)(NSNotification *notification))block{
	CKNotificationBlockBinder* binder = (CKNotificationBlockBinder*)[[CKBindingsManager defaultManager]dequeueReusableBindingWithClass:[CKNotificationBlockBinder class]];
	[binder setInstance:notificationSender];
	binder.notificationName = notification;
	binder.block = block;
	[[CKBindingsManager defaultManager]bind:binder withContext:[NSObject currentBindingContext]];
	[binder release];
}

- (void)bindNotificationName:(NSString *)notification withBlock:(void (^)(NSNotification *notification))block{
	CKNotificationBlockBinder* binder = (CKNotificationBlockBinder*)[[CKBindingsManager defaultManager]dequeueReusableBindingWithClass:[CKNotificationBlockBinder class]];
	binder.notificationName = notification;
	binder.block = block;
	[[CKBindingsManager defaultManager]bind:binder withContext:[NSObject currentBindingContext]];
	[binder release];
}

- (void)bindNotificationName:(NSString *)notification object:(id)notificationSender target:(id)target action:(SEL)selector{
	CKNotificationBlockBinder* binder = (CKNotificationBlockBinder*)[[CKBindingsManager defaultManager]dequeueReusableBindingWithClass:[CKNotificationBlockBinder class]];
	[binder setInstance:notificationSender];
	[binder setTarget:target];
	binder.notificationName = notification;
	binder.selector = selector;
	[[CKBindingsManager defaultManager]bind:binder withContext:[NSObject currentBindingContext]];
	[binder release];
}

- (void)bindNotificationName:(NSString *)notification target:(id)target action:(SEL)selector{
	CKNotificationBlockBinder* binder = (CKNotificationBlockBinder*)[[CKBindingsManager defaultManager]dequeueReusableBindingWithClass:[CKNotificationBlockBinder class]];
	[binder setTarget:target];
	binder.notificationName = notification;
	binder.selector = selector;
	[[CKBindingsManager defaultManager]bind:binder withContext:[NSObject currentBindingContext]];
	[binder release];
}


+ (void)bindNotificationName:(NSString *)notification object:(id)notificationSender withBlock:(void (^)(NSNotification *notification))block{
	[[NSNotificationCenter defaultCenter]bindNotificationName:notification object:notificationSender withBlock:block];
}
+ (void)bindNotificationName:(NSString *)notification withBlock:(void (^)(NSNotification *notification))block{
	[[NSNotificationCenter defaultCenter]bindNotificationName:notification withBlock:block];
}

+ (void)bindNotificationName:(NSString *)notification object:(id)notificationSender target:(id)target action:(SEL)selector{
	[[NSNotificationCenter defaultCenter]bindNotificationName:notification object:notificationSender target:target action:selector];
}
+ (void)bindNotificationName:(NSString *)notification target:(id)target action:(SEL)selector{
	[[NSNotificationCenter defaultCenter]bindNotificationName:notification target:target action:selector];
}

@end


/*id subView = (viewTag >= 0) ? [self.view viewWithTag:viewTag] : self.view;
 id controlId = (keyPath == nil || [keyPath isEqualToString:@""]) ? subView : [subView valueForKeyPath:keyPath];
 if(!controlId){
 NSAssert(NO,@"Invalid control object in CKUIControlActionBlockBinder");
 }*/
