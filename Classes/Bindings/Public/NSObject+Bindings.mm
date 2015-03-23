//
//  NSObject+Binding.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "NSObject+Bindings.h"
#import "CKBindingsManager.h"
#import "CKUIControlBlockBinder.h"
#import "CKDataBinder.h"
#import "CKNotificationBlockBinder.h"
#import "CKCollectionBlockBinder.h"
#import "CKDataBlockBinder.h"
#import "CKConfiguration.h"
#import "CKDebug.h"
#include <ext/hash_map>

using namespace __gnu_cxx;

namespace __gnu_cxx{
    template<> struct hash< id >
    {
        size_t operator()( id x ) const{
            return (size_t)x;
        }
    };
}

@interface CKDataBlockBinder()
- (void)executeWithValue:(id)value;
@end

@interface CKBindingsManager () {
    @public
    hash_map<id, CKWeakRef*> weakRefContext;
}
@property (nonatomic, retain) NSDictionary *bindingsPoolForClass;
@property (nonatomic, retain) NSDictionary *bindingsForContext;
@end

static NSMutableArray* CKBindingsContextStack = nil;
static NSString* CKBindingsNoContext = @"CKBindingsNoContext";


@implementation NSObject (CKBindingContext)


+ (id)currentBindingContext{
	if(CKBindingsContextStack && [CKBindingsContextStack count] > 0){
		return [[CKBindingsContextStack lastObject]objectForKey:@"context"];
	}
	return CKBindingsNoContext;
}


+ (CKBindingsContextOptions)currentBindingContextOptions{
    if(CKBindingsContextStack && [CKBindingsContextStack count] > 0){
		return (CKBindingsContextOptions)[[[CKBindingsContextStack lastObject]objectForKey:@"options"]integerValue];
	}
	return (CKBindingsContextOptions) (CKBindingsContextPerformOnMainThread | CKBindingsContextWaitUntilDone);
}

+ (NSString *)allBindingsDescription{
	return [[CKBindingsManager defaultManager]description];
}

+ (void)beginBindingsContext:(id)context{
	[NSObject beginBindingsContext:context policy:CKBindingsContextPolicyAdd options:(CKBindingsContextOptions) (CKBindingsContextPerformOnMainThread | CKBindingsContextWaitUntilDone)];
}

+ (void)beginBindingsContext:(id)context policy:(CKBindingsContextPolicy)policy{
	[NSObject beginBindingsContext:context policy:policy options:(CKBindingsContextOptions) (CKBindingsContextPerformOnMainThread | CKBindingsContextWaitUntilDone)];
}

+ (void)beginBindingsContext:(id)context options:(CKBindingsContextOptions)options{
	[NSObject beginBindingsContext:context policy:CKBindingsContextPolicyAdd options:options];
}

+ (void)beginBindingsContext:(id)context policy:(CKBindingsContextPolicy)policy options:(CKBindingsContextOptions)options{
    if(CKBindingsContextStack == nil){
		CKBindingsContextStack = [[NSMutableArray alloc]init];
	}
	
	[CKBindingsContextStack addObject:[NSDictionary dictionaryWithObjectsAndKeys:context,@"context",[NSNumber numberWithInteger:options],@"options",nil]];
	
	if(policy == CKBindingsContextPolicyRemovePreviousBindings){
		[[CKBindingsManager defaultManager] unbindAllBindingsWithContext:context doNotUnbindBecauseObjectIsDeallocated:NO];
	}
}

+ (void)endBindingsContext{
    if (!(CKBindingsContextStack != nil && [CKBindingsContextStack count] > 0))
        [NSException raise:NSGenericException format:@"No context opened"];
	[CKBindingsContextStack removeLastObject];
}

+ (void)removeAllBindingsForContext:(id)context{
    [self removeAllBindingsForContext:context doNotUnbindBecauseObjectIsDeallocated:NO];
}

+ (void)removeAllBindingsForContext:(id)context doNotUnbindBecauseObjectIsDeallocated:(BOOL)doNotUnbindBecauseObjectIsDeallocated{
	[[CKBindingsManager defaultManager]unbindAllBindingsWithContext:context doNotUnbindBecauseObjectIsDeallocated:doNotUnbindBecauseObjectIsDeallocated];
}


