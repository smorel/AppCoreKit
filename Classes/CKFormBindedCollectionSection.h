//
//  CKFormBindedCollectionSection.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-11-28.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import "CKFormSectionBase.h"
#import "CKTableViewCellController.h"

/** TODO
 */
@interface CKFormBindedCollectionSection : CKFormSectionBase<CKObjectControllerDelegate>{
	BOOL _sectionUpdate;
}

@property (nonatomic,retain,readonly) NSMutableArray* headerCellControllers;
@property (nonatomic,retain,readonly) NSMutableArray* footerCellControllers;
@property (nonatomic,retain,readonly) CKCollectionController* objectController;

//Initialization and constructors
- (id)initWithCollection:(CKCollection*)collection factory:(CKItemViewControllerFactory*)factory;

+ (CKFormBindedCollectionSection*)sectionWithCollection:(CKCollection*)collection factory:(CKItemViewControllerFactory*)factory;
+ (CKFormBindedCollectionSection*)sectionWithCollection:(CKCollection*)collection factory:(CKItemViewControllerFactory*)factory headerTitle:(NSString*)title;
+ (CKFormBindedCollectionSection*)sectionWithCollection:(CKCollection*)collection factory:(CKItemViewControllerFactory*)factory appendCollectionCellControllerAsFooterCell:(BOOL)appendCollectionCellControllerAsFooterCell;
+ (CKFormBindedCollectionSection*)sectionWithCollection:(CKCollection*)collection factory:(CKItemViewControllerFactory*)factory headerTitle:(NSString*)title appendCollectionCellControllerAsFooterCell:(BOOL)appendCollectionCellControllerAsFooterCell;

//Cell Controller API
- (void)addFooterCellController:(CKTableViewCellController*)controller;
- (void)removeFooterCellController:(CKTableViewCellController*)controller;

- (void)addHeaderCellController:(CKTableViewCellController*)controller;
- (void)removeHeaderCellController:(CKTableViewCellController*)controller;

@end