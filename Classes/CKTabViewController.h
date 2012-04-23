//
//  CKTabViewController.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKContainerViewController.h"

@class CKTabViewItem;
@protocol CKTabViewDelegate;

typedef enum CKTabViewStyle{
    CKTabViewStyleFill,
    CKTabViewStyleCenter,
    CKTabViewStyleAlignLeft,
    CKTabViewStyleAlignRight
}CKTabViewStyle;

@interface CKTabView : UIView

@property (nonatomic, assign) id<CKTabViewDelegate> delegate;
@property (nonatomic, copy) NSArray* items;
@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, assign) CKTabViewStyle style;
@property (nonatomic, assign) CGFloat itemsSpace;
@property (nonatomic, assign) UIEdgeInsets contentInsets;
@property (nonatomic, retain) UIView* selectedTabIndicatorView;

@end


// CKTabViewDelegate

@protocol CKTabViewDelegate <NSObject>

- (void)tabView:(CKTabView *)tabView didSelectItemAtIndex:(NSUInteger)index;

@end

// CKTabViewItem

@interface CKTabViewItem : UIButton
@end


@class CKTabViewController;
typedef void(^CKTabViewControllerSelectionBlock)(CKTabViewController* controller,NSInteger index);

//CKTabViewController

typedef enum CKTabViewControllerStyle{
    CKTabViewControllerStyleBottom,
    CKTabViewControllerStyleTop
}CKTabViewControllerStyle;

@interface CKTabViewController : CKContainerViewController <CKTabViewDelegate>

@property (nonatomic, retain, readonly) CKTabView *tabBar;
@property (nonatomic, assign) CKTabViewControllerStyle style;
@property (nonatomic, copy) CKTabViewControllerSelectionBlock willSelectViewControllerBlock;
@property (nonatomic, copy) CKTabViewControllerSelectionBlock didSelectViewControllerBlock;

@end


// UIViewController Addition

@interface UIViewController (CKTabViewItem)

@property (nonatomic, retain) CKTabViewItem *tabViewItem;

@end
