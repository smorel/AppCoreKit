//
//  CKFormTableViewController.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-06.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKFormTableViewController.h"
#import "CKObjectController.h"
#import "CKObjectViewControllerFactory.h";


@interface CKFormObjectController : NSObject<CKObjectController>{
	id _delegate;
}
@property (nonatomic, assign) id delegate;
@end

@implementation CKFormObjectController
@synthesize delegate = _delegate;

- (NSInteger)numberOfSections{
	CKFormTableViewController* formController = (CKFormTableViewController*)self.delegate;
	return [formController.sections count];
}

- (NSInteger)numberOfObjectsForSection:(NSInteger)section{
	CKFormTableViewController* formController = (CKFormTableViewController*)self.delegate;
	CKFormSection* formSection = [formController.sections objectAtIndex:section];
	return [formSection.cellDescriptors count];
}

- (NSString*)headerTitleForSection:(NSInteger)section{
	CKFormTableViewController* formController = (CKFormTableViewController*)self.delegate;
	CKFormSection* formSection = [formController.sections objectAtIndex:section];
	return formSection.headerTitle;
}

- (UIView*)headerViewForSection:(NSInteger)section{
	CKFormTableViewController* formController = (CKFormTableViewController*)self.delegate;
	CKFormSection* formSection = [formController.sections objectAtIndex:section];
	return formSection.headerView;
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath{
	CKFormTableViewController* formController = (CKFormTableViewController*)self.delegate;
	CKFormSection* formSection = [formController.sections objectAtIndex:indexPath.section];
	CKFormCellDescriptor* cellDescriptor = [formSection.cellDescriptors objectAtIndex:indexPath.row];
	return cellDescriptor.value;
}

- (void)setDelegate:(id)theDelegate{
	_delegate = theDelegate;
}

@end


@interface CKFormObjectControllerFactory : CKObjectViewControllerFactory{
}
@end

@implementation CKFormObjectControllerFactory

- (Class)controllerClassForIndexPath:(NSIndexPath*)indexPath{
	CKFormObjectController* formObjectController = (CKFormObjectController*)self.objectController;
	CKFormTableViewController* formController = (CKFormTableViewController*)formObjectController.delegate;
	CKFormSection* formSection = [formController.sections objectAtIndex:indexPath.section];
	CKFormCellDescriptor* cellDescriptor = [formSection.cellDescriptors objectAtIndex:indexPath.row];
	return cellDescriptor.controllerClass;
}

- (id)styleForIndexPath:(NSIndexPath*)indexPath{
	CKFormObjectController* formObjectController = (CKFormObjectController*)self.objectController;
	CKFormTableViewController* formController = (CKFormTableViewController*)formObjectController.delegate;
	CKFormSection* formSection = [formController.sections objectAtIndex:indexPath.section];
	CKFormCellDescriptor* cellDescriptor = [formSection.cellDescriptors objectAtIndex:indexPath.row];
	return cellDescriptor.controllerStyle;
}

- (void)initializeController:(id)controller atIndexPath:(NSIndexPath*)indexPath{
	CKFormObjectController* formObjectController = (CKFormObjectController*)self.objectController;
	CKFormTableViewController* formController = (CKFormTableViewController*)formObjectController.delegate;
	CKFormSection* formSection = [formController.sections objectAtIndex:indexPath.section];
	CKFormCellDescriptor* cellDescriptor = [formSection.cellDescriptors objectAtIndex:indexPath.row];
	if(cellDescriptor.block){
		cellDescriptor.block(controller);
	}
	else if(cellDescriptor.target){
		[cellDescriptor.target performSelector:cellDescriptor.action withObject:controller];
	}
}

@end







@implementation CKFormSection
@synthesize headerTitle = _headerTitle;
@synthesize headerView = _headerView;
@synthesize cellDescriptors = _cellDescriptors;

- (id)initWithCellDescriptors:(NSArray*)theCellDescriptors headerTitle:(NSString*)title{
	[super init];
	self.headerTitle = title;
	self.cellDescriptors = [NSMutableArray arrayWithArray:theCellDescriptors];
	return self;
}

- (id)initWithCellDescriptors:(NSArray*)theCellDescriptors headerView:(UIView*)view{
	[super init];
	self.headerView = view;
	self.cellDescriptors = [NSMutableArray arrayWithArray:theCellDescriptors];
	return self;
}

- (id)initWithCellDescriptors:(NSArray*)theCellDescriptors{
	[super init];
	self.headerTitle = @"";
	self.cellDescriptors = [NSMutableArray arrayWithArray:theCellDescriptors];
	return self;
}

+ (CKFormSection*)section{
	return [[[CKFormSection alloc]initWithCellDescriptors:nil headerTitle:@""]autorelease];
}

+ (CKFormSection*)sectionWithHeaderTitle:(NSString*)title{
	return [[[CKFormSection alloc]initWithCellDescriptors:nil headerTitle:title]autorelease];
}

+ (CKFormSection*)sectionWithHeaderView:(UIView*)view{
	return [[[CKFormSection alloc]initWithCellDescriptors:nil headerView:view]autorelease];
}

+ (CKFormSection*)sectionWithCellDescriptors:(NSArray*)cellDescriptors{
	return [[[CKFormSection alloc]initWithCellDescriptors:cellDescriptors headerTitle:@""]autorelease];
}

+ (CKFormSection*)sectionWithCellDescriptors:(NSArray*)cellDescriptors headerTitle:(NSString*)title{
	return [[[CKFormSection alloc]initWithCellDescriptors:cellDescriptors headerTitle:title]autorelease];
}

+ (CKFormSection*)sectionWithCellDescriptors:(NSArray*)cellDescriptors headerView:(UIView*)view{
	return [[[CKFormSection alloc]initWithCellDescriptors:cellDescriptors headerView:view]autorelease];
}

- (void)insertCellDescriptor:(CKFormCellDescriptor *)cellDescriptor atIndex:(NSUInteger)index{
	if(_cellDescriptors == nil){
		self.cellDescriptors = [NSMutableArray array];
	}
	[_cellDescriptors insertObject:cellDescriptor atIndex:index];
}

- (void)addCellDescriptor:(CKFormCellDescriptor *)cellDescriptor{
	if(_cellDescriptors == nil){
		self.cellDescriptors = [NSMutableArray array];
	}
	[_cellDescriptors addObject:cellDescriptor];
}

- (void)removeCellDescriptorAtIndex:(NSUInteger)index{
	[_cellDescriptors removeObjectAtIndex:index];
}
@end

@implementation CKFormCellDescriptor
@synthesize value = _value;
@synthesize controllerClass = _controllerClass;
@synthesize controllerStyle = _controllerStyle;
@synthesize block = _initializeBlock;
@synthesize target = _initializeTarget;
@synthesize action = _initializeAction;

- (id)initWithValue:(id)theValue controllerClass:(Class)theControllerClass controllerStyle:(id)theControllerStyle withBlock:(CKFormCellInitializeBlock)initializeBlock{
	[super init];
	self.value = theValue;
	self.controllerClass = theControllerClass;
	self.controllerStyle = theControllerStyle;
	self.block = initializeBlock;
	return self;
}

- (id)initWithValue:(id)theValue controllerClass:(Class)theControllerClass controllerStyle:(id)theControllerStyle target:(id)theTarget action:(SEL)theAction{
	[super init];
	self.value = theValue;
	self.controllerClass = theControllerClass;
	self.controllerStyle = theControllerStyle;
	self.target = theTarget;
	self.action = theAction;
	return self;
}


+ (CKFormCellDescriptor*)cellDescriptorWithValue:(id)value controllerClass:(Class)controllerClass controllerStyle:(id)controllerStyle withBlock:(CKFormCellInitializeBlock)initializeBlock{
	return [[[CKFormCellDescriptor alloc]initWithValue:value controllerClass:controllerClass controllerStyle:controllerStyle withBlock:initializeBlock]autorelease];
}

+ (CKFormCellDescriptor*)cellDescriptorWithValue:(id)value controllerClass:(Class)controllerClass controllerStyle:(id)controllerStyle target:(id)target action:(SEL)action{
	return [[[CKFormCellDescriptor alloc]initWithValue:value controllerClass:controllerClass controllerStyle:controllerStyle target:target action:action]autorelease];
}

@end

@implementation CKFormTableViewController
@synthesize sections = _sections;

- (void)postInit{
	self.objectController = [[[CKFormObjectController alloc]init]autorelease];
	self.controllerFactory = [[[CKFormObjectControllerFactory alloc]init]autorelease];
}

- (void)dealloc{
	[_sections release];
	_sections = nil;
	[super dealloc];
}

- (id)initWithSections:(NSArray*)theSections{
	[super init];
	self.sections = [NSMutableArray arrayWithArray:theSections];
	return self;
}

- (void)addSection:(CKFormSection *)section{
	if(_sections == nil){
		self.sections = [NSMutableArray array];
	}
	[_sections addObject:section];
}

- (CKFormSection *)addSectionWithCellDescriptors:(NSArray *)cellDescriptors{
	CKFormSection* section = [CKFormSection sectionWithCellDescriptors:cellDescriptors];
	if(_sections == nil){
		self.sections = [NSMutableArray array];
	}
	[_sections addObject:section];
	return section;
}

- (CKFormSection *)addSectionWithCellDescriptors:(NSArray *)cellDescriptors headerTitle:(NSString *)headerTitle{
	CKFormSection* section = [CKFormSection sectionWithCellDescriptors:cellDescriptors headerTitle:headerTitle];
	if(_sections == nil){
		self.sections = [NSMutableArray array];
	}
	[_sections addObject:section];
	return section;
}

- (void)insertCellDescriptor:(CKFormCellDescriptor*)cellDescriptor atIndex:(NSUInteger)index inSection:(NSUInteger)sectionIndex animated:(BOOL)animated{
	if(_sections == nil){
		self.sections = [NSMutableArray array];
	}
	
	while([_sections count] < sectionIndex){
		CKFormSection* section = [CKFormSection section];
		[_sections addObject:section];
	}
	
	CKFormSection* section = [_sections objectAtIndex:sectionIndex];
	[section insertCellDescriptor:cellDescriptor atIndex:index];
	[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:sectionIndex]] withRowAnimation:animated ? _rowInsertAnimation : UITableViewRowAnimationNone];
}

- (void)removeCellDescriptorAtIndex:(NSUInteger)index inSection:(NSUInteger)sectionIndex animated:(BOOL)animated{
	CKFormSection* section = [_sections objectAtIndex:sectionIndex];
	[section removeCellDescriptorAtIndex:index];
	[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:sectionIndex]] withRowAnimation:animated ? _rowRemoveAnimation : UITableViewRowAnimationNone];
}

- (CKFormSection*)sectionAtIndex:(NSUInteger)index{
	CKFormSection* section = [_sections objectAtIndex:index];
	return section;
}

@end
