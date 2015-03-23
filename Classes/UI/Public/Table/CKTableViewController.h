//
//  CKTableViewController.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-18.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKSectionContainer.h"

//commented until the layout loop is solved
//#define USING_UITableViewHeaderFooterView

@class CKTableViewCell;
@class CKTableView;

/**
 */
@interface CKReusableViewController(CKTableViewController)

/**
 */
@property(nonatomic,readonly) CKTableViewCell* tableViewCell;

#ifdef USING_UITableViewHeaderFooterView
/**
 */
@property(nonatomic,readonly) UITableViewHeaderFooterView* headerFooterView;
#endif

@end




/**
 */
@interface CKTableViewController : UITableViewController<CKSectionContainerDelegate>

/** default id grouped
 */
@property(nonatomic,assign) UITableViewStyle style;

/**
 */
@property(nonatomic,retain) CKReusableViewController* tableHeaderViewController;

/**
 */
@property(nonatomic,retain) CKReusableViewController* tableFooterViewController;

/** Default is YES
 */
@property(nonatomic,assign) BOOL endEditingViewWhenScrolling;

/** Default is YES
 */
@property(nonatomic,assign) BOOL adjustInsetsOnKeyboardNotification;

/**
 */
- (Class)tableViewClass;

/**
 */
- (void)scrollToControllerAtIndexPath:(NSIndexPath*)indexpath animated:(BOOL)animated;


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


@property(nonatomic,retain) NSArray* selectedIndexPaths;

@end
