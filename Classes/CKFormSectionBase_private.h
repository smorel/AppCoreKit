//
//  CKFormSectionBase_private.h
//  AppCoreKit
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

- (void)start;
- (void)stop;

- (void)lock;
- (void)unlock;

- (id)controllerForObject:(id)object atIndex:(NSInteger)index;

@end