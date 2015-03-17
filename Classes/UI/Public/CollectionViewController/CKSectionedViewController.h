//
//  CKSectionedViewController.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-17.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKViewController.h"
#import "CKAbstractSection.h"
#import "CKSection.h"
#import "CKCollectionSection.h"


@interface UIView(CKSectionedViewController)
@property(nonatomic,retain) CKCollectionCellContentViewController* attachedCellContentViewController;
@end

//this aims to be the nex generation of CKCollectionViewController.
//Tables, collection and maps will move to CKSectionedViewController.
                                               

/** These methods must be implemented in the inherited classes and refresh the views in consequence.
 Inherited classes are respondible to reload their view appropriatly in viewWillAppear.
 */
@protocol CKSectionedViewControllerProtocol

- (void)willInsertSections:(NSArray*)sections atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated;
- (void)didInsertSections:(NSArray*)sections atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated;

- (void)willRemoveSections:(NSArray*)sections atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated;
- (void)didRemoveSections:(NSArray*)sections atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated;

- (void)willInsertControllers:(NSArray*)controllers atIndexPaths:(NSArray*)indexPaths animated:(BOOL)animated;
- (void)didInsertControllers:(NSArray*)controllers atIndexPaths:(NSArray*)indexPaths animated:(BOOL)animated;

- (void)willRemoveControllers:(NSArray*)controllers atIndexPaths:(NSArray*)indexPaths animated:(BOOL)animated;
- (void)didRemoveControllers:(NSArray*)controllers atIndexPaths:(NSArray*)indexPaths animated:(BOOL)animated;

- (void)performBatchUpdates:(void (^)(void))updates completion:(void (^)(BOOL finished))completion;

- (UIView*)viewForControllerAtIndexPath:(NSIndexPath*)indexPath reusingView:(UIView*)view;

@end




/**
 */
@interface CKSectionedViewController : CKViewController<CKSectionDelegate,CKSectionedViewControllerProtocol>

- (id)initWithSections:(NSArray*)sections;
- (instancetype)controllerWithSections:(NSArray*)sections;

- (void)postInit;

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

- (CKCollectionCellContentViewController*)controllerAtIndexPath:(NSIndexPath*)indexPath;
- (NSArray*)controllersAtIndexPaths:(NSArray*)indexPaths;

@end
