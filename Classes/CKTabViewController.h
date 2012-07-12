//
//  CKTabViewController.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKContainerViewController.h"

@class CKTabViewItem;
@protocol CKTabViewDelegate;

/**
 */
typedef enum CKTabViewStyle{
    CKTabViewStyleFill,
    CKTabViewStyleCenter,
    CKTabViewStyleAlignLeft,
    CKTabViewStyleAlignRight
}CKTabViewStyle;

/**
 */
@interface CKTabView : UIView

///-----------------------------------
/// @name Managing the delegate
///-----------------------------------

/**
 */
@property (nonatomic, assign) id<CKTabViewDelegate> delegate;

///-----------------------------------
/// @name Customizing the tab controller content
///-----------------------------------

/**
 */
@property (nonatomic, copy) NSArray* items;

/**
 */
@property (nonatomic, assign) NSUInteger selectedIndex;

///-----------------------------------
/// @name Customizing the tab controller appearance
///-----------------------------------

/**
 */
@property (nonatomic, assign) CKTabViewStyle style;

/**
 */
@property (nonatomic, assign) CGFloat itemsSpace;

/**
 */
@property (nonatomic, assign) UIEdgeInsets contentInsets;

/**
 */
@property (nonatomic, retain) UIView* selectedTabIndicatorView;

@end




/**
 */
@protocol CKTabViewDelegate <NSObject>

///-----------------------------------
/// @name Reacting to Tab Controller Events
///-----------------------------------

/**
 */
- (void)tabView:(CKTabView *)tabView didSelectItemAtIndex:(NSUInteger)index;

@end


/**
 */
typedef enum CKTabViewItemPosition{
    CKTabViewItemPositionFirst  = 1 << 0,
    CKTabViewItemPositionMiddle = 1 << 1,
    CKTabViewItemPositionLast   = 1 << 2,
    CKTabViewItemPositionAlone  = 1 << 3
}CKTabViewItemPosition;


/**
 */
@interface CKTabViewItem : UIButton

///-----------------------------------
/// @name Accessing the tab item status
///-----------------------------------

/**
 */
@property(nonatomic,assign,readonly)CKTabViewItemPosition position;

@end


@class CKTabViewController;
typedef void(^CKTabViewControllerSelectionBlock)(CKTabViewController* controller,NSInteger index);


/**
 */
typedef enum CKTabViewControllerStyle{
    CKTabViewControllerStyleBottom,
    CKTabViewControllerStyleTop
}CKTabViewControllerStyle;


/**
 */
@interface CKTabViewController : CKContainerViewController <CKTabViewDelegate>

///-----------------------------------
/// @name Getting the tab view
///-----------------------------------

/**
 */
@property (nonatomic, retain, readonly) CKTabView *tabBar;

///-----------------------------------
/// @name Customizing the appearance
///-----------------------------------

/**
 */
@property (nonatomic, assign) CKTabViewControllerStyle style;

///-----------------------------------
/// @name Customizing selection behaviour
///-----------------------------------

/**
 */
@property (nonatomic, copy) CKTabViewControllerSelectionBlock willSelectViewControllerBlock;

/**
 */
@property (nonatomic, copy) CKTabViewControllerSelectionBlock didSelectViewControllerBlock;

@end



/**
 */
@interface UIViewController (CKTabViewItem)

///-----------------------------------
/// @name Customizing the tab bar item
///-----------------------------------

/**
 */
@property (nonatomic, retain) CKTabViewItem *tabViewItem;

@end
