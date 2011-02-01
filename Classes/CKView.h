//
//  CKNibViewController.h
//  NFB
//
//  Created by Sebastien Morel on 11-01-26.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKUIViewDataBinder.h"
#import "CKUIControlActionBlockBinder.h"

@interface CKUIViewBinderTemplate : NSObject
- (id)createBinderForView:(UIView*)view withTarget:(id)target;
@end

@interface CKUIViewDataBinderTemplate: CKUIViewBinderTemplate {
	NSString* targetKeyPath;
	int viewTag;
	NSString* keyPath;
}

@property (nonatomic, retain) NSString *targetKeyPath;
@property (nonatomic, assign) int viewTag;
@property (nonatomic, retain) NSString *keyPath;

+(CKUIViewDataBinderTemplate*)templateForViewTag:(int)viewTag viewKeyPath:(NSString*)keyPath targetKeyPath:(NSString*)targetKeyPath;

@end


typedef CKUIControlActionBlock (^CKUIControlActionBlockBuilder)(id target);
@interface CKUIControlActionBlockBinderTemplate : CKUIViewBinderTemplate {
	int viewTag;
	UIControlEvents controlEvents;
	CKUIControlActionBlockBuilder actionBlockBuilder;
}

@property (nonatomic, retain) CKUIControlActionBlockBuilder actionBlockBuilder;
@property (nonatomic, assign) int viewTag;
@property (nonatomic, assign) UIControlEvents controlEvents;

+(CKUIControlActionBlockBinderTemplate*)templateForViewTag:(int)viewTag forControlEvents:(UIControlEvents)controlEvents actionBlockBuilder:(CKUIControlActionBlockBuilder)actionBlockBuilder;

@end


typedef UIView*(^CKViewCreationBlock)();
@interface CKViewTemplate : NSObject{
	CKViewCreationBlock viewCreationBlock;
	NSArray* bindingTemplates;//configure how to bind subdata to view by tag
}

@property (nonatomic, retain) CKViewCreationBlock viewCreationBlock;
@property (nonatomic, retain) NSArray *bindingTemplates;

@end


@interface CKView : UIView {
	CKViewTemplate* viewTemplate;
	NSMutableArray* internal;
	UIView* subView;
}

@property (nonatomic, retain) CKViewTemplate *viewTemplate;

-(void)bind:(id)object;
-(void)unbind;

@end
