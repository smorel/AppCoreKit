//
//  CKFormSectionBase.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-11-28.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKModelObject.h"
#import "CKObjectTableViewController.h"
#import "CKTableViewCellController.h"
#import "CKObjectController.h"
#import "CKDocumentController.h"


@class CKFormTableViewController;

/** TODO
 */
@interface CKFormSectionBase : CKModelObject
{
	NSString* _headerTitle;
	UIView* _headerView;
	NSString* _footerTitle;
	UIView* _footerView;
	CKFormTableViewController* _parentController;
	BOOL _hidden;
}

@property (nonatomic,retain) NSString* headerTitle;
@property (nonatomic,retain) UIView* headerView;
@property (nonatomic,retain) NSString* footerTitle;
@property (nonatomic,retain) UIView* footerView;
@property (nonatomic,assign) CKFormTableViewController* parentController;
@property (nonatomic,readonly) NSInteger sectionIndex;
@property (nonatomic,readonly) NSInteger sectionVisibleIndex;
@property (nonatomic,readonly) BOOL hidden;

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