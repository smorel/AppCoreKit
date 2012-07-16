//
//  CKFormSectionBase_private.h
//  CloudKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

@interface CKFormSectionBase()
@property (nonatomic,readwrite) BOOL hidden;
@property (nonatomic,readwrite) BOOL collapsed;
@property (nonatomic,assign,readwrite) CKFormTableViewController* parentController;

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