//
//  CKBindingsManager.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-03-11.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKBindingsManager.h"
#import "CKBinding.h"
#import <objc/runtime.h>

@interface CKBindingsManager ()
@property (nonatomic, retain) NSDictionary *bindingsPoolForClass;
@property (nonatomic, retain) NSDictionary *bindingsForContext;
@property (nonatomic, retain) NSDictionary *bindingsToContext;
@property (nonatomic, retain) NSMutableSet *contexts;
@end

static CKBindingsManager* CKBindingsDefauktManager = nil;
@implementation CKBindingsManager
@synthesize bindingsForContext = _bindingsForContext;
@synthesize bindingsPoolForClass = _bindingsPoolForClass;
@synthesize bindingsToContext = _bindingsToContext;
@synthesize contexts = _contexts;

- (id)init{
	[super init];
	self.bindingsForContext = [NSMutableDictionary dictionary];
	self.bindingsToContext = [NSMutableDictionary dictionary];
	self.bindingsPoolForClass = [NSMutableDictionary dictionary];
	self.contexts = [NSMutableSet set];
	return self;
}

- (void)dealloc{
	[_bindingsForContext release];
	[_bindingsPoolForClass release];
	[_bindingsToContext release];
	[_contexts release];
	[super dealloc];
}

+ (CKBindingsManager*)defaultManager{
	if(CKBindingsDefauktManager == nil){
		CKBindingsDefauktManager = [[CKBindingsManager alloc]init];
	}
	return CKBindingsDefauktManager;
}

- (NSString*)description{
	return [_bindingsForContext description];
}

- (id)dequeueReusableBindingWithClass:(Class)bindingClass{
	NSString* className = [NSString stringWithUTF8String:class_getName(bindingClass)];
	NSMutableArray* bindings = [_bindingsPoolForClass valueForKey:className];
	if(!bindings){
		bindings = [NSMutableArray array];
		[_bindingsPoolForClass setValue:bindings forKey:className];
	}
	
	if([bindings count] > 0){
		id binding = [bindings lastObject];
		[bindings removeLastObject];
		return binding;
	}
	
	return [[[bindingClass alloc]init]autorelease];
}

- (void)bind:(id)binding withContext:(id)context{
	if([binding conformsToProtocol:@protocol(CKBinding)]){
		[binding performSelector:@selector(bind)];
	}
	
	NSMutableArray* bindings = [_bindingsForContext valueForKey:context];
	if(!bindings){
		[_contexts addObject:context];
		bindings = [NSMutableArray array];
		[_bindingsForContext setValue:bindings forKey:context];
	}
	[bindings addObject:binding];
	[_bindingsToContext setObject:context forKey:binding];
}


- (void)unbind:(id)binding{
	id context = [_bindingsToContext valueForKey:binding];
	if(context){
		[self unbind:binding withContext:context];
	}
}

- (void)unbind:(id)binding withContext:(id)context{
	if([binding conformsToProtocol:@protocol(CKBinding)]){
		[binding performSelector:@selector(unbind)];
	}
	
	NSMutableArray* bindings = [_bindingsForContext valueForKey:context];
	if(!bindings){
		NSAssert(NO,@"Should not unbind a non binded item");
		return;
	}
	[bindings removeObject:binding];
	
	//Put the binding in the reusable queue
	NSString* className = [NSString stringWithUTF8String:class_getName([binding class])];
	NSMutableArray* queuedBindings = [_bindingsPoolForClass valueForKey:className];
	if(!queuedBindings){
		queuedBindings = [NSMutableArray array];
		[_bindingsPoolForClass setValue:queuedBindings forKey:className];
	}
	[queuedBindings addObject:binding];
	[_bindingsToContext removeObjectForKey:binding];
	
	if([bindings count] <= 0){
		[_bindingsForContext removeObjectForKey:context];
		[_contexts removeObject:context];
	}
}

- (void)unbindAllBindingsWithContext:(id)context{
	NSMutableArray* bindings = [_bindingsForContext valueForKey:context];
	if(!bindings){
		return;
	}
	
	for(id binding in bindings){
		if([binding conformsToProtocol:@protocol(CKBinding)]){
			[binding performSelector:@selector(unbind)];
		}
		
		NSString* className = [NSString stringWithUTF8String:class_getName([binding class])];
		NSMutableArray* queuedBindings = [_bindingsPoolForClass valueForKey:className];
		if(!queuedBindings){
			queuedBindings = [NSMutableArray array];
			[_bindingsPoolForClass setValue:queuedBindings forKey:className];
		}
		[queuedBindings addObject:binding];
		[_bindingsToContext removeObjectForKey:binding];
	}
	
	[_bindingsForContext removeObjectForKey:context];
	[_contexts removeObject:context];
}

@end