+ (void)validateCurrentBindingsContext{
    if(![NSThread isMainThread]){
        NSAssert(NO,@"AppCoreKit : Creating Bindings MUST be done on the Main Thread.");
    }
    
//#ifdef DEBUG
    if(![[CKConfiguration sharedInstance]assertForBindingsOutOfContext])
        return;
    
    if ([NSObject currentBindingContext] == CKBindingsNoContext)
        [NSException raise:NSGenericException format:@"You're creating a binding without having opened a context !"];
//#endif
}

//Instance method for bindings management

- (CKWeakRef*)weakRefBindingsContext{
    return [CKBindingsManager defaultManager]->weakRefContext[self];
}

- (void)beginBindingsContextUsingPolicy:(CKBindingsContextPolicy)policy options:(CKBindingsContextOptions)options{
    if(![NSThread isMainThread]){
        NSAssert(NO,@"AppCoreKit : Opening Bindings Context MUST be done on the Main Thread.");
    }
    
    
    CKWeakRef* weakRef = [self weakRefBindingsContext];
    if(weakRef == nil){
        weakRef = [CKWeakRef weakRefWithObject:self block:^(CKWeakRef* ref){
            NSMutableSet* bindings = [[[CKBindingsManager defaultManager]bindingsForContext] objectForKey:ref];
            if(!bindings){
                return;
            }
            
            //This retains self : CKDebugLog(@"WARNING : the following context is beeing cleared as it's object is deallocated : {context : %@\n}",ref);
            [NSObject removeAllBindingsForContext:ref doNotUnbindBecauseObjectIsDeallocated:YES];
        }];
    }
	[NSObject beginBindingsContext:weakRef policy:policy options:options];
}

- (void)beginBindingsContextByKeepingPreviousBindings{
	[self beginBindingsContextUsingPolicy:CKBindingsContextPolicyAdd options:(CKBindingsContextOptions) (CKBindingsContextPerformOnMainThread | CKBindingsContextWaitUntilDone)];
}

- (void)beginBindingsContextByRemovingPreviousBindings{
	[self beginBindingsContextUsingPolicy:CKBindingsContextPolicyRemovePreviousBindings options:(CKBindingsContextOptions) (CKBindingsContextPerformOnMainThread | CKBindingsContextWaitUntilDone)];
}

- (void)beginBindingsContextByKeepingPreviousBindingsWithOptions:(CKBindingsContextOptions)options{
	[self beginBindingsContextUsingPolicy:CKBindingsContextPolicyAdd options:options];
}

- (void)beginBindingsContextByRemovingPreviousBindingsWithOptions:(CKBindingsContextOptions)options{
	[self beginBindingsContextUsingPolicy:CKBindingsContextPolicyRemovePreviousBindings options:options];
}

- (void)endBindingsContext{
	[NSObject endBindingsContext];
}

- (void)clearBindingsContext{
	[NSObject removeAllBindingsForContext:[self weakRefBindingsContext]];
}

- (void)beginBindingsContext{
    [self beginBindingsContextByRemovingPreviousBindings];
}

- (id)bindingContextWithScope:(NSString*)scope{
    return [NSString stringWithFormat:@"%@_<%p>_%@",[self class],self,scope];
}

- (void)beginBindingsContextWithScope:(NSString*)scope{
    [self beginBindingsContextByRemovingPreviousBindingsWithScope:scope];
}

- (void)clearBindingsContextWithScope:(NSString*)scope{
    NSString* context = [self bindingContextWithScope:scope];
    [NSObject removeAllBindingsForContext:context];
}

/**
 */
- (void)beginBindingsContextByKeepingPreviousBindingsWithScope:(NSString*)scope{
    NSString* context = [self bindingContextWithScope:scope];
    [NSObject beginBindingsContext:context policy:CKBindingsContextPolicyAdd options:(CKBindingsContextOptions) (CKBindingsContextPerformOnMainThread | CKBindingsContextWaitUntilDone)];
}

/**
 */
- (void)beginBindingsContextByRemovingPreviousBindingsWithScope:(NSString*)scope{
    NSString* context = [self bindingContextWithScope:scope];
    [NSObject beginBindingsContext:context policy:CKBindingsContextPolicyRemovePreviousBindings options:(CKBindingsContextOptions) (CKBindingsContextPerformOnMainThread | CKBindingsContextWaitUntilDone)];
}

/**
 */
- (void)beginBindingsContextByKeepingPreviousBindingsWithOptions:(CKBindingsContextOptions)options scope:(NSString*)scope{
    NSString* context = [self bindingContextWithScope:scope];
    [NSObject beginBindingsContext:context policy:CKBindingsContextPolicyAdd options:options];
}

/**
 */
