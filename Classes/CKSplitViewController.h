//
//  CKSplitViewController.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-10-25.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import "CKViewController.h"
#import "CKObject.h"

//CKSplitViewConstraints


typedef enum CKSplitViewConstraintsType{
    CKSplitViewConstraintsTypeFlexibleSize,
    CKSplitViewConstraintsTypeFixedSizeInPixels,
    CKSplitViewConstraintsTypeFixedSizeRatio
}CKSplitViewConstraintsType;

@interface CKSplitViewConstraints : CKObject
@property(nonatomic,assign)CKSplitViewConstraintsType type;
@property(nonatomic,assign)CGFloat size;//in pixel or ratio
+ (CKSplitViewConstraints*)constraints;

@end

//CKSplitViewDelegate

@class CKSplitView;
@protocol CKSplitViewDelegate
@optional
- (NSInteger)numberOfViewsInSplitView:(CKSplitView*)view;
- (UIView*)splitView:(CKSplitView*)view viewAtIndex:(NSInteger)index;
- (CKSplitViewConstraints*)splitView:(CKSplitView*)view constraintsForViewAtIndex:(NSInteger)index;
@end

//CKSplitView

typedef enum CKSplitViewOrientation{
    CKSplitViewOrientationHorizontal,
    CKSplitViewOrientationVertical
}CKSplitViewOrientation;


@interface CKSplitView : UIView
@property(nonatomic,assign)id delegate;
@property(nonatomic,assign)CKSplitViewOrientation orientation;

- (void)reloadData;

@end

//CKSplitViewController

@interface CKSplitViewController : CKViewController
@property (nonatomic, copy) NSArray* viewControllers;
@property (nonatomic, retain, readonly) CKSplitView* splitView;

@property (nonatomic, copy) void (^addOrRemoveAnimationBlock)(UIView* view, BOOL removing);

- (id)initWithViewControllers:(NSArray*)viewControllers;
- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated;

@end


//UIViewController(CKSplitView)

@interface UIViewController(CKSplitView)
@property(nonatomic,retain)CKSplitViewConstraints* splitViewConstraints;
@end