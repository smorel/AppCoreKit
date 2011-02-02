//
//  CKNibViewController.m
//  NFB
//
//  Created by Sebastien Morel on 11-01-26.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKView.h"
#import <CloudKit/CKConstants.h>

@implementation CKViewTemplate
@synthesize viewCreationBlock;
@synthesize viewSetupBlock;

-(void)dealloc{
	self.viewSetupBlock = nil;
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

-(void)setViewTemplate:(CKViewTemplate*)template{
	[viewTemplate release];
	viewTemplate = [template retain];
	
	self.internal = nil;//delete previous setup objects
	[self createInternalView];
}

-(void)bind:(id)object{
	if(viewTemplate){
		self.internal = viewTemplate.viewSetupBlock(self.subView,object);
	}
}

-(void)createInternalView{
	if(self.subView != nil){
		[subView removeFromSuperview];
		self.subView = nil;
	}
	
	if(viewTemplate){
		self.subView = viewTemplate.viewCreationBlock();
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth |  UIViewAutoresizingFlexibleHeight;
		self.subView.autoresizingMask = UIViewAutoresizingFlexibleWidth |  UIViewAutoresizingFlexibleHeight;
		[self addSubview:self.subView];
	}
}

- (void)layoutSubviews{
	[super layoutSubviews];
	self.subView.frame = self.bounds;
}

@end
