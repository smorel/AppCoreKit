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
@synthesize controlEvents;
@synthesize actionBlock;
@synthesize keyPath;

#pragma mark Initialization

-(id)init{
	[super init];
	controlEvents = UIControlEventTouchUpInside;//UIControlEventValueChanged;
	self.viewTag = -1;
	return self;
}

-(void)dealloc{
	[self unbind];
	self.actionBlock = nil;
	self.control = nil;
	[super dealloc];
}

-(NSString*)description{
	return [NSString stringWithFormat:@"CKUIControlActionBlockBinder count=%d %d",[self retainCount],viewTag];
}

+ (CKUIControlActionBlockBinder*)actionBlockBinderForView:(UIView*)view viewTag:(NSUInteger)viewTag
											controlEvents:(UIControlEvents)controlEvents actionBlock:(CKUIControlActionBlock)actionBlock{
	return [self actionBlockBinderForView:view viewTag:viewTag keyPath:@"" controlEvents:controlEvents actionBlock:actionBlock];
}

+ (CKUIControlActionBlockBinder*)actionBlockBinderForView:(UIView*)view keyPath:(NSString*)keyPath 
											controlEvents:(UIControlEvents)controlEvents actionBlock:(CKUIControlActionBlock)actionBlock{
	return [self actionBlockBinderForView:view viewTag:-1 keyPath:keyPath controlEvents:controlEvents actionBlock:actionBlock];
}

+ (CKUIControlActionBlockBinder*)actionBlockBinderForView:(UIView*)view viewTag:(NSUInteger)viewTag keyPath:(NSString*)keyPath 
											controlEvents:(UIControlEvents)controlEvents actionBlock:(CKUIControlActionBlock)actionBlock{
	CKUIControlActionBlockBinder* binder = [[[CKUIControlActionBlockBinder alloc]init]autorelease];
	binder.viewTag = viewTag;
	binder.keyPath = keyPath;
	binder.controlEvents = controlEvents;
	binder.actionBlock = actionBlock;
	[binder bindControlInView:view];
	return binder;
}

#pragma mark Private API

-(void)unbind{
	if(self.control){
		[self.control removeTarget:self action:@selector(execute) forControlEvents:controlEvents];
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
	
	id subView = (viewTag >= 0) ? [controlView viewWithTag:viewTag] : controlView;
	
	id controlId = (keyPath == nil || [keyPath isEqualToString:@""]) ? subView : [subView valueForKeyPath:keyPath];
	if(!controlId){
		NSAssert(NO,@"Invalid control object in CKUIControlActionBlockBinder");
	}
	
	if([controlId isKindOfClass:[UIControl class]]){
		self.control = (UIControl*)controlId;
		[self.control addTarget:self action:@selector(controlChange) forControlEvents:controlEvents];
	}
	
}




@end


