//
//  CKAbstractSection.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-17.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKResusableViewController.h"
#import "NSObject+Bindings.h"

@class CKAbstractSection;
@class CKSectionedViewController;

/**
 */
@protocol CKSectionDelegate

- (void)section:(CKAbstractSection*)section willInsertControllers:(NSArray*)controllers atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated;
- (void)section:(CKAbstractSection*)section didInsertControllers:(NSArray*)controllers atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated;

- (void)section:(CKAbstractSection*)section willRemoveControllers:(NSArray*)controllers atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated;
- (void)section:(CKAbstractSection*)section didRemoveControllers:(NSArray*)controllers atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated;

@end



/**
 */
@interface CKAbstractSection : NSObject

@property(nonatomic,assign) CKSectionedViewController* delegate;

@property(nonatomic,retain) CKResusableViewController* headerViewController;
@property(nonatomic,retain) CKResusableViewController* footerViewController;


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

- (NSInteger)indexOfController:(CKResusableViewController*)controller;
- (NSIndexSet*)indexesOfControllers:(NSArray*)controllers;

- (CKResusableViewController*)controllerAtIndex:(NSInteger)index;
- (NSArray*)controllersAtIndexes:(NSIndexSet*)indexes;

- (void)sectionedViewController:(CKSectionedViewController*)sectionViewController willRemoveControllerAtIndex:(NSInteger)index;

- (void)sectionedViewController:(CKSectionedViewController*)sectionViewController didMoveControllerAtIndex:(NSInteger)from toIndex:(NSInteger)to;

@property(nonatomic,readonly) NSInteger sectionIndex;

- (void)fetchNextPage;

@end
