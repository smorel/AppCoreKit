//
//  CKSwipeableViewController.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2/12/2014.
//  Copyright (c) 2014 Sebastien Morel. All rights reserved.
//

#import "CKReusableViewController.h"

@class CKSwipeableViewController;

typedef NS_ENUM (NSInteger,CKSwipeableActionAnimationStyle){
    CKSwipeableActionAnimationStyleNone,
    CKSwipeableActionAnimationStyleSwipeOutContentLeft,
    CKSwipeableActionAnimationStyleSwipeOutContentRight,
    CKSwipeableActionAnimationStyleBounceAndHiglight
};

typedef NS_ENUM(NSInteger, CKSwipeableActionGroupStyle){
    CKSwipeableActionGroupStyleSwipeToReveal,
    CKSwipeableActionGroupStyleSwipeToAction
};


//CKSwipeableAction ---------------------------------




/** Actions will be represented by buttons.
 Buttons will be created in viewDidLoad and can be customized in CKSwipableCollectionCellContentViewController's contentViewController stylesheet by targeting "UIButton[name=name]" or by implementing the setupActionViewAppearance block.
 action will be performed on tap if action group style is CKSwipeableActionGroupStyleSwipeToReveal or when releasing scrollview if group style is CKSwipeableActionGroupStyleSwipeToAction.
 
 As we are in a reuse view architecture, actions buttons will get reused too.
 */
@interface CKSwipeableAction : NSObject

/**
 */
@property(nonatomic,retain) NSString* name;

/**
 */
@property(nonatomic,assign) BOOL enabled;

/**
 */
@property(nonatomic,copy) void(^action)();

/**
 */
@property(nonatomic,copy) void(^setupActionViewAppearance)(UIButton* actionView);


/** Do your animation then calls the endAnimation block that is given as an attribute. The action block will get executed when you call endAnimation()
 If actionAnimation is nil, the action block is called directly.
 */
@property(nonatomic,copy) void(^actionAnimation)( CKSwipeableViewController* controller, UIButton* actionView, void(^endAnimation)() );

/**
 */
+ (CKSwipeableAction*)actionWithName:(NSString*)name action:(void(^)())action;

/**
 */
+ (CKSwipeableAction*)actionWithName:(NSString*)name animationStyle:(CKSwipeableActionAnimationStyle)animationStyle action:(void(^)())action;

/**
 */
- (id)initWithName:(NSString*)name action:(void(^)())action;

/**
 */
- (id)initWithName:(NSString*)name animationStyle:(CKSwipeableActionAnimationStyle)animationStyle action:(void(^)())action;


/** This will set the actionAnimation with default predefined animation with the specified style
 */
- (void)setAnimationStyle:(CKSwipeableActionAnimationStyle)style;

@end




//CKSwipeableActionGroup ---------------------------------



/**
 */
@interface CKSwipeableActionGroup : NSObject

/**
 */
@property(nonatomic,assign) CKSwipeableActionGroupStyle style;

/**
 */
@property(nonatomic,retain) NSArray* actions;

/**
 */
@property(nonatomic,copy) void(^setupActionGroupViewAppearance)(UIView* actionGroupView);

/**
 */
+ (CKSwipeableActionGroup*)actionGroupWithStyle:(CKSwipeableActionGroupStyle)style actions:(NSArray*)actions;

/**
 */
- (id)initWithStyle:(CKSwipeableActionGroupStyle)style actions:(NSArray*)actions;

@end





//CKSwipeableViewController ---------------------------------

/**
 */
@interface CKSwipeableViewController : CKReusableViewController

/**
 */
@property(nonatomic,retain,readonly) UIScrollView* scrollView;

/**
 */
@property(nonatomic,retain,readonly) UIView* scrollContentView;

/**
 */
@property(nonatomic,retain,readonly) UIView* leftActionsViewContainer;

/**
 */
@property(nonatomic,retain,readonly) UIView* rightActionsViewContainer;

/** By setting enabled to NO, this will disable scrolling in scrollView and hide actions and actions containers.
    Default value is YES.
 */
@property(nonatomic,assign) BOOL enabled;

/**
 */
@property(nonatomic,retain) CKSwipeableActionGroup* leftActions;

/**
 */
@property(nonatomic,retain) CKSwipeableActionGroup* rightActions;

/**
 */
@property(nonatomic,retain,readonly) CKReusableViewController* contentViewController;

/**
 */
- (id)initWithContentViewController:(CKReusableViewController*)contentViewController;

@end





//CKReusableViewController ---------------------------------

/**
 */
@interface CKReusableViewController(CKSwipeableViewController)

/**
 */
@property(nonatomic,readonly) CKSwipeableViewController* parentSwipeableContentViewController;

@end
