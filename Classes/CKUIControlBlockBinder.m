//
//  CKViewExecutionBlock.m
//  NFB
//
//  Created by Sebastien Morel on 11-01-26.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKUIControlBlockBinder.h"
#import "CKNSObject+Introspection.h"
#import "CKImageView.h"
#import "CKBindingsManager.h"


@implementation CKUIControlBlockBinder
@synthesize controlEvents;
@synthesize block;
@synthesize control;
@synthesize target;
@synthesize selector;

#pragma mark Initialization

-(id)init{
	[super init];
	controlEvents = UIControlEventTouchUpInside;//UIControlEventValueChanged;
	binded = NO;
	return self;
}

-(void)dealloc{
	[self unbind];
	self.block = nil;
	self.control = nil;
	self.target = nil;
	self.selector = nil;
	[super dealloc];
}

-(NSString*)description{
	return [NSString stringWithFormat:@"CKUIControlBlockBinder count=%d",[self retainCount]];
}

//Update data in model
-(void)controlChange{
	if(block){
		block();
	}
	else if(target && [target respondsToSelector:self.selector]){
		[target performSelector:self.selector];
	}
	else{
		NSAssert(NO,@"CKUIControlBlockBinder no action plugged");
	}
}

#pragma mark Public API
- (void)bind{
	[self unbind];

	if(self.control){
		[self.control addTarget:self action:@selector(controlChange) forControlEvents:controlEvents];
	}
	binded = YES;
}

-(void)unbind{
	if(binded){
		if(self.control){
			[self.control removeTarget:self action:@selector(execute) forControlEvents:controlEvents];
		}
		
		//Unregister only when the binding is invalidated with weakRefs
		//[[CKBindingsManager defaultManager]unregister:self];
		binded = NO;
	}
}

//Shallow copy for references in dictionaries
- (id) copyWithZone:(NSZone *)zone {
	return self;
}

@end


