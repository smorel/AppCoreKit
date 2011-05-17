//
//  CKFormTableViewController.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-06.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKObjectTableViewController.h"
#import "CKTableViewCellController.h"
#import "CKModelObject.h"
#import "CKObjectController.h"
#import "CKDocumentController.h"

@class CKFormTableViewController;
@interface CKFormSectionBase : CKModelObject
{
	NSString* _headerTitle;
	UIView* _headerView;
	CKFormTableViewController* _parentController;
}

@property (nonatomic,retain) NSString* headerTitle;
@property (nonatomic,retain) UIView* headerView;
@property (nonatomic,assign) CKFormTableViewController* parentController;
@property (nonatomic,readonly) NSInteger sectionIndex;

- (NSInteger)numberOfObjects;
- (id)objectAtIndex:(NSInteger)index;
- (void)removeObjectAtIndex:(NSInteger)index;
- (void)fetchRange:(NSRange)range;

- (void)updateStyleForNonNewVisibleCells;
- (void)updateStyleForExistingCells;

- (void)start;
- (void)stop;

- (CKObjectViewControllerFactoryItem*)factoryItemForIndex:(NSInteger)index;
@end


@class CKFormCellDescriptor;
@interface CKFormSection : CKFormSectionBase{
	
	NSMutableArray* _cellDescriptors;
}

@property (nonatomic,retain) NSArray* cellDescriptors;

- (id)initWithCellDescriptors:(NSArray*)cellDescriptors headerTitle:(NSString*)title;
- (id)initWithCellDescriptors:(NSArray*)cellDescriptors headerView:(UIView*)view;
- (id)initWithCellDescriptors:(NSArray*)cellDescriptors;

+ (CKFormSection*)section;
+ (CKFormSection*)sectionWithHeaderTitle:(NSString*)title;
+ (CKFormSection*)sectionWithHeaderView:(UIView*)view;
+ (CKFormSection*)sectionWithCellDescriptors:(NSArray*)cellDescriptors;
+ (CKFormSection*)sectionWithCellDescriptors:(NSArray*)cellDescriptors headerTitle:(NSString*)title;
+ (CKFormSection*)sectionWithCellDescriptors:(NSArray*)cellDescriptors headerView:(UIView*)view;

- (void)insertCellDescriptor:(CKFormCellDescriptor *)cellDescriptor atIndex:(NSUInteger)index;
- (void)addCellDescriptor:(CKFormCellDescriptor *)cellDescriptor;
- (void)removeCellDescriptorAtIndex:(NSUInteger)index;

@end

@interface CKFormDocumentCollectionSection : CKFormSectionBase<CKObjectControllerDelegate>{
	CKDocumentController* _objectController;
	CKObjectViewControllerFactory* _controllerFactory;
	
	NSMutableArray* _headerCellDescriptors;
	NSMutableArray* _footerCellDescriptors;
	NSMutableArray* _changeSet;
}

@property (nonatomic,retain,readonly) CKDocumentController* objectController;
@property (nonatomic,retain) NSArray* headerCellDescriptors;
@property (nonatomic,retain) NSArray* footerCellDescriptors;

- (id)initWithCollection:(CKDocumentCollection*)collection mappings:(NSArray*)mappings;
+ (CKFormDocumentCollectionSection*)sectionWithCollection:(CKDocumentCollection*)collection mappings:(NSArray*)mappings;
+ (CKFormDocumentCollectionSection*)sectionWithCollection:(CKDocumentCollection*)collection mappings:(NSArray*)mappings headerTitle:(NSString*)title;

@end

typedef void(^CKFormCellInitializeBlock)(CKTableViewCellController* controller);
@interface CKFormCellDescriptor : CKObjectViewControllerFactoryItem{
	id _value;
}

@property (nonatomic,retain) id value;

- (id)initWithValue:(id)value controllerClass:(Class)controllerClass withBlock:(CKFormCellInitializeBlock)initializeBlock;
- (id)initWithValue:(id)value controllerClass:(Class)controllerClass target:(id)target action:(SEL)action;
- (id)initWithValue:(id)value controllerClass:(Class)controllerClass;

+ (CKFormCellDescriptor*)cellDescriptorWithValue:(id)value controllerClass:(Class)controllerClass withBlock:(CKFormCellInitializeBlock)initializeBlock;
+ (CKFormCellDescriptor*)cellDescriptorWithValue:(id)value controllerClass:(Class)controllerClass target:(id)target action:(SEL)action;
+ (CKFormCellDescriptor*)cellDescriptorWithValue:(id)value controllerClass:(Class)controllerClass;

@end

@interface CKFormTableViewController : CKObjectTableViewController {
	NSMutableArray* _sections;
}
@property (nonatomic,retain) NSArray* sections;

- (id)initWithSections:(NSArray*)sections;

- (void)addSection:(CKFormSectionBase *)section;
- (CKFormSection *)addSectionWithCellDescriptors:(NSArray *)cellDescriptors;
- (CKFormSection *)addSectionWithCellDescriptors:(NSArray *)cellDescriptors headerTitle:(NSString *)headerTitle;
- (CKFormDocumentCollectionSection *)addSectionWithCollection:(CKDocumentCollection*)collection mappings:(NSArray*)mappings;
- (CKFormSectionBase *)sectionAtIndex:(NSUInteger)index;
- (NSInteger)indexOfSection:(CKFormSectionBase *)section;

@end
