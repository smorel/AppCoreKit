//
//  CKFormBindedCollectionSection.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-11-28.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import "CKFormSectionBase.h"
#import "CKCollection.h"
#import "CKCollectionCellControllerFactory.h"
#import "CKCollectionController.h"

@class CKTableViewCellController;

/** TODO
 */
@interface CKFormBindedCollectionSection : CKFormSectionBase<CKObjectControllerDelegate>

@property (nonatomic,retain,readonly) NSMutableArray* headerCellControllers;
@property (nonatomic,retain,readonly) NSMutableArray* footerCellControllers;

//Initialization and constructors
- (id)initWithCollection:(CKCollection*)collection factory:(CKCollectionCellControllerFactory*)factory;

+ (CKFormBindedCollectionSection*)sectionWithCollection:(CKCollection*)collection factory:(CKCollectionCellControllerFactory*)factory;
+ (CKFormBindedCollectionSection*)sectionWithCollection:(CKCollection*)collection factory:(CKCollectionCellControllerFactory*)factory headerTitle:(NSString*)title;
+ (CKFormBindedCollectionSection*)sectionWithCollection:(CKCollection*)collection factory:(CKCollectionCellControllerFactory*)factory appendSpinnerAsFooterCell:(BOOL)appendSpinnerAsFooterCell;
+ (CKFormBindedCollectionSection*)sectionWithCollection:(CKCollection*)collection factory:(CKCollectionCellControllerFactory*)factory headerTitle:(NSString*)title appendSpinnerAsFooterCell:(BOOL)appendSpinnerAsFooterCell;

//Cell Controller API
- (void)addFooterCellController:(CKTableViewCellController*)controller;
- (void)removeFooterCellController:(CKTableViewCellController*)controller;

- (void)addHeaderCellController:(CKTableViewCellController*)controller;
- (void)removeHeaderCellController:(CKTableViewCellController*)controller;

@end