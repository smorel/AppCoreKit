//
//  CKViewDataBinder.h
//  CloudKitApp
//
//  Created by Sebastien Morel on 11-01-26.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//


@interface CKUIViewDataBinder : NSObject{
	NSInteger viewTag;
	NSString* keyPath;
	UIControlEvents controlEvents;
	
	id target;
	NSString* targetKeyPath;
	
	//Internal
	UIView* view;
	BOOL binded;
}

@property (nonatomic, assign) NSInteger viewTag;
@property (nonatomic, retain) NSString *keyPath;
@property (nonatomic, assign) id target;
@property (nonatomic, retain) NSString *targetKeyPath;
@property (nonatomic, assign) UIControlEvents controlEvents;

+ (CKUIViewDataBinder*)dataBinderForView:(UIView*)view viewTag:(NSInteger)viewTag keyPath:(NSString*)keyPath 
						   controlEvents:(UIControlEvents)controlEvents target:(id)target targetKeyPath:(NSString*)targetKeyPath;

+ (CKUIViewDataBinder*)dataBinderForView:(UIView*)view keyPath:(NSString*)keyPath 
						   controlEvents:(UIControlEvents)controlEvents target:(id)target targetKeyPath:(NSString*)targetKeyPath;


+ (CKUIViewDataBinder*)dataBinderForView:(UIView*)view viewTag:(NSInteger)viewTag keyPath:(NSString*)keyPath 
						   target:(id)target targetKeyPath:(NSString*)targetKeyPath;

+ (CKUIViewDataBinder*)dataBinderForView:(UIView*)view keyPath:(NSString*)keyPath 
						   target:(id)target targetKeyPath:(NSString*)targetKeyPath;

-(void)bindViewInView:(UIView*)theView;
-(void)unbind;

@end


@interface UIView (CKUIViewDataBinder)
+ (void)setValueForView : (UIView*)view viewTag:(NSInteger)viewTag keyPath:(NSString*)keyPath target:(id)target targetKeyPath:(NSString*)targetKeyPath;
+ (void)setValueForView : (UIView*)view keyPath:(NSString*)keyPath  target:(id)target targetKeyPath:(NSString*)targetKeyPath;
@end
