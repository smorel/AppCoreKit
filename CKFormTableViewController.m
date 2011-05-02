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
#import "CKNSObject+Invocation.h"
#import "CKStyleManager.h"


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
	CKFormSectionBase* formSection = (CKFormSectionBase*)[formController.sections objectAtIndex:section];
	return [formSection numberOfObjects];
}

- (NSString*)headerTitleForSection:(NSInteger)section{
	CKFormTableViewController* formController = (CKFormTableViewController*)self.delegate;
	CKFormSectionBase* formSection =  (CKFormSectionBase*)[formController.sections objectAtIndex:section];
	return formSection.headerTitle;
}

- (UIView*)headerViewForSection:(NSInteger)section{
	CKFormTableViewController* formController = (CKFormTableViewController*)self.delegate;
	CKFormSectionBase* formSection =  (CKFormSectionBase*)[formController.sections objectAtIndex:section];
	if( formSection.headerView != nil ){
		NSMutableDictionary* controllerStyle = [[CKStyleManager defaultManager] styleForObject:self  propertyName:@""];
		[formSection.headerView applyStyle:controllerStyle];
	}
	return formSection.headerView;
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath{
	CKFormTableViewController* formController = (CKFormTableViewController*)self.delegate;
	CKFormSectionBase* formSection =  (CKFormSectionBase*)[formController.sections objectAtIndex:indexPath.section];
	return [formSection objectAtIndex:indexPath.row];
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
	CKFormSectionBase* formSection = (CKFormSectionBase*)[formController.sections objectAtIndex:indexPath.section];
	return [formSection controllerClassForIndex:indexPath.row];
}

- (void)initializeController:(id)controller atIndexPath:(NSIndexPath*)indexPath{
	CKFormObjectController* formObjectController = (CKFormObjectController*)self.objectController;
	CKFormTableViewController* formController = (CKFormTableViewController*)formObjectController.delegate;
	CKFormSectionBase* formSection = (CKFormSectionBase*)[formController.sections objectAtIndex:indexPath.section];
	[formSection initializeController:controller atIndex:indexPath.row];
}

@end


@implementation CKFormSectionBase
@synthesize headerTitle = _headerTitle;
@synthesize headerView = _headerView;
@synthesize parentController = _parentController;

- (NSInteger)sectionIndex{
	return [_parentController indexOfSection:self];
}

- (NSInteger)numberOfObjects{
	NSAssert(NO,@"Base Implementation");
	return 0;
}

- (id)objectAtIndex:(NSInteger)index{
	NSAssert(NO,@"Base Implementation");
	return nil;
}

- (Class)controllerClassForIndex:(NSInteger)index{
	NSAssert(NO,@"Base Implementation");
	return nil;
}

- (void)initializeController:(id)controller atIndex:(NSInteger)index{
	NSAssert(NO,@"Base Implementation");
}


@end


@implementation CKFormSection
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


- (NSInteger)numberOfObjects{
	return [_cellDescriptors count];
}

- (id)objectAtIndex:(NSInteger)index{
	CKFormCellDescriptor* cellDescriptor = [_cellDescriptors objectAtIndex:index];
	return cellDescriptor.value;
}

- (Class)controllerClassForIndex:(NSInteger)index{
	CKFormCellDescriptor* cellDescriptor = [_cellDescriptors objectAtIndex:index];
	return cellDescriptor.controllerClass;
}

- (void)initializeController:(id)controller atIndex:(NSInteger)index{
	CKFormCellDescriptor* cellDescriptor = [_cellDescriptors objectAtIndex:index];
	if(cellDescriptor.block){
		cellDescriptor.block(controller);
	}
	else if(cellDescriptor.target){
		[cellDescriptor.target performSelector:cellDescriptor.action withObject:controller];
	}
}

@end

@interface CKFormDocumentCollectionSection()
@property (nonatomic,retain) CKDocumentController* objectController;
@property (nonatomic,retain) CKObjectViewControllerFactory* controllerFactory;
@end

@implementation CKFormDocumentCollectionSection
@synthesize objectController = _objectController;
@synthesize controllerFactory = _controllerFactory;
@synthesize headerCellDescriptors = _headerCellDescriptors;


- (id)initWithCollection:(CKDocumentCollection*)collection mappings:(NSDictionary*)mappings{
	[super init];
	self.objectController = [CKDocumentController controllerWithCollection:collection];
	if([_objectController respondsToSelector:@selector(setDelegate:)]){
		[_objectController performSelector:@selector(setDelegate:) withObject:self];
	}

	self.controllerFactory = [CKObjectViewControllerFactory factoryWithMappings:mappings];
	if([_controllerFactory respondsToSelector:@selector(setObjectController:)]){
		[_controllerFactory performSelector:@selector(setObjectController:) withObject:_objectController];
	}
	
	return self;
}

+ (CKFormDocumentCollectionSection*)sectionWithCollection:(CKDocumentCollection*)collection mappings:(NSDictionary*)mappings{
	CKFormDocumentCollectionSection* section = [[[CKFormDocumentCollectionSection alloc]initWithCollection:collection mappings:mappings]autorelease];
	return section;
}

- (NSInteger)numberOfObjects{
	NSInteger count = 0;
	count += [_headerCellDescriptors count];
	if([_objectController respondsToSelector:@selector(numberOfObjectsForSection:)]){
		count += [_objectController numberOfObjectsForSection:0];
	}
	return count;
}

- (id)objectAtIndex:(NSInteger)index{
	if(index < [_headerCellDescriptors count]){
		CKFormCellDescriptor* cellDescriptor = [_headerCellDescriptors objectAtIndex:index];
		return cellDescriptor.value;
	}
	
	if([_objectController respondsToSelector:@selector(objectAtIndexPath:)]){
		return [_objectController objectAtIndexPath:[NSIndexPath indexPathForRow:(index - [_headerCellDescriptors count]) inSection:0]];
	}
	return nil;
}

- (Class)controllerClassForIndex:(NSInteger)index{
	if(index < [_headerCellDescriptors count]){
		CKFormCellDescriptor* cellDescriptor = [_headerCellDescriptors objectAtIndex:index];
		return cellDescriptor.controllerClass;
	}
	
	return [_controllerFactory controllerClassForIndexPath:[NSIndexPath indexPathForRow:(index - [_headerCellDescriptors count]) inSection:0]];
}

- (void)initializeController:(id)controller atIndex:(NSInteger)index{
	if(index < [_headerCellDescriptors count]){
		CKFormCellDescriptor* cellDescriptor = [_headerCellDescriptors objectAtIndex:index];
		if(cellDescriptor.block){
			cellDescriptor.block(controller);
		}
		else if(cellDescriptor.target){
			[cellDescriptor.target performSelector:cellDescriptor.action withObject:controller];
		}
	}
	
	[_controllerFactory initializeController:controller atIndexPath:[NSIndexPath indexPathForRow:(index - [_headerCellDescriptors count]) inSection:0]];
}

- (void)objectControllerReloadData:(id)controller{
	[self.parentController performSelector:@selector(objectControllerReloadData:) withObject:self.objectController];
}

- (void)objectControllerDidBeginUpdating:(id)controller{
	[self.parentController performSelector:@selector(objectControllerDidBeginUpdating:) withObject:self.objectController];
}

- (void)objectControllerDidEndUpdating:(id)controller{
	[self.parentController performSelector:@selector(objectControllerDidEndUpdating:) withObject:self.objectController];
}

- (void)objectController:(id)controller insertObject:(id)object atIndexPath:(NSIndexPath*)indexPath{
	[self.parentController performSelector:@selector(objectController:insertObject:atIndexPath:) 
							   withObjects:[NSArray arrayWithObjects:self.objectController,object,[NSIndexPath indexPathForRow:(indexPath.row + [_headerCellDescriptors count]) inSection:self.sectionIndex],nil]];
}

- (void)objectController:(id)controller removeObject:(id)object atIndexPath:(NSIndexPath*)indexPath{
	[self.parentController performSelector:@selector(objectController:insertObject:atIndexPath:) 
								withObjects:[NSArray arrayWithObjects:self.objectController,object,[NSIndexPath indexPathForRow:(indexPath.row + [_headerCellDescriptors count]) inSection:self.sectionIndex],nil]];
}

@end


@implementation CKFormCellDescriptor
@synthesize value = _value;
@synthesize controllerClass = _controllerClass;
@synthesize block = _initializeBlock;
@synthesize target = _initializeTarget;
@synthesize action = _initializeAction;

- (id)initWithValue:(id)theValue controllerClass:(Class)theControllerClass withBlock:(CKFormCellInitializeBlock)initializeBlock{
	[super init];
	self.value = theValue;
	self.controllerClass = theControllerClass;
	self.block = initializeBlock;
	return self;
}

- (id)initWithValue:(id)theValue controllerClass:(Class)theControllerClass target:(id)theTarget action:(SEL)theAction{
	[super init];
	self.value = theValue;
	self.controllerClass = theControllerClass;
	self.target = theTarget;
	self.action = theAction;
	return self;
}

- (id)initWithValue:(id)theValue controllerClass:(Class)theControllerClass{
	[super init];
	self.value = theValue;
	self.controllerClass = theControllerClass;
	return self;
}

+ (CKFormCellDescriptor*)cellDescriptorWithValue:(id)value controllerClass:(Class)controllerClass withBlock:(CKFormCellInitializeBlock)initializeBlock{
	return [[[CKFormCellDescriptor alloc]initWithValue:value controllerClass:controllerClass withBlock:initializeBlock]autorelease];
}

+ (CKFormCellDescriptor*)cellDescriptorWithValue:(id)value controllerClass:(Class)controllerClass target:(id)target action:(SEL)action{
	return [[[CKFormCellDescriptor alloc]initWithValue:value controllerClass:controllerClass target:target action:action]autorelease];
}

+ (CKFormCellDescriptor*)cellDescriptorWithValue:(id)value controllerClass:(Class)controllerClass{
	return [[[CKFormCellDescriptor alloc]initWithValue:value controllerClass:controllerClass]autorelease];
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
	for(CKFormSectionBase* section in theSections){
		section.parentController = self;
	}
	return self;
}

- (void)addSection:(CKFormSectionBase *)section{
	if(_sections == nil){
		self.sections = [NSMutableArray array];
	}
	section.parentController = self;
	[_sections addObject:section];
}

- (CKFormSection *)addSectionWithCellDescriptors:(NSArray *)cellDescriptors{
	CKFormSection* section = [CKFormSection sectionWithCellDescriptors:cellDescriptors];
	if(_sections == nil){
		self.sections = [NSMutableArray array];
	}
	section.parentController = self;
	[_sections addObject:section];
	return section;
}

- (CKFormSection *)addSectionWithCellDescriptors:(NSArray *)cellDescriptors headerTitle:(NSString *)headerTitle{
	CKFormSection* section = [CKFormSection sectionWithCellDescriptors:cellDescriptors headerTitle:headerTitle];
	if(_sections == nil){
		self.sections = [NSMutableArray array];
	}
	section.parentController = self;
	[_sections addObject:section];
	return section;
}

- (CKFormDocumentCollectionSection *)addSectionWithCollection:(CKDocumentCollection*)collection mappings:(NSDictionary*)mappings{
	CKFormDocumentCollectionSection* section = [CKFormDocumentCollectionSection sectionWithCollection:collection mappings:mappings];
	if(_sections == nil){
		self.sections = [NSMutableArray array];
	}
	section.parentController = self;
	[_sections addObject:section];
	return section;
}

- (CKFormSectionBase*)sectionAtIndex:(NSUInteger)index{
	CKFormSectionBase* section = [_sections objectAtIndex:index];
	return section;
}

- (NSInteger)indexOfSection:(CKFormSectionBase *)section{
	return [_sections indexOfObject:section];
}

@end
