//
//  CKTableViewController.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-18.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKSectionContainer.h"
#import "CKPassThroughView.h"

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
@interface UITableView(AppCoreKit)

/**
 */
@property(nonatomic,readonly) BOOL isPreventingUpdates;

/**
 */
- (void)beginPreventingUpdates;

/**
 */
- (void)endPreventingUpdates;

@end




/**
 */
@interface CKTableViewController : UITableViewController<CKSectionContainerDelegate>

/** By default, a CKPassThroughView transparent view that does catches touches. You can set your own backgroundview in viewDidLoad
 */
@property(nonatomic,retain) UIView* backgroundView;

/** By default, a CKPassThroughView transparent view that does catches touches. You can add views that must be displayed on top of the tableView here
 */
@property(nonatomic,retain) UIView* foregroundView;

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

///-----------------------------------
/// @name Getting the Controller status
///-----------------------------------
/**
 Returns the current page computed using tableView height or width depending on the orientation
 */
@property (nonatomic, assign, readonly) NSInteger currentPage;
/**
 Returns the number of pages computed using tableView height or width depending on the orientation
 */
@property (nonatomic, assign, readonly) NSInteger numberOfPages;

///-----------------------------------
/// @name Scrolling
///-----------------------------------
/**
 Returns the scrolling state of the table. Somebody can bind himself on this property to act depending on the scrolling state for example.
 */
@property (nonatomic, assign, readonly) BOOL scrolling;

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
