//
//  CKSection.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-17.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKAbstractSection.h"


/**
 */
@interface CKSection : CKAbstractSection

- (id)initWithControllers:(NSArray*)controllers;
+ (CKSection*)sectionWithControllers:(NSArray*)controllers;

- (void)addController:(CKResusableViewController*)controller animated:(BOOL)animated;
- (void)insertController:(CKResusableViewController*)controller atIndex:(NSInteger)index animated:(BOOL)animated;
- (void)addControllers:(NSArray*)controllers animated:(BOOL)animated;
- (void)insertControllers:(NSArray*)controllers atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated;

- (void)removeAllControllersAnimated:(BOOL)animated;
- (void)removeController:(CKResusableViewController*)controller animated:(BOOL)animated;
- (void)removeControllerAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)removeControllers:(NSArray*)controllers animated:(BOOL)animated;
- (void)removeControllersAtIndexes:(NSIndexSet*)indexes animated:(BOOL)animated;

@end

