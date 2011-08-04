//
//  CKActionSheet.m
//  CloudKit
//
//  Created by Olivier Collet on 11-07-07.
//  Copyright 2011 WhereCloud. All rights reserved.
//

#import "CKActionSheet.h"


@interface CKActionSheetAction : NSObject {
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, copy) CKActionSheetActionBlock actionBlock;

- (id)initWithTitle:(NSString *)title actionBlock:(CKActionSheetActionBlock)actionBlock;
+ (id)actionWithTitle:(NSString *)title actionBlock:(CKActionSheetActionBlock)actionBlock;

@end

//

@interface CKActionSheet ()

@property (nonatomic, retain) UIActionSheet *actionSheet;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, assign) NSInteger cancelButtonIndex;
@property (nonatomic, assign) NSInteger destructiveButtonIndex;
@property (nonatomic, retain) NSMutableArray *actions;

@end

//

@implementation CKActionSheet

@synthesize title = _title;
@synthesize actionSheet = _actionSheet;
@synthesize cancelButtonIndex = _cancelButtonIndex;
@synthesize destructiveButtonIndex = _destructiveButtonIndex;
@synthesize actions = _actions;
@synthesize actionSheetStyle = _actionSheetStyle;
@synthesize cancelOnEnterBackground = _cancelOnEnterBackground;


- (void)postInit {
	self.title = nil;
	self.actions = [NSMutableArray array];
	self.cancelButtonIndex = -1;
	self.destructiveButtonIndex = -1;
	self.actionSheetStyle = UIActionSheetStyleAutomatic;
	self.cancelOnEnterBackground = NO;
}

- (id)init {
	self = [super init];
	if (self) {
		[self postInit];
	}
	return self;
}

- (id)initWithTitle:(NSString *)title {
	self = [super init];
	if (self) {
		[self postInit];
		self.title = title;
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	self.title = nil;
	self.actionSheet.delegate = nil;
	self.actionSheet = nil;
	self.actions = nil;
	[super dealloc];
}

#pragma mark - Buttons

- (void)addButtonWithTitle:(NSString *)title action:(void (^)(void))actionBlock {
	[self.actions addObject:[CKActionSheetAction actionWithTitle:title actionBlock:actionBlock]];
}

- (void)addCancelButtonWithTitle:(NSString *)title action:(void (^)(void))actionBlock {
	NSAssert((self.cancelButtonIndex == -1), @"The cancel action is already set.");
	[self addButtonWithTitle:title action:actionBlock];
	self.cancelButtonIndex = [self.actions count] - 1;
}

- (void)addDestructiveButtonWithTitle:(NSString *)title action:(void (^)(void))actionBlock {
	NSAssert((self.destructiveButtonIndex == -1), @"The desctructive action is already set.");
	[self addButtonWithTitle:title action:actionBlock];
	self.destructiveButtonIndex = [self.actions count] - 1;
}

#pragma mark - Setup the ActionSheet

- (void)setupActionSheet {
	self.actionSheet = [[[UIActionSheet alloc] init] autorelease];
	self.actionSheet.delegate = self;
	self.actionSheet.title = self.title;
	self.actionSheet.actionSheetStyle = self.actionSheetStyle;

	for (CKActionSheetAction *action in self.actions) {
		[self.actionSheet addButtonWithTitle:action.title];
	}

	if (self.cancelButtonIndex >= 0) self.actionSheet.cancelButtonIndex = self.cancelButtonIndex;
	if (self.destructiveButtonIndex >= 0) self.actionSheet.destructiveButtonIndex = self.destructiveButtonIndex;

	if (self.cancelOnEnterBackground && (self.cancelButtonIndex != -1)) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
	}
}

#pragma mark - Present the ActionSheet

- (void)showFromTabBar:(UITabBar *)tabBar {
	[self setupActionSheet];
	[self.actionSheet showFromTabBar:tabBar];
}

- (void)showFromToolbar:(UIToolbar *)toolbar {
	[self setupActionSheet];
	[self.actionSheet showFromToolbar:toolbar];
}

- (void)showInView:(UIView *)view {
	[self setupActionSheet];
	[self.actionSheet showInView:view];
}

- (void)showFromBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated {
	[self setupActionSheet];
	[self.actionSheet showFromBarButtonItem:item animated:animated];
}

- (void)showFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated {
	[self setupActionSheet];
	[self.actionSheet showFromRect:rect inView:view animated:animated];
}

#pragma mark - UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex >= [self.actions count]) return;
	CKActionSheetAction *action = [self.actions objectAtIndex:buttonIndex];
	if (action.actionBlock) action.actionBlock();
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
	[self retain];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	[self release];
}

#pragma mark - Notification

- (void)applicationDidEnterBackground:(NSNotification *)notification {
	[self.actionSheet dismissWithClickedButtonIndex:self.cancelButtonIndex animated:NO];
}

@end


#pragma mark -
#pragma mark - CKActionSheetAction

@implementation CKActionSheetAction

@synthesize title = _title;
@synthesize actionBlock = _actionBlock;

- (id)initWithTitle:(NSString *)title actionBlock:(CKActionSheetActionBlock)actionBlock {
	self = [super init];
	if (self) {
		self.title = title;
		self.actionBlock = actionBlock;
	}
	return self;
}

+ (id)actionWithTitle:(NSString *)title actionBlock:(CKActionSheetActionBlock)actionBlock {
	return [[[CKActionSheetAction alloc] initWithTitle:title actionBlock:actionBlock] autorelease];
}

- (void)dealloc {
	self.title = nil;
	self.actionBlock = nil;
	[super dealloc];
}

@end