- (void)beginBindingsContextByRemovingPreviousBindingsWithOptions:(CKBindingsContextOptions)options scope:(NSString*)scope{
    NSString* context = [self bindingContextWithScope:scope];
    [NSObject beginBindingsContext:context policy:CKBindingsContextPolicyRemovePreviousBindings options:options];
}


@end

@implementation NSObject (CKBindings)


//NSObject Bindings

- (void)bind:(NSString *)keyPath toObject:(id)object withKeyPath:(NSString *)keyPath2{
    [NSObject validateCurrentBindingsContext];
    
	CKDataBinder* binder = (CKDataBinder*)[[CKBindingsManager defaultManager]newDequeuedReusableBindingWithClass:[CKDataBinder class]];
    binder.contextOptions = [NSObject currentBindingContextOptions];
	[binder setInstance1:self];
	binder.keyPath1 = keyPath;
	[binder setInstance2:object];
	binder.keyPath2 = keyPath2;
	[[CKBindingsManager defaultManager] bind:binder withContext:[NSObject currentBindingContext]];
	[binder release];
}

- (void)bind:(NSString *)keyPath withBlock:(void (^)(id value))block{
    [self bind:keyPath executeBlockImmediatly:NO withBlock:block];
}

- (void)bind:(NSString *)keyPath executeBlockImmediatly:(BOOL)execute withBlock:(void (^)(id value))block{
    [NSObject validateCurrentBindingsContext];
    
	CKDataBlockBinder* binder = (CKDataBlockBinder*)[[CKBindingsManager defaultManager]newDequeuedReusableBindingWithClass:[CKDataBlockBinder class]];
    binder.contextOptions = [NSObject currentBindingContextOptions];
	[binder setInstance:self];
	binder.keyPath = keyPath;
	binder.block = block;
	[[CKBindingsManager defaultManager] bind:binder withContext:[NSObject currentBindingContext]];
	[binder release];
    
    if(execute){
        [binder executeWithValue:[self valueForKeyPath:keyPath]];
    }
}


- (void)bind:(NSString *)keyPath target:(id)target action:(SEL)selector{
    [NSObject validateCurrentBindingsContext];
    
	CKDataBlockBinder* binder = (CKDataBlockBinder*)[[CKBindingsManager defaultManager]newDequeuedReusableBindingWithClass:[CKDataBlockBinder class]];
    binder.contextOptions = [NSObject currentBindingContextOptions];
	[binder setInstance:self];
	binder.keyPath = keyPath;
	[binder setTarget:target];
	binder.selector = selector;
	[[CKBindingsManager defaultManager]bind:binder withContext:[NSObject currentBindingContext]];
	[binder release];
}

- (void)bindPropertyChangeWithBlock:(void (^)(NSString* propertyName, id value))block{
    NSArray* allProperties = [self allPropertyNames];
    for(NSString* keyPath in allProperties){
        [self bind:keyPath withBlock:^(id value) {
            block(keyPath,value);
        }];
    }
}

@end

//

@implementation UIControl (CKBindings)

- (void)bindEvent:(UIControlEvents)controlEvents withBlock:(void (^)())block{
    [self bindEvent:controlEvents executeBlockImmediatly:NO withBlock:block];
}


- (void)bindEvent:(UIControlEvents)controlEvents executeBlockImmediatly:(BOOL)execute withBlock:(void (^)())block{
    [NSObject validateCurrentBindingsContext];
    
	CKUIControlBlockBinder* binder = (CKUIControlBlockBinder*)[[CKBindingsManager defaultManager]newDequeuedReusableBindingWithClass:[CKUIControlBlockBinder class]];
    binder.contextOptions = [NSObject currentBindingContextOptions];
	binder.controlEvents = controlEvents;
	binder.block = block;
	[binder setControl:self];
	[[CKBindingsManager defaultManager]bind:binder withContext:[NSObject currentBindingContext]];
	[binder release];
    
    if(execute && block){
        block();
    }
}

- (void)bindEvent:(UIControlEvents)controlEvents target:(id)target action:(SEL)selector{
    [NSObject validateCurrentBindingsContext];
    
	CKUIControlBlockBinder* binder = (CKUIControlBlockBinder*)[[CKBindingsManager defaultManager]newDequeuedReusableBindingWithClass:[CKUIControlBlockBinder class]];
    binder.contextOptions = [NSObject currentBindingContextOptions];
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
    [NSObject validateCurrentBindingsContext];
    
	CKNotificationBlockBinder* binder = (CKNotificationBlockBinder*)[[CKBindingsManager defaultManager]newDequeuedReusableBindingWithClass:[CKNotificationBlockBinder class]];
    binder.contextOptions = [NSObject currentBindingContextOptions];
	[binder setInstance:notificationSender];
	binder.notificationName = notification;
	binder.block = block;
	[[CKBindingsManager defaultManager]bind:binder withContext:[NSObject currentBindingContext]];
	[binder release];
}

