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

@class CKFormCellDescriptor;
@interface CKFormSection : CKModelObject{
	NSString* _headerTitle;
	UIView* _headerView;
	NSMutableArray* _cellDescriptors;
}

@property (nonatomic,retain) NSString* headerTitle;
@property (nonatomic,retain) UIView* headerView;
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

typedef void(^CKFormCellInitializeBlock)(CKTableViewCellController* controller);
@interface CKFormCellDescriptor : CKModelObject{
	id _value;
	Class _controllerClass;
	id _controllerStyle;
	
	//OS4
	CKFormCellInitializeBlock _initializeBlock;
	//OS3
	id _initializeTarget;
	SEL _initializeAction;
}

@property (nonatomic,retain) id value;
@property (nonatomic,assign) Class controllerClass;
@property (nonatomic,retain) id controllerStyle;
@property (nonatomic,copy) CKFormCellInitializeBlock block;
@property (nonatomic,assign) id target;
@property (nonatomic,assign) SEL action;

- (id)initWithValue:(id)value controllerClass:(Class)controllerClass controllerStyle:(id)controllerStyle withBlock:(CKFormCellInitializeBlock)initializeBlock;
- (id)initWithValue:(id)value controllerClass:(Class)controllerClass controllerStyle:(id)controllerStyle target:(id)target action:(SEL)action;
- (id)initWithValue:(id)value controllerClass:(Class)controllerClass controllerStyle:(id)controllerStyle;
- (id)initWithValue:(id)value controllerClass:(Class)controllerClass;

+ (CKFormCellDescriptor*)cellDescriptorWithValue:(id)value controllerClass:(Class)controllerClass controllerStyle:(id)controllerStyle withBlock:(CKFormCellInitializeBlock)initializeBlock;
+ (CKFormCellDescriptor*)cellDescriptorWithValue:(id)value controllerClass:(Class)controllerClass controllerStyle:(id)controllerStyle target:(id)target action:(SEL)action;
+ (CKFormCellDescriptor*)cellDescriptorWithValue:(id)value controllerClass:(Class)controllerClass controllerStyle:(id)controllerStyle;
+ (CKFormCellDescriptor*)cellDescriptorWithValue:(id)value controllerClass:(Class)controllerClass;

@end

@interface CKFormTableViewController : CKObjectTableViewController {
	NSMutableArray* _sections;
}
@property (nonatomic,retain) NSArray* sections;

- (id)initWithSections:(NSArray*)sections;

- (void)addSection:(CKFormSection *)section;
- (CKFormSection *)addSectionWithCellDescriptors:(NSArray *)cellDescriptors;
- (CKFormSection *)addSectionWithCellDescriptors:(NSArray *)cellDescriptors headerTitle:(NSString *)headerTitle;
- (void)insertCellDescriptor:(CKFormCellDescriptor*)cellDescriptor atIndex:(NSUInteger)index inSection:(NSUInteger)sectionIndex animated:(BOOL)animated;
- (void)removeCellDescriptorAtIndex:(NSUInteger)index inSection:(NSUInteger)sectionIndex animated:(BOOL)animated;
- (CKFormSection*)sectionAtIndex:(NSUInteger)index;

@end
