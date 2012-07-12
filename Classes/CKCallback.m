//
//  CKCallback.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKCallback.h"


@implementation  CKCallback{
	id _target;
	SEL _action;
	CKCallbackBlock _block;
	NSArray* _params;
}

@synthesize target = _target;
@synthesize action = _action;
@synthesize block = _block;
@synthesize params = _params;

- (void)dealloc{
	_target = nil;
	_action = nil;
	[_block release];
	_block = nil;
	[super dealloc];
}

+ (CKCallback*)callbackWithBlock:(CKCallbackBlock)block{
	return [[[CKCallback alloc]initWithBlock:block]autorelease];
}

+ (CKCallback*)callbackWithTarget:(id)target action:(SEL)action{
	return [[[CKCallback alloc]initWithTarget:target action:action]autorelease];
}

- (id)initWithTarget:(id)thetarget action:(SEL)theaction{
	if (self = [super init]) {
        self.target = thetarget;
        self.action = theaction;
    }
	return self;
}

- (id)initWithBlock:(CKCallbackBlock)theblock{
	if (self = [super init]) {
        self.block = theblock;
    }
	return self;
}

- (id)execute:(id)object{
	if(_target != nil && _action != nil){
		return [_target performSelector:_action withObject:object];
	}
	else if(_block != nil){
		return _block(object);
	}
	return nil;
}

@end
