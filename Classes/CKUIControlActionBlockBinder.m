//
//  CKViewExecutionBlock.m
//  NFB
//
//  Created by Sebastien Morel on 11-01-26.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKUIControlActionBlockBinder.h"
#import "CKNSObject+Introspection.h"


@interface CKUIControlActionBlockBinder()
@property (nonatomic, retain) UIControl *control;
-(void)unbind;
-(void)controlChange;
@end


@implementation CKUIControlActionBlockBinder
@synthesize viewTag;
@synthesize control;
@synthesize controllEvents;
@synthesize actionBlock;

#pragma mark Initialization

-(id)init{
	[super init];
	controllEvents = UIControlEventTouchUpInside;//UIControlEventValueChanged;
	return self;
}

-(void)dealloc{
	[self unbind];
	self.actionBlock = nil;
	self.viewTag = nil;
	self.control = nil;
	[super dealloc];
}

-(NSString*)description{
	return [NSString stringWithFormat:@"CKUIControlActionBlockBinder count=%d %d",[self retainCount],[viewTag intValue]];
}

#pragma mark Private API

-(void)unbind{
	if(self.control){
		[self.control removeTarget:self action:@selector(execute) forControlEvents:controllEvents];
		self.control = nil;
	}
}

//Update data in model
-(void)controlChange{
	actionBlock();
}

#pragma mark Public API

-(void)bindControlInView:(UIView*)controlView{
	[self unbind];
	
	id controlId = [controlView viewWithTag:[viewTag intValue]];
	if(!controlId){
		NSAssert(NO,@"Invalid control object in CKUIControlActionBlockBinder");
	}
	
	if([controlId isKindOfClass:[UIControl class]]){
		self.control = (UIControl*)controlId;
		[self.control addTarget:self action:@selector(controlChange) forControlEvents:controllEvents];
	}
	
}




@end


