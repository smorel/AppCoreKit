//
//  CKCollectionSection.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-17.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKAbstractSection.h"
#import "CKViewControllerFactory.h"

/**
 */
@interface CKCollectionSection : CKAbstractSection

- (id)initWithCollection:(CKCollection*)collection factory:(CKViewControllerFactory*)factory;
+ (CKCollectionSection*)sectionWithCollection:(CKCollection*)collection factory:(CKViewControllerFactory*)factory;

- (id)initWithCollection:(CKCollection*)collection factory:(CKViewControllerFactory*)factory reorderingEnabled:(BOOL)reorderingEnabled;
+ (CKCollectionSection*)sectionWithCollection:(CKCollection*)collection factory:(CKViewControllerFactory*)factory reorderingEnabled:(BOOL)reorderingEnabled;


@property(nonatomic,readonly) NSArray* collectionControllers;
@property(nonatomic,readonly) CKCollection* collection;
@property(nonatomic,readonly) CKViewControllerFactory* factory;

/** Default value is NO.
 */
@property(nonatomic,assign) BOOL reorderingEnabled;

- (NSRange)rangeForCollectionControllers;

@property(nonatomic,readonly) NSArray* collectionHeaderControllers;
- (void)addCollectionHeaderController:(CKCollectionCellContentViewController*)controller animated:(BOOL)animated;
- (void)insertCollectionHeaderController:(CKCollectionCellContentViewController*)controller atIndex:(NSInteger)index animated:(BOOL)animated;
- (void)addCollectionHeaderControllers:(NSArray*)controller animated:(BOOL)animated;
- (void)insertCollectionHeaderControllers:(NSArray*)controllers atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated;

- (void)removeAllCollectionHeaderControllersAnimated:(BOOL)animated;
- (void)removeCollectionHeaderController:(CKCollectionCellContentViewController*)controller animated:(BOOL)animated;
- (void)removeCollectionHeaderControllerAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)removeCollectionHeaderControllers:(NSArray*)controllers animated:(BOOL)animated;
- (void)removeCollectionHeaderControllersAtIndexes:(NSIndexSet*)indexes animated:(BOOL)animated;


@property(nonatomic,readonly) NSArray* collectionFooterControllers;
- (void)addCollectionFooterController:(CKCollectionCellContentViewController*)controller animated:(BOOL)animated;
- (void)insertCollectionFooterController:(CKCollectionCellContentViewController*)controller atIndex:(NSInteger)index animated:(BOOL)animated;
- (void)addCollectionFooterControllers:(NSArray*)controller animated:(BOOL)animated;
- (void)insertCollectionFooterControllers:(NSArray*)controllers atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated;

- (void)removeAllCollectionFooterControllersAnimated:(BOOL)animated;
- (void)removeCollectionFooterController:(CKCollectionCellContentViewController*)controller animated:(BOOL)animated;
- (void)removeCollectionFooterControllerAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)removeCollectionFooterControllers:(NSArray*)controllers animated:(BOOL)animated;
- (void)removeCollectionFooterControllersAtIndexes:(NSIndexSet*)indexes animated:(BOOL)animated;

@end