- (void)bindNotificationName:(NSString *)notification withBlock:(void (^)(NSNotification *notification))block{
    [NSObject validateCurrentBindingsContext];
    
	CKNotificationBlockBinder* binder = (CKNotificationBlockBinder*)[[CKBindingsManager defaultManager]newDequeuedReusableBindingWithClass:[CKNotificationBlockBinder class]];
    binder.contextOptions = [NSObject currentBindingContextOptions];
	binder.notificationName = notification;
	binder.block = block;
	[[CKBindingsManager defaultManager]bind:binder withContext:[NSObject currentBindingContext]];
	[binder release];
}

- (void)bindNotificationName:(NSString *)notification object:(id)notificationSender target:(id)target action:(SEL)selector{
    [NSObject validateCurrentBindingsContext];
    
	CKNotificationBlockBinder* binder = (CKNotificationBlockBinder*)[[CKBindingsManager defaultManager]newDequeuedReusableBindingWithClass:[CKNotificationBlockBinder class]];
    binder.contextOptions = [NSObject currentBindingContextOptions];
	[binder setInstance:notificationSender];
	[binder setTarget:target];
	binder.notificationName = notification;
	binder.selector = selector;
	[[CKBindingsManager defaultManager]bind:binder withContext:[NSObject currentBindingContext]];
	[binder release];
}

- (void)bindNotificationName:(NSString *)notification target:(id)target action:(SEL)selector{
    [NSObject validateCurrentBindingsContext];
    
	CKNotificationBlockBinder* binder = (CKNotificationBlockBinder*)[[CKBindingsManager defaultManager]newDequeuedReusableBindingWithClass:[CKNotificationBlockBinder class]];
    binder.contextOptions = [NSObject currentBindingContextOptions];
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



/**
 */
- (void)bindNotificationNames:(NSArray *)notifications withBlock:(void (^)(NSNotification *notification))block{
    for(NSString* notification in notifications){
        [self bindNotificationName:notification withBlock:block];
    }
}

/**
 */
- (void)bindNotificationNames:(NSArray *)notifications object:(id)notificationSender withBlock:(void (^)(NSNotification *notification))block{
    for(NSString* notification in notifications){
        [self bindNotificationName:notification object:notificationSender withBlock:block];
    }
}

/**
 */
+ (void)bindNotificationNames:(NSArray *)notifications withBlock:(void (^)(NSNotification *notification))block{
	[[NSNotificationCenter defaultCenter]bindNotificationNames:notifications withBlock:block];
}

/**
 */
+ (void)bindNotificationNames:(NSArray *)notifications object:(id)notificationSender withBlock:(void (^)(NSNotification *notification))block{
	[[NSNotificationCenter defaultCenter]bindNotificationNames:notifications object:notificationSender withBlock:block];
}



@end



@implementation CKCollection (CKBindings)


- (void)bindEvent:(CKCollectionBindingEvents)events withBlock:(void(^)(CKCollectionBindingEvents event, NSArray* objects, NSIndexSet* indexes))block{
    [self bindEvent:events executeBlockImmediatly:NO withBlock:block];
}


- (void)bindEvent:(CKCollectionBindingEvents)events executeBlockImmediatly:(BOOL)executeBlockImmediatly withBlock:(void(^)(CKCollectionBindingEvents event, NSArray* objects, NSIndexSet* indexes))block{
    [NSObject validateCurrentBindingsContext];
    
	CKCollectionBlockBinder* binder = (CKCollectionBlockBinder*)[[CKBindingsManager defaultManager]newDequeuedReusableBindingWithClass:[CKCollectionBlockBinder class]];
    binder.contextOptions = [NSObject currentBindingContextOptions];
	[binder setInstance:self];
	binder.events = events;
	binder.block = block;
	[[CKBindingsManager defaultManager]bind:binder withContext:[NSObject currentBindingContext]];
	[binder release];
    
    if(executeBlockImmediatly){
        block(CKCollectionBindingEventInsertion,[self allObjects],[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self count])]);
    }
}

@end