//
//  CKFormSection.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-11-28.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import "CKFormSectionBase.h"
#import "CKTableViewCellController.h"

/** TODO
 */
@interface CKFormSection : CKFormSectionBase{
	NSMutableArray* _cellControllers;
}

- (NSInteger)count;

- (id)initWithCellControllers:(NSArray*)cellcontrollers headerTitle:(NSString*)title;
- (id)initWithCellControllers:(NSArray*)cellcontrollers headerView:(UIView*)view;
- (id)initWithCellControllers:(NSArray*)cellcontrollers footerTitle:(NSString*)title;
- (id)initWithCellControllers:(NSArray*)cellcontrollers footerView:(UIView*)view;
- (id)initWithCellControllers:(NSArray*)cellcontrollers;

+ (CKFormSection*)sectionWithCellControllers:(NSArray*)cellcontrollers;
+ (CKFormSection*)sectionWithCellControllers:(NSArray*)cellcontrollers headerTitle:(NSString*)title;
+ (CKFormSection*)sectionWithCellControllers:(NSArray*)cellcontrollers headerView:(UIView*)view;
+ (CKFormSection*)sectionWithCellControllers:(NSArray*)cellcontrollers footerTitle:(NSString*)title;
+ (CKFormSection*)sectionWithCellControllers:(NSArray*)cellcontrollers footerView:(UIView*)view;

- (void)insertCellController:(CKTableViewCellController *)controller atIndex:(NSUInteger)index;
- (void)addCellController:(CKTableViewCellController *)controller;
- (void)removeCellController:(CKTableViewCellController *)controller;
- (void)removeCellControllerAtIndex:(NSUInteger)index;


+ (CKFormSection*)section;
+ (CKFormSection*)sectionWithHeaderTitle:(NSString*)title;
+ (CKFormSection*)sectionWithHeaderView:(UIView*)view;
+ (CKFormSection*)sectionWithFooterTitle:(NSString*)title;
+ (CKFormSection*)sectionWithFooterView:(UIView*)view;


@end

#import "CKFormSection+PropertyGrid.h"