//
//  CKAlertView.m
//  AppCoreKit
//
//  Created by Fred Brunel.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKAlertView.h"
#import "NSObject+Bindings.h"


@interface CKAlertViewAction : NSObject {
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, copy) CKAlertViewActionBlock actionBlock;

- (id)initWithTitle:(NSString *)title actionBlock:(CKAlertViewActionBlock)actionBlock;
+ (id)actionWithTitle:(NSString *)title actionBlock:(CKAlertViewActionBlock)actionBlock;

@end

//

@interface CKAlertView ()

@property (nonatomic, retain, readwrite) UIAlertView *alertView;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSMutableArray *actions;

@end

//

@implementation CKAlertView

@synthesize alertView = _alertView;
@synthesize title = _title;
@synthesize message = _message;
@synthesize actions = _actions;
@synthesize deallocBlock = _deallocBlock;

- (void)postInit {
	self.title = nil;
	self.message = nil;
	self.actions = [NSMutableArray array];
    
	self.alertView = [[[UIAlertView alloc] init] autorelease];
	self.alertView.delegate = self;
}

- (id)init {
	self = [super init];
	if (self) {
		[self postInit];
	}
	return self;
}

+ (id)alertViewWithTitle:(NSString *)title message:(NSString *)message{
    return [[[CKAlertView alloc]initWithTitle:title message:message]autorelease];
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message {
	self = [super init];
	if (self) {
		[self postInit];
		self.title = title;
		self.message = message;
	}
	return self;
}

- (void)dealloc {
    if(_deallocBlock){
        _deallocBlock();
    }
    [self clearBindingsContext];
	self.title = nil;
	self.message = nil;
//	self.alertView.delegate = nil;
	self.alertView = nil;
	self.actions = nil;
    [_deallocBlock release];
    _deallocBlock = nil;
	[super dealloc];
}

#pragma mark - Buttons

- (void)addButtonWithTitle:(NSString *)title action:(void (^)(void))actionBlock {
	[self.actions addObject:[CKAlertViewAction actionWithTitle:title actionBlock:actionBlock]];
}

#pragma mark - Setup the AlertView

- (void)setupAlertView {
	self.alertView.title = self.title;
	self.alertView.message = self.message;
	
	for (CKAlertViewAction *action in self.actions) {
		[self.alertView addButtonWithTitle:action.title];
	}
}

#pragma mark - Present the AlertView

- (void)show {
	[self setupAlertView];
	[self.alertView show];
	[self retain];
}

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex >= [self.actions count]) return;
	CKAlertViewAction *action = [self.actions objectAtIndex:buttonIndex];
	if (action.actionBlock) action.actionBlock();
	[self release];
}

@end


#pragma mark -
#pragma mark - CKActionSheetAction

@implementation CKAlertViewAction

@synthesize title = _title;
@synthesize actionBlock = _actionBlock;

- (id)initWithTitle:(NSString *)title actionBlock:(CKAlertViewActionBlock)actionBlock {
	self = [super init];
	if (self) {
		self.title = title;
		self.actionBlock = actionBlock;
	}
	return self;
}

+ (id)actionWithTitle:(NSString *)title actionBlock:(CKAlertViewActionBlock)actionBlock {
	return [[[CKAlertViewAction alloc] initWithTitle:title actionBlock:actionBlock] autorelease];
}

- (void)dealloc {
	self.title = nil;
	self.actionBlock = nil;
	[super dealloc];
}

@end
