//
//  CKNibViewController.m
//  NFB
//
//  Created by Sebastien Morel on 11-01-26.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKView.h"
#import <CloudKit/CKConstants.h>

@implementation CKUIViewBinderTemplate

- (id)createBinderForView:(UIView*)view withTarget:(id)target{
	NSAssert(NO,@"Not Implemented");
	return nil;
}

@end;

@implementation CKUIViewDataBinderTemplate
@synthesize targetKeyPath;
@synthesize viewTag;
@synthesize keyPath;

+(CKUIViewDataBinderTemplate*)templateForViewTag:(int)viewTag viewKeyPath:(NSString*)viewKeyPath targetKeyPath:(NSString*)targetKeyPath{
	CKUIViewDataBinderTemplate* template = [[[CKUIViewDataBinderTemplate alloc]init]autorelease];
	template.targetKeyPath = targetKeyPath;
	template.viewTag = viewTag;
	template.keyPath = viewKeyPath;
	return template;
}


- (id)createBinderForView:(UIView*)view withTarget:(id)target{
	CKUIViewDataBinder* binder = [[[CKUIViewDataBinder alloc]init]autorelease];
	binder.viewTag = [NSNumber numberWithInt:self.viewTag];
	binder.keyPath = self.keyPath;
	binder.targetKeyPath = self.targetKeyPath;
	binder.target = target;
	[binder bindViewInView:view];
	return binder;
}

@end


@implementation CKUIControlActionBlockBinderTemplate
@synthesize actionBlockBuilder;
@synthesize viewTag;
@synthesize controlEvents;

-(void)dealloc{
	self.actionBlockBuilder = nil;
	[super dealloc];
}

+(CKUIControlActionBlockBinderTemplate*)templateForViewTag:(int)viewTag forControlEvents:(UIControlEvents)controlEvents actionBlockBuilder:(CKUIControlActionBlockBuilder)actionBlockBuilder{
	CKUIControlActionBlockBinderTemplate* template = [[[CKUIControlActionBlockBinderTemplate alloc]init]autorelease];
	template.actionBlockBuilder = actionBlockBuilder;
	template.viewTag = viewTag;
	template.controlEvents = controlEvents;
	return template;
}


- (id)createBinderForView:(UIView*)view withTarget:(id)target{
	CKUIControlActionBlockBinder* binder = [[[CKUIControlActionBlockBinder alloc]init]autorelease];
	binder.viewTag = [NSNumber numberWithInt:self.viewTag];
	CKUIControlActionBlock block = self.actionBlockBuilder(target);
	binder.actionBlock = block;
	binder.controllEvents = self.controlEvents;
	[binder bindControlInView:view];
	return binder;
}

@end


@implementation CKViewTemplate
@synthesize viewCreationBlock;
@synthesize bindingTemplates;

-(void)dealloc{
	self.bindingTemplates = nil;
	self.viewCreationBlock = nil;
	[super dealloc];
}

@end


@interface CKView ()
@property (nonatomic, retain) NSMutableArray *internal;
@property (nonatomic, retain) UIView *subView;
-(void)createInternalView;
@end

@implementation CKView
@synthesize internal;
@synthesize viewTemplate;
@synthesize subView;


-(void)dealloc{
	self.internal = nil;
	self.viewTemplate = nil;
	self.subView = nil;
	[super dealloc];
}

-(void)unbind{
	self.internal = nil;
}

-(void)setViewTemplate:(CKViewTemplate*)template{
	[viewTemplate release];
	viewTemplate = [template retain];
	//[template release];
	
	[self unbind];
	[self createInternalView];
}

-(void)bind:(id)object{
	[self unbind];
	
	NSMutableArray* ar = [[NSMutableArray alloc]init];
	self.internal = ar;
	[ar release];
	
	//Generate bindings between view controls and data to the model and execution blocks
	for(id binderTemplate in viewTemplate.bindingTemplates){
		if([binderTemplate isKindOfClass:[CKUIViewBinderTemplate class]]){
			if([binderTemplate respondsToSelector:@selector(createBinderForView:withTarget:)]){
				id binder = [binderTemplate createBinderForView:self withTarget:object];
				[internal addObject:binder];
			}
		}
	}
}

-(void)createInternalView{
	if(self.subView != nil){
		[subView removeFromSuperview];
		self.subView = nil;
	}
	
	self.subView = viewTemplate.viewCreationBlock();
	self.autoresizingMask = UIViewAutoresizingFlexibleWidth |  UIViewAutoresizingFlexibleHeight;
	self.subView.autoresizingMask = UIViewAutoresizingFlexibleWidth |  UIViewAutoresizingFlexibleHeight;
	[self addSubview:self.subView];
}

- (void)layoutSubviews{
	[super layoutSubviews];
	self.subView.frame = self.bounds;
}

@end
