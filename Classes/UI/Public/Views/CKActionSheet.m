//
//  CKActionSheet.m
//  AppCoreKit
//
//  Created by Olivier Collet.
//  Copyright 2011 WhereCloud. All rights reserved.
//

#import "CKActionSheet.h"
#import "CKDebug.h"


@interface CKActionSheetAction : NSObject {
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, assign) CKActionSheetImageAlignment imageAlignment;
@property (nonatomic, copy) CKActionSheetActionBlock actionBlock;

- (id)initWithTitle:(NSString *)title image:(UIImage*)image  imageAlignment:(CKActionSheetImageAlignment)imageAlignment actionBlock:(CKActionSheetActionBlock)actionBlock;
+ (id)actionWithTitle:(NSString *)title image:(UIImage*)image  imageAlignment:(CKActionSheetImageAlignment)imageAlignment actionBlock:(CKActionSheetActionBlock)actionBlock;

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
	[self addButtonWithTitle:title image:nil imageAlignment:CKActionSheetImageAlignmentLeft action:actionBlock];
}

- (void)addCancelButtonWithTitle:(NSString *)title action:(void (^)(void))actionBlock {
	[self addCancelButtonWithTitle:title image:nil imageAlignment:CKActionSheetImageAlignmentLeft action:actionBlock];
}

- (void)addDestructiveButtonWithTitle:(NSString *)title action:(void (^)(void))actionBlock {
	[self addDestructiveButtonWithTitle:title image:nil imageAlignment:CKActionSheetImageAlignmentLeft action:actionBlock];
}

- (void)addButtonWithTitle:(NSString *)title image:(UIImage*)image imageAlignment:(CKActionSheetImageAlignment)imageAlignment  action:(void (^)(void))actionBlock {
	[self.actions addObject:[CKActionSheetAction actionWithTitle:title image:image imageAlignment:imageAlignment actionBlock:actionBlock]];
}

- (void)addCancelButtonWithTitle:(NSString *)title image:(UIImage*)image imageAlignment:(CKActionSheetImageAlignment)imageAlignment  action:(void (^)(void))actionBlock {
	CKAssert((self.cancelButtonIndex == -1), @"The cancel action is already set.");
	[self addButtonWithTitle:title image:image imageAlignment:imageAlignment action:actionBlock];
	self.cancelButtonIndex = [self.actions count] - 1;
}

- (void)addDestructiveButtonWithTitle:(NSString *)title image:(UIImage*)image imageAlignment:(CKActionSheetImageAlignment)imageAlignment action:(void (^)(void))actionBlock {
	CKAssert((self.destructiveButtonIndex == -1), @"The desctructive action is already set.");
	[self addButtonWithTitle:title image:image imageAlignment:imageAlignment action:actionBlock];
	self.destructiveButtonIndex = [self.actions count] - 1;
}

#pragma mark - Setup the ActionSheet

- (void)setupActionSheet {
	self.actionSheet = [[[UIActionSheet alloc] init] autorelease];
	self.actionSheet.delegate = self;
	self.actionSheet.title = self.title;
	self.actionSheet.actionSheetStyle = self.actionSheetStyle;

	for (CKActionSheetAction *action in self.actions) {
		NSInteger index = [self.actionSheet addButtonWithTitle:action.title];
        if(action.image){
            UIButton* button = [[self.actionSheet valueForKey:@"_buttons"] objectAtIndex:index];
            UIImageView* img = [[UIImageView alloc]initWithImage:action.image];
            switch(action.imageAlignment){
                case CKActionSheetImageAlignmentLeft:{
                    
                    img.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
                    img.frame = CGRectMake(10, (button.bounds.size.height / 2) - (action.image.size.height / 2),
                                           action.image.size.width,action.image.size.height);
                    break;
                }
                case CKActionSheetImageAlignmentRight:{
                    
                    img.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
                    img.frame = CGRectMake(button.bounds.size.width - 10 - action.image.size.width, (button.bounds.size.height / 2) - (action.image.size.height / 2),
                                           action.image.size.width,action.image.size.height);
                    break;
                }
            }
            
            [button addSubview:img];
        }
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

- (id)initWithTitle:(NSString *)title  image:(UIImage*)image imageAlignment:(CKActionSheetImageAlignment)imageAlignment actionBlock:(CKActionSheetActionBlock)actionBlock {
	self = [super init];
	if (self) {
		self.title = title;
		self.image = image;
		self.imageAlignment = imageAlignment;
		self.actionBlock = actionBlock;
	}
	return self;
}

+ (id)actionWithTitle:(NSString *)title  image:(UIImage*)image imageAlignment:(CKActionSheetImageAlignment)imageAlignment actionBlock:(CKActionSheetActionBlock)actionBlock {
	return [[[CKActionSheetAction alloc] initWithTitle:title image:image imageAlignment:imageAlignment actionBlock:actionBlock] autorelease];
}

- (void)dealloc {
	self.title = nil;
	self.actionBlock = nil;
	[super dealloc];
}

@end
