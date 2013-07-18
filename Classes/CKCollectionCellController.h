//
//  CKCollectionCellController.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKObject.h"
#import "CKCallback.h"
#import "CKWeakRef.h"
#import "CKStyleManager.h"


/**
 */
enum{
	CKItemViewFlagNone = 1UL << 0,
	CKItemViewFlagSelectable = 1UL << 1,
	CKItemViewFlagEditable = 1UL << 2,
	CKItemViewFlagRemovable = 1UL << 3,
	CKItemViewFlagMovable = 1UL << 4,
	CKItemViewFlagAll = CKItemViewFlagSelectable | CKItemViewFlagEditable | CKItemViewFlagRemovable | CKItemViewFlagMovable
};
typedef NSUInteger CKItemViewFlags;


@class CKCollectionViewController;

/**
 */
@interface CKCollectionCellController : NSObject


///-----------------------------------
/// @name Identifying the Controller at runtime
///-----------------------------------

/**
 */
@property (nonatomic, retain) NSString *name;

/**
 */
@property (nonatomic, copy, readonly) NSIndexPath *indexPath;

/**
 */
- (NSString*)identifier;

///-----------------------------------
/// @name Managing Content
///-----------------------------------

/**
 */
@property (nonatomic, assign, readonly) CKCollectionViewController* containerController;

/**
 */
@property (nonatomic, retain) id value;

/**
 */
@property (nonatomic, assign) UIView *view;

///-----------------------------------
/// @name Customizing the Controller Interactions And Visual Appearance
///-----------------------------------

/**
 */
@property (nonatomic, assign) CKItemViewFlags flags;

/**
 */
@property (nonatomic, assign) CGSize size;

/**
 */
@property (nonatomic, retain) CKCallback* deallocCallback;

/**
 */
@property (nonatomic, retain) CKCallback* createCallback;

/**
 */
@property (nonatomic, retain) CKCallback* viewInitCallback;

/**
 */
@property (nonatomic, retain) CKCallback* setupCallback;

/**
 */
@property (nonatomic, retain) CKCallback* selectionCallback;

/**
 */
@property (nonatomic, retain) CKCallback* accessorySelectionCallback;

/**
 */
@property (nonatomic, retain) CKCallback* becomeFirstResponderCallback;

/**
 */
@property (nonatomic, retain) CKCallback* resignFirstResponderCallback;

/**
 */
@property (nonatomic, retain) CKCallback* viewDidAppearCallback;

/**
 */
@property (nonatomic, retain) CKCallback* viewDidDisappearCallback;

/**
 */
@property (nonatomic, retain) CKCallback* layoutCallback;

/** This callback is called when the collection view commits editing changes to this cell controller.
 By default, removeCallback is nil.
 If you implements it you will have to manually remove the cell or the object from the binded collections.
 */
@property (nonatomic, retain) CKCallback* removeCallback;


///-----------------------------------
/// @name Responding to ContainerController Events
///-----------------------------------

/**
 */
- (void)viewDidAppear:(UIView *)view;

/**
 */
- (void)viewDidDisappear;

/**
 */
- (UIView *)loadView;

/**
 */
- (void)initView:(UIView*)view;

/**
 */
- (void)setupView:(UIView *)view;

/**
 */
- (void)rotateView:(UIView*)view animated:(BOOL)animated;

/**
 */
- (NSIndexPath *)willSelect;

/**
 */
- (void)didSelect;

/**
 */
- (void)didSelectAccessoryView;

/**
 */
- (void)didBecomeFirstResponder;

/**
 */
- (void)didResignFirstResponder;


///-----------------------------------
/// @name Managing Stylesheets
///-----------------------------------

/** This will return the containerController's StyleManager.
 */
- (CKStyleManager*)styleManager;

/** This will apply the style to the sub views
 */
- (void)applyStyle;

/** This will apply the style to the controller itself
 */
- (void)applyControllerStyle;

/**
 */
- (NSMutableDictionary*)stylesheet;

///-----------------------------------
/// @name Initializing a Controller
///-----------------------------------

/**
 */
- (void)postInit;

/**
 */
- (void)invalidateSize;

/**
 */
- (void)setSize:(CGSize)size notifyingContainerForUpdate:(BOOL)notifyingContainerForUpdate;

@end

