//
//  CKViewDataBinder.m
//  CloudKitApp
//
//  Created by Sebastien Morel on 11-01-26.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKUIViewDataBinder.h"
#import "CKNSObject+Introspection.h"
#import "CKValueTransformer.h"


@interface CKUIViewDataBinder()
@property (nonatomic, retain) UIView *view;
-(void)unbind;
-(void)controlChange;
@end

@implementation CKUIViewDataBinder
@synthesize viewTag;
@synthesize keyPath;
@synthesize target;
@synthesize targetKeyPath;
@synthesize view;
@synthesize controlEvents;

#pragma mark Initialization

-(id)init{
	[super init];
	controlEvents = UIControlEventValueChanged;
	viewTag = -1;
	return self;
}

-(void)dealloc{
	[self unbind];
	[super dealloc];
}

-(NSString*)description{
	return [NSString stringWithFormat:@"CKUIViewDataBinder count=%d %@ %@",[self retainCount],target,targetKeyPath];
}

+ (CKUIViewDataBinder*)dataBinderForView:(UIView*)view keyPath:(NSString*)keyPath 
						   target:(id)target targetKeyPath:(NSString*)targetKeyPath{
	return [self dataBinderForView:view viewTag:-1 keyPath:keyPath controlEvents:UIControlEventValueChanged target:target targetKeyPath:targetKeyPath];
}

+ (CKUIViewDataBinder*)dataBinderForView:(UIView*)view viewTag:(NSInteger)viewTag keyPath:(NSString*)keyPath 
						   target:(id)target targetKeyPath:(NSString*)targetKeyPath{
	return [self dataBinderForView:view viewTag:viewTag keyPath:keyPath controlEvents:UIControlEventValueChanged target:target targetKeyPath:targetKeyPath];
}

+ (CKUIViewDataBinder*)dataBinderForView:(UIView*)view keyPath:(NSString*)keyPath 
						   controlEvents:(UIControlEvents)controlEvents target:(id)target targetKeyPath:(NSString*)targetKeyPath{
	return [self dataBinderForView:view viewTag:-1 keyPath:keyPath controlEvents:controlEvents target:target targetKeyPath:targetKeyPath];
}

+ (CKUIViewDataBinder*)dataBinderForView:(UIView*)view viewTag:(NSInteger)viewTag keyPath:(NSString*)keyPath 
						   controlEvents:(UIControlEvents)controlEvents target:(id)target targetKeyPath:(NSString*)targetKeyPath{
	CKUIViewDataBinder* binder = [[[CKUIViewDataBinder alloc]init]autorelease];
	binder.viewTag = viewTag;
	binder.keyPath = keyPath;
	binder.controlEvents = controlEvents;
	binder.target = target;
	binder.targetKeyPath = targetKeyPath;
	[binder bindViewInView:view];
	return binder;
}

#pragma mark Private API

-(void)unbind{
	if(self.view && [self.view isKindOfClass:[UIControl class]]){
		UIControl* control = (UIControl*)self.view;
		[control removeTarget:self action:@selector(controlChange) forControlEvents:controlEvents];
		[target removeObserver:self forKeyPath:targetKeyPath];
	}
	
	self.view = nil;
}


//Update data in model
-(void)controlChange{
	id subView = (viewTag >= 0) ? [self.view viewWithTag:viewTag] : self.view ;
	if(!subView){
		NSAssert(NO,@"Invalid subView object in CKUIViewDataBinder");
	}
	
	id newValue = [subView valueForKeyPath:keyPath];
	
	id dataValue = [target valueForKeyPath:targetKeyPath];
	if(![newValue isEqual:dataValue]){
		[target setValue:[CKValueTransformer transformValue:newValue toClass:[dataValue class]] forKeyPath:targetKeyPath];
	}
}


//update data in control
- (void)observeValueForKeyPath:(NSString *)theKeyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context
{
	id newValue = [change objectForKey:NSKeyValueChangeNewKey];
	
	id subView = (viewTag >= 0) ? [self.view viewWithTag:viewTag] : self.view;
	if(!subView){
		NSAssert(NO,@"Invalid subView object in CKUIViewDataBinder");
	}
	else{
		id subViewValue = [subView valueForKeyPath:keyPath];
		if(![newValue isEqual:subViewValue]){
			CKObjectProperty* propertyDescriptor = [NSObject property:subView forKeyPath:keyPath];
			[subView setValue:[CKValueTransformer transformValue:newValue toClass:propertyDescriptor.type] forKeyPath:keyPath];
		}
	}
}

#pragma mark Public API

-(void)bindViewInView:(UIView*)theView{
	[self unbind];
	self.view = theView;
	
	id subView = (viewTag >= 0) ? [self.view viewWithTag:viewTag] : self.view;
	if(!subView){
		NSAssert(NO,@"Invalid subView object in CKUIViewDataBinder");
	}
	
	id dataValue = [target valueForKeyPath:targetKeyPath];
	
	CKObjectProperty* propertyDescriptor = [NSObject property:subView forKeyPath:keyPath];
	[subView setValue:[CKValueTransformer transformValue:dataValue toClass:propertyDescriptor.type] forKeyPath:keyPath];
	
	if([subView isKindOfClass:[UIControl class]]){
		UIControl* control = (UIControl*)subView;
		[control addTarget:self action:@selector(controlChange) forControlEvents:controlEvents];
	}
	
	[target addObserver:self
				   forKeyPath:targetKeyPath
					  options:(NSKeyValueObservingOptionNew)
					  context:nil];
}



@end


