//
//  CKFormSectionBase_private.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-11-28.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

@interface CKFormSectionBase()
@property (nonatomic,readwrite) BOOL hidden;
@property (nonatomic,assign) CKFormTableViewController* parentController;

- (NSInteger)numberOfObjects;
- (id)objectAtIndex:(NSInteger)index;
- (void)removeObjectAtIndex:(NSInteger)index;
- (void)fetchRange:(NSRange)range;

- (void)updateStyleForNonNewVisibleCells;
- (void)updateStyleForExistingCells;

- (void)start;
- (void)stop;

- (void)lock;
- (void)unlock;

- (CKItemViewControllerFactoryItem*)factoryItemForIndex:(NSInteger)index;

@end