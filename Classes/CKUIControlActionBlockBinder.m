//
//  CKViewExecutionBlock.m
//  NFB
//
//  Created by Sebastien Morel on 11-01-26.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKUIControlActionBlockBinder.h"
#import "CKNSObject+Introspection.h"
#import "CKImageView.h"


@interface CKUIControlActionBlockBinder()
@property (nonatomic, retain) UIView *view;
-(void)unbind;
-(void)controlChange;
@end


@implementation CKUIControlActionBlockBinder
@synthesize viewTag;
@synthesize view;
@synthesize controlEvents;
@synthesize actionBlock;
@synthesize keyPath;

#pragma mark Initialization

-(id)init{
	[super init];
	controlEvents = UIControlEventTouchUpInside;//UIControlEventValueChanged;
	self.viewTag = -1;
	binded = NO;
	return self;
}

-(void)dealloc{
	[self unbind];
	self.actionBlock = nil;
	self.view = nil;
	[super dealloc];
}

-(NSString*)description{
	return [NSString stringWithFormat:@"CKUIControlActionBlockBinder count=%d %d",[self retainCount],viewTag];
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
	self.view = controlId;
	if(!controlId){
		NSAssert(NO,@"Invalid control object in CKUIControlActionBlockBinder");
	}
	
	if([controlId isKindOfClass:[UIControl class]]){
		UIControl* ctrl = (UIControl*)controlId;
		[ctrl addTarget:self action:@selector(controlChange) forControlEvents:controlEvents];
	}
	binded = YES;
}

-(void)unbind{
	if(binded){
		if(self.view){
			if([view isKindOfClass:[UIControl class]]){
				UIControl* ctrl = (UIControl*)self.view;
				[ctrl removeTarget:self action:@selector(execute) forControlEvents:controlEvents];
			}
			
			self.view = nil;
			binded = NO;
		}
	}
}


+ (CKUIControlActionBlockBinder*)actionBlockBinderForView:(UIView*)view viewTag:(NSUInteger)viewTag keyPath:(NSString*)keyPath 
											  actionBlock:(CKUIControlActionBlock)actionBlock{
	return [self actionBlockBinderForView:view viewTag:viewTag keyPath:keyPath controlEvents:UIControlEventTouchUpInside actionBlock:actionBlock];
}


+ (CKUIControlActionBlockBinder*)actionBlockBinderForView:(UIView*)view viewTag:(NSUInteger)viewTag
											  actionBlock:(CKUIControlActionBlock)actionBlock{
	return [self actionBlockBinderForView:view viewTag:viewTag keyPath:@"" controlEvents:UIControlEventTouchUpInside actionBlock:actionBlock];
}

+ (CKUIControlActionBlockBinder*)actionBlockBinderForView:(UIView*)view keyPath:(NSString*)keyPath 
											  actionBlock:(CKUIControlActionBlock)actionBlock{
	return [self actionBlockBinderForView:view viewTag:-1 keyPath:keyPath controlEvents:UIControlEventTouchUpInside actionBlock:actionBlock];
}

+ (CKUIControlActionBlockBinder*)actionBlockBinderForView:(UIView*)view 
											  actionBlock:(CKUIControlActionBlock)actionBlock{
	return [self actionBlockBinderForView:view viewTag:-1 keyPath:@"" controlEvents:UIControlEventTouchUpInside actionBlock:actionBlock];
}

+ (CKUIControlActionBlockBinder*)actionBlockBinderForView:(UIView*)view viewTag:(NSUInteger)viewTag
											controlEvents:(UIControlEvents)controlEvents actionBlock:(CKUIControlActionBlock)actionBlock{
	return [self actionBlockBinderForView:view viewTag:viewTag keyPath:@"" controlEvents:controlEvents actionBlock:actionBlock];
}

+ (CKUIControlActionBlockBinder*)actionBlockBinderForView:(UIView*)view keyPath:(NSString*)keyPath 
											controlEvents:(UIControlEvents)controlEvents actionBlock:(CKUIControlActionBlock)actionBlock{
	return [self actionBlockBinderForView:view viewTag:-1 keyPath:keyPath controlEvents:controlEvents actionBlock:actionBlock];
}

+ (CKUIControlActionBlockBinder*)actionBlockBinderForView:(UIView*)view
											controlEvents:(UIControlEvents)controlEvents actionBlock:(CKUIControlActionBlock)actionBlock{
	return [self actionBlockBinderForView:view viewTag:-1 keyPath:@"" controlEvents:controlEvents actionBlock:actionBlock];
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




@end


