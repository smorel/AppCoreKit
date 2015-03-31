//
//  CKAbstractSection.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-17.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKReusableViewController.h"
#import "NSObject+Bindings.h"

@class CKAbstractSection;
@class CKSectionedViewController;
@protocol CKSectionContainerDelegate;


/**
 */
@protocol CKSectionDelegate

@required

- (void)section:(CKAbstractSection*)section willInsertControllers:(NSArray*)controllers atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated;
- (void)section:(CKAbstractSection*)section didInsertControllers:(NSArray*)controllers atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated sectionUpdate:(void(^)())sectionUpdate;

- (void)section:(CKAbstractSection*)section willRemoveControllers:(NSArray*)controllers atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated;
- (void)section:(CKAbstractSection*)section didRemoveControllers:(NSArray*)controllers atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated sectionUpdate:(void(^)())sectionUpdate;

- (NSInteger)indexOfSection:(CKAbstractSection*)section;

@end



/**
 */
@interface CKAbstractSection : NSObject

@property(nonatomic,retain) NSString* name;
@property(nonatomic,assign) id<CKSectionDelegate> delegate;
@property(nonatomic,assign) UIViewController* containerViewController;

@property(nonatomic,retain) CKReusableViewController* headerViewController;
@property(nonatomic,retain) CKReusableViewController* footerViewController;


/** This will set headerViewController with a CKSectionHeaderFooterViewController initialized with the specified text
 */
- (void)setHeaderTitle:(NSString*)headerTitle;

/** This will set footerViewController with a CKSectionHeaderFooterViewController initialized with the specified text
 */
- (void)setFooterTitle:(NSString*)footerTitle;


@property (nonatomic,assign) BOOL hidden;
- (void)setHidden:(BOOL)hidden animated:(BOOL)animated;

@property (nonatomic,assign) BOOL collapsed;
- (void)setCollapsed:(BOOL)collapsed animated:(BOOL)animated;

@property(nonatomic,readonly) NSArray* controllers;

- (NSInteger)indexOfController:(CKReusableViewController*)controller;
- (NSIndexSet*)indexesOfControllers:(NSArray*)controllers;

- (CKReusableViewController*)controllerAtIndex:(NSInteger)index;
- (NSArray*)controllersAtIndexes:(NSIndexSet*)indexes;

- (void)sectionContainerDelegate:(UIViewController<CKSectionContainerDelegate>*)sectionContainerDelegate willRemoveControllerAtIndex:(NSInteger)index;

- (void)sectionContainerDelegate:(UIViewController<CKSectionContainerDelegate>*)sectionContainerDelegate didMoveControllerAtIndex:(NSInteger)from toIndex:(NSInteger)to;

@property(nonatomic,readonly) NSInteger sectionIndex;

- (void)fetchNextPageFromIndex:(NSInteger)index;

@end
