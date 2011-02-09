//
//  CKSignal.m
//  CloudKitApp
//
//  Created by Sebastien Morel on 11-01-19.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKSignal.h"
#import <objc/runtime.h>

@implementation CKSlot

@synthesize instance;
@synthesize selector;
@synthesize priority;

+(CKSlot*)slotWith : (id)object sel:(SEL)sel{
	return [CKSlot slotWith:object sel:sel p:0];
}

+(CKSlot*)slotWith : (id)object sel:(SEL)sel p:(int)p{
	CKSlot* slot = [[[CKSlot alloc]init]autorelease];
	slot.instance = object;
	slot.selector = sel;
	slot.priority = p;
	return slot;
}

-(void)setSelector:(SEL)s{
	selector = s;
}

- (NSMethodSignature*) getSignature{
	Method m = class_getInstanceMethod([self.instance class], self.selector);
	NSMethodSignature* signature =  [NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(m)];
	return signature;
}

- (BOOL)valid{
	return self.instance && self.selector;
}

@end

//

@implementation CKSignal

@synthesize methodSignature;
@synthesize slotArray;
@synthesize disable;

+(CKSignal*)signalWithSignature:(NSMethodSignature*)signature{
	CKSignal* signal = [[[CKSignal alloc]init]autorelease];
	signal.methodSignature = signature;
	return signal;
}


+(CKSignal*)signalWithTypes:(char*)argType0,...{
	va_list ArgumentList;
	va_start(ArgumentList,argType0);
	
	//concatenate types
	char argsbuffer[1024] = "";
	sprintf(argsbuffer,"%s",argType0);
	char* arg;
	while (arg = va_arg(ArgumentList, char*)){
		strcat(argsbuffer,arg);
    }
    va_end(ArgumentList);
	
	//create signature with void as return type
	char buffer[1024] = "";
	sprintf(buffer,"v@:%s",argsbuffer);
	return [CKSignal signalWithSignature:[NSMethodSignature signatureWithObjCTypes:buffer]];
}

-(id)init{
	[super init];
	slotArray = [[NSMutableArray array]retain];
	disable = NO;
	return self;
}

- (void)dealloc {
	[methodSignature release];
	[slotArray release];
	[super dealloc];
}

-(BOOL)addSlotArrayObject:(id)object{
	NSAssert([object isKindOfClass:[CKSlot class]],@"not a slot");
	CKSlot* slot = (CKSlot*)object;
	if(methodSignature && ![methodSignature isEqual:[slot getSignature]]){
		NSAssert(NO,@"invalid signature when trying to insert slot!");
		return NO;
	}
	//insert at the good index depending on priority
	[slotArray addObject:slot];
	return YES;
}

-(BOOL)removeSlot:(id)slot{
	[slotArray removeObject:slot];
	return YES;
}

- (BOOL)addSlot:(id)object selector:(SEL)selector{
	CKSlot* slot = [CKSlot slotWith:object sel:selector];
	return [self addSlotArrayObject:slot];
}

- (BOOL)removeSlot:(id)object selector:(SEL)selector{
	for(CKSlot* slot in slotArray){
		if(slot.selector == selector && slot.instance == object){
			[slotArray removeObject:slot];
			return YES;
		}
	}
	return NO;
}

-(void)send:(NSArray*)arguments{
	if(disable)
		return;
	
	for(CKSlot* slot in slotArray){
		if(slot && [slot valid]){
			NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:[slot getSignature]];
			[invocation setTarget:slot.instance];
			[invocation setSelector:slot.selector];
			int count = 2;
			for(id arg in arguments){
				[invocation setArgument:&arg atIndex:count];
				count++;
			}
			[invocation retainArguments];
			[invocation invoke];
		}
		
		//[invocation getReturnValue:&ReturnValue];
	}
}

@end
