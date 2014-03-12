//
//  CKSwipableCollectionCellContentViewController.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2/12/2014.
//  Copyright (c) 2014 Sebastien Morel. All rights reserved.
//

#import "CKCollectionCellContentViewController.h"

@class CKSwipableCollectionCellContentViewController;

typedef enum CKSwipableCollectionCellActionAnimationStyle{
    CKSwipableCollectionCellActionAnimationStyleNone,
    CKSwipableCollectionCellActionAnimationStyleSwipeOutContentLeft,
    CKSwipableCollectionCellActionAnimationStyleSwipeOutContentRight,
    CKSwipableCollectionCellActionAnimationStyleBounceAndHiglight
}CKSwipableCollectionCellActionAnimationStyle;

typedef enum CKSwipableCollectionCellActionGroupStyle{
    CKSwipableCollectionCellActionGroupStyleSwipeToReveal,
    CKSwipableCollectionCellActionGroupStyleSwipeToAction
}CKSwipableCollectionCellActionGroupStyle;



//CKSwipableCollectionCellAction ---------------------------------




/** Actions will be represented by buttons.
 Buttons will be created in viewDidLoad and can be customized in CKSwipableCollectionCellContentViewController's contentViewController stylesheet by targeting "UIButton[name=name]" or by implementing the setupActionViewAppearance block.
 action will be performed on tap if action group style is CKSwipableCollectionCellActionGroupStyleSwipeToReveal or when releasing scrollview if group style is CKSwipableCollectionCellActionGroupStyleSwipeToAction.
 
 As we are in a reuse view architecture, actions buttons will get reused too.
 */
@interface CKSwipableCollectionCellAction : NSObject

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
@property(nonatomic,copy) void(^actionAnimation)( CKSwipableCollectionCellContentViewController* controller, UIButton* actionView, void(^endAnimation)() );

/**
 */
+ (CKSwipableCollectionCellAction*)actionWithName:(NSString*)name action:(void(^)())action;

/**
 */
+ (CKSwipableCollectionCellAction*)actionWithName:(NSString*)name animationStyle:(CKSwipableCollectionCellActionAnimationStyle)animationStyle action:(void(^)())action;

/**
 */
- (id)initWithName:(NSString*)name action:(void(^)())action;

/**
 */
- (id)initWithName:(NSString*)name animationStyle:(CKSwipableCollectionCellActionAnimationStyle)animationStyle action:(void(^)())action;


/** This will set the actionAnimation with default predefined animation with the specified style
 */
- (void)setAnimationStyle:(CKSwipableCollectionCellActionAnimationStyle)style;

@end




//CKSwipableCollectionCellActionGroup ---------------------------------



/**
 */
@interface CKSwipableCollectionCellActionGroup : NSObject

/**
 */
@property(nonatomic,assign) CKSwipableCollectionCellActionGroupStyle style;

/**
 */
@property(nonatomic,retain) NSArray* actions;

/**
 */
@property(nonatomic,copy) void(^setupActionGroupViewAppearance)(UIView* actionGroupView);

/**
 */
+ (CKSwipableCollectionCellActionGroup*)actionGroupWithStyle:(CKSwipableCollectionCellActionGroupStyle)style actions:(NSArray*)actions;

/**
 */
- (id)initWithStyle:(CKSwipableCollectionCellActionGroupStyle)style actions:(NSArray*)actions;

@end





//CKSwipableCollectionCellContentViewController ---------------------------------

/**
 */
@interface CKSwipableCollectionCellContentViewController : CKCollectionCellContentViewController

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
@property(nonatomic,retain) CKSwipableCollectionCellActionGroup* leftActions;

/**
 */
@property(nonatomic,retain) CKSwipableCollectionCellActionGroup* rightActions;

/**
 */
@property(nonatomic,retain,readonly) CKCollectionCellContentViewController* contentViewController;

/**
 */
- (id)initWithContentViewController:(CKCollectionCellContentViewController*)contentViewController;

@end





//CKCollectionCellContentViewController ---------------------------------

/**
 */
@interface CKCollectionCellContentViewController(CKSwipableCollectionCellContentViewController)

/**
 */
@property(nonatomic,readonly) CKSwipableCollectionCellContentViewController* parentSwipeableContentViewController;

@end
