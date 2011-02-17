//
//  CKViewExecutionBlock.h
//  NFB
//
//  Created by Sebastien Morel on 11-01-26.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

typedef void(^CKUIControlActionBlock)();


@interface CKUIControlActionBlockBinder : NSObject{
	NSInteger viewTag;
	NSString* keyPath;
	UIControlEvents controlEvents;
	CKUIControlActionBlock actionBlock;
	
	UIView* view;
}

@property (nonatomic, assign) NSInteger viewTag;
@property (nonatomic, assign) UIControlEvents controlEvents;
@property (nonatomic, copy) CKUIControlActionBlock actionBlock;
@property (nonatomic, retain) NSString *keyPath;

+ (CKUIControlActionBlockBinder*)actionBlockBinderForView:(UIView*)view viewTag:(NSUInteger)viewTag keyPath:(NSString*)keyPath 
											controlEvents:(UIControlEvents)controlEvents actionBlock:(CKUIControlActionBlock)actionBlock;


+ (CKUIControlActionBlockBinder*)actionBlockBinderForView:(UIView*)view viewTag:(NSUInteger)viewTag
											controlEvents:(UIControlEvents)controlEvents actionBlock:(CKUIControlActionBlock)actionBlock;

+ (CKUIControlActionBlockBinder*)actionBlockBinderForView:(UIView*)view keyPath:(NSString*)keyPath 
											controlEvents:(UIControlEvents)controlEvents actionBlock:(CKUIControlActionBlock)actionBlock;

+ (CKUIControlActionBlockBinder*)actionBlockBinderForView:(UIView*)view 
											controlEvents:(UIControlEvents)controlEvents actionBlock:(CKUIControlActionBlock)actionBlock;

+ (CKUIControlActionBlockBinder*)actionBlockBinderForView:(UIView*)view viewTag:(NSUInteger)viewTag keyPath:(NSString*)keyPath 
											actionBlock:(CKUIControlActionBlock)actionBlock;


+ (CKUIControlActionBlockBinder*)actionBlockBinderForView:(UIView*)view viewTag:(NSUInteger)viewTag
											actionBlock:(CKUIControlActionBlock)actionBlock;

+ (CKUIControlActionBlockBinder*)actionBlockBinderForView:(UIView*)view keyPath:(NSString*)keyPath 
											actionBlock:(CKUIControlActionBlock)actionBlock;

+ (CKUIControlActionBlockBinder*)actionBlockBinderForView:(UIView*)view 
											  actionBlock:(CKUIControlActionBlock)actionBlock;

-(void)bindControlInView:(UIView*)controlView;

@end
