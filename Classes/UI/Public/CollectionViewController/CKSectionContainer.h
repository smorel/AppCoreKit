//
//  CKSectionContainer.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-17.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKViewController.h"
#import "CKAbstractSection.h"
#import "CKSection.h"
#import "CKCollectionSection.h"

/**
 */
@interface UIView(CKSectionedViewController)
@property(nonatomic,retain) CKReusableViewController* reusableViewController;
@end



@class CKSectionContainer;

/**
 */
@protocol CKSectionContainerDelegate

@required

@property (nonatomic,retain,readonly) CKSectionContainer* sectionContainer;

- (void)didInsertSections:(NSArray*)sections atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated sectionUpdate:(void(^)())sectionUpdate;
- (void)didRemoveSections:(NSArray*)sections atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated sectionUpdate:(void(^)())sectionUpdate;
- (void)didInsertControllers:(NSArray*)controllers atIndexPaths:(NSArray*)indexPaths animated:(BOOL)animated sectionUpdate:(void(^)())sectionUpdate;
- (void)didRemoveControllers:(NSArray*)controllers atIndexPaths:(NSArray*)indexPaths animated:(BOOL)animated sectionUpdate:(void(^)())sectionUpdate;

@optional

- (void)willInsertSections:(NSArray*)sections atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated;
- (void)willRemoveSections:(NSArray*)sections atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated;
- (void)willInsertControllers:(NSArray*)controllers atIndexPaths:(NSArray*)indexPaths animated:(BOOL)animated;
- (void)willRemoveControllers:(NSArray*)controllers atIndexPaths:(NSArray*)indexPaths animated:(BOOL)animated;

- (void)performBatchUpdates:(void (^)(void))updates completion:(void (^)(BOOL finished))completion;

- (void)invalidateControllerAtIndexPath:(NSIndexPath*)indexPath;

@end





/**
 */
@interface CKSectionContainer : NSObject<CKSectionDelegate>

- (id)initWithDelegate:(UIViewController<CKSectionContainerDelegate>*)delegate;
- (id)initWithSections:(NSArray*)sections delegate:(UIViewController<CKSectionContainerDelegate>*)delegate;

@property(nonatomic,assign,readonly) UIViewController<CKSectionContainerDelegate>* delegate;
@property(nonatomic,retain,readonly) NSArray* sections;

- (NSInteger)indexOfSection:(CKAbstractSection*)section;
- (NSIndexSet*)indexesOfSections:(NSArray*)sections;

- (id)sectionAtIndex:(NSInteger)index;
- (NSArray*)sectionsAtIndexes:(NSIndexSet*)indexes;

- (void)addSection:(CKAbstractSection*)section animated:(BOOL)animated;
- (void)insertSection:(CKAbstractSection*)section atIndex:(NSInteger)index animated:(BOOL)animated;
- (void)addSections:(NSArray*)sections animated:(BOOL)animated;
- (void)insertSections:(NSArray*)sections atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated;

- (void)removeAllSectionsAnimated:(BOOL)animated;
- (void)removeSection:(CKAbstractSection*)section animated:(BOOL)animated;
- (void)removeSectionAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)removeSections:(NSArray*)sections animated:(BOOL)animated;
- (void)removeSectionsAtIndexes:(NSIndexSet*)indexes animated:(BOOL)animated;

- (CKReusableViewController*)controllerAtIndexPath:(NSIndexPath*)indexPath;
- (NSArray*)controllersAtIndexPaths:(NSArray*)indexPaths;

- (NSIndexPath*)indexPathForController:(CKReusableViewController*)controller;
- (NSArray*)indexPathsForControllers:(NSArray*)controllers;

- (UIView*)viewForController:(CKReusableViewController*)controller reusingView:(UIView*)view;
- (UIView*)viewForControllerAtIndexPath:(NSIndexPath*)indexPath reusingView:(UIView*)view;


@property(nonatomic,retain) NSArray* selectedIndexPaths;

- (void)handleViewWillAppearAnimated:(BOOL)animated;
- (void)handleViewDidAppearAnimated:(BOOL)animated;
- (void)handleViewWillDisappearAnimated:(BOOL)animated;
- (void)handleViewDidDisappearAnimated:(BOOL)animated;

@end
