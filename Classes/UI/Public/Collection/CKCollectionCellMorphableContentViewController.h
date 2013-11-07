//
//  CKCollectionCellMorphableContentViewController.h
//  VARLab
//
//  Created by Sebastien Morel on 2013-10-24.
//  Copyright (c) 2013 Sebastien Morel. All rights reserved.
//

#import "CKCollectionCellContentViewController.h"
#import "CKCollectionViewMorphableLayout.h"

@class CKCollectionCellMorphableContentViewControllerTransition;

@interface CKCollectionCellMorphableContentViewController : CKCollectionCellContentViewController<CKCollectionViewMorphableLayoutDelegate>

@property(nonatomic,retain,readonly) NSArray* contentViewControllers;

//array of CKCollectionCellContentViewController
- (id)initWithContentViewControllers:(NSArray*)contentViewControllers;

@end


@interface CKCollectionCellMorphableContentViewControllerTransition : NSObject

@property(nonatomic,assign,readonly) CKCollectionCellContentViewController* contentViewController;
@property(nonatomic,assign,readonly) NSInteger contentViewControllerIndex;
@property(nonatomic,assign,readonly) CGRect frame;
@property(nonatomic,assign,readonly) UIView* view;
@property(nonatomic,assign,readonly) BOOL isPerformingTransition;

- (void)startTransition;
- (void)performTransitionWithRatio:(CGFloat)ratio velocity:(CGFloat)velocity;
- (void)endTransition;

@end


@interface CKCollectionCellMorphableContentViewControllerCrossFadeTransition : CKCollectionCellMorphableContentViewControllerTransition
@end


@interface CKCollectionCellContentViewController(CKCollectionCellMorphableContentViewController)

@property(nonatomic,retain) CKCollectionCellMorphableContentViewControllerTransition* transition;

@end
