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

- (void)removeObjectAtIndexPath:(NSIndexPath *)indexPath{
	CKFormTableViewController* formController = (CKFormTableViewController*)self.delegate;
	CKFormSectionBase* formSection =  (CKFormSectionBase*)[formController.sections objectAtIndex:indexPath.section];
	return [formSection removeObjectAtIndex:indexPath.row];
}

- (void)fetchRange:(NSRange)range forSection:(int)section{
	CKFormTableViewController* formController = (CKFormTableViewController*)self.delegate;
	CKFormSectionBase* formSection = (CKFormSectionBase*)[formController.sections objectAtIndex:section];
	[formSection fetchRange:range];
}

@end


@interface CKFormObjectControllerFactory : CKObjectViewControllerFactory{
}
@end

@implementation CKFormObjectControllerFactory

- (CKObjectViewControllerFactoryItem*)factoryItemAtIndexPath:(NSIndexPath*)indexPath{
	CKFormObjectController* formObjectController = (CKFormObjectController*)self.objectController;
	CKFormTableViewController* formController = (CKFormTableViewController*)formObjectController.delegate;
	CKFormSectionBase* formSection = (CKFormSectionBase*)[formController.sections objectAtIndex:indexPath.section];
	return [formSection factoryItemForIndex:indexPath.row];
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

- (CKObjectViewControllerFactoryItem*)factoryItemForIndex:(NSInteger)index{
	NSAssert(NO,@"Base Implementation");
	return nil;
}

- (void)updateStyleForNonNewVisibleCells{
	NSAssert(NO,@"Base Implementation");
}

- (void)removeObjectAtIndex:(NSInteger)index{
	NSAssert(NO,@"Base Implementation");
}

- (void)fetchRange:(NSRange)range{}

- (void)updateStyleForExistingCells{
	//Update style for indexpath that have not been applyed
	NSInteger count = [self numberOfObjects];
	for(NSInteger i = 0; i < count; ++i){
		NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:self.sectionIndex];
		CKTableViewCellController* controller = [self.parentController controllerForRowAtIndexPath:indexPath];
		if(controller){
			NSMutableDictionary* controllerStyle = [controller controllerStyle];
			[controller applyStyle:controllerStyle forCell:controller.tableViewCell];
		}
	}
}

- (void)start{}
- (void)stop{}

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

- (CKObjectViewControllerFactoryItem*)factoryItemForIndex:(NSInteger)index{
	CKFormCellDescriptor* cellDescriptor = [_cellDescriptors objectAtIndex:index];
	return (CKObjectViewControllerFactoryItem*)cellDescriptor;
}

- (void)updateStyleForNonNewVisibleCells{
	//Update style for indexpath that have not been applyed
	NSInteger sectionIndex = [self sectionIndex];
	
	NSArray *visibleCells = [self.parentController.tableView visibleCells];
	for (UITableViewCell *cell in visibleCells) {
		NSIndexPath *indexPath = [self.parentController.tableView indexPathForCell:cell];
		if(indexPath.section == sectionIndex){
			CKTableViewCellController* controller = [self.parentController controllerForRowAtIndexPath:indexPath];
			NSAssert(controller != nil,@"invalid controller");
			
			NSMutableDictionary* controllerStyle = [controller controllerStyle];
			[controller applyStyle:controllerStyle forCell:cell];
		}
	}
}

- (void)removeObjectAtIndex:(NSInteger)index{
	NSAssert(NO,@"NOT IMPLEMENTED");
}

@end

@interface CKFormDocumentCollectionSection()
@property (nonatomic,retain) CKDocumentController* objectController;
@property (nonatomic,retain) CKObjectViewControllerFactory* controllerFactory;
@property (nonatomic,retain) NSMutableArray* changeSet;
@end

@implementation CKFormDocumentCollectionSection
@synthesize objectController = _objectController;
@synthesize controllerFactory = _controllerFactory;
@synthesize headerCellDescriptors = _headerCellDescriptors;
@synthesize footerCellDescriptors = _footerCellDescriptors;
@synthesize changeSet = _changeSet;


- (id)initWithCollection:(CKDocumentCollection*)collection mappings:(NSArray*)mappings{
	[super init];
	self.objectController = [CKDocumentController controllerWithCollection:collection];
	
	self.controllerFactory = [CKObjectViewControllerFactory factoryWithMappings:mappings];
	if([_controllerFactory respondsToSelector:@selector(setObjectController:)]){
		[_controllerFactory performSelector:@selector(setObjectController:) withObject:_objectController];
	}
	
	return self;
}


- (void)start{
	if([_objectController respondsToSelector:@selector(setDelegate:)]){
		[_objectController performSelector:@selector(setDelegate:) withObject:self];
	}
}

- (void)stop{
	if([_objectController respondsToSelector:@selector(setDelegate:)]){
		[_objectController performSelector:@selector(setDelegate:) withObject:nil];
	}
}

+ (CKFormDocumentCollectionSection*)sectionWithCollection:(CKDocumentCollection*)collection mappings:(NSArray*)mappings{
	CKFormDocumentCollectionSection* section = [[[CKFormDocumentCollectionSection alloc]initWithCollection:collection mappings:mappings]autorelease];
	return section;
}

+ (CKFormDocumentCollectionSection*)sectionWithCollection:(CKDocumentCollection*)collection mappings:(NSArray*)mappings headerTitle:(NSString*)title{
	CKFormDocumentCollectionSection* section = [[[CKFormDocumentCollectionSection alloc]initWithCollection:collection mappings:mappings]autorelease];
	section.headerTitle = title;
	return section;
}

- (NSInteger)numberOfObjects{
	NSInteger count = 0;
	count += [_headerCellDescriptors count];
	if([_objectController respondsToSelector:@selector(numberOfObjectsForSection:)]){
		count += [_objectController numberOfObjectsForSection:0];
	}
	count += [_footerCellDescriptors count];
	return count;
}

- (id)objectAtIndex:(NSInteger)index{
	int headerCount = [_headerCellDescriptors count];
	if(index < headerCount){
		CKFormCellDescriptor* cellDescriptor = [_headerCellDescriptors objectAtIndex:index];
		return cellDescriptor.value;
	}
	
	int count = [_objectController numberOfObjectsForSection:0];
	if(index < count + headerCount){
		if([_objectController respondsToSelector:@selector(objectAtIndexPath:)]){
			return [_objectController objectAtIndexPath:[NSIndexPath indexPathForRow:(index - headerCount) inSection:0]];
		}
	}
	
	
	int footerCount = [_footerCellDescriptors count];
	if(index < count + headerCount +footerCount){
		CKFormCellDescriptor* cellDescriptor = [_footerCellDescriptors objectAtIndex:index - (count + headerCount)];
		return cellDescriptor.value;
	}
	
	return nil;
}


- (void)fetchRange:(NSRange)range{
	int headerCount = [_headerCellDescriptors count];
	if([_objectController respondsToSelector:@selector(objectAtIndexPath:)]){
		[_objectController fetchRange:NSMakeRange(range.location - headerCount,range.length) forSection:0];
	}
}

- (CKObjectViewControllerFactoryItem*)factoryItemForIndex:(NSInteger)index{
	int headerCount = [_headerCellDescriptors count];
	if(index < headerCount){
		CKFormCellDescriptor* cellDescriptor = [_headerCellDescriptors objectAtIndex:index];
		return cellDescriptor;
	}
	
	int count = [_objectController numberOfObjectsForSection:0];
	if(index < count + headerCount){
		return [_controllerFactory factoryItemAtIndexPath:[NSIndexPath indexPathForRow:(index - headerCount) inSection:0]];
	}
	
	int footerCount = [_footerCellDescriptors count];
	if(index < count + headerCount +footerCount){
		CKFormCellDescriptor* cellDescriptor = [_footerCellDescriptors objectAtIndex:index - (count + headerCount)];
		return cellDescriptor;
	}
	
	return nil;
}

- (void)removeObjectAtIndex:(NSInteger)index{
	int headerCount = [_headerCellDescriptors count];
	if(index < headerCount){
		NSAssert(NO,@"NOT IMPLEMENTED");
	}
	
	int count = [_objectController numberOfObjectsForSection:0];
	if(index < count + headerCount){
		if([_objectController respondsToSelector:@selector(removeObjectAtIndexPath:)]){
			return [_objectController removeObjectAtIndexPath:[NSIndexPath indexPathForRow:(index - headerCount) inSection:0]];
		}
	}
	
	int footerCount = [_footerCellDescriptors count];
	if(index < count + headerCount + footerCount){
		NSAssert(NO,@"NOT IMPLEMENTED");
	}
}

- (void)updateStyleForNonNewVisibleCells{
	//Update style for indexpath that have not been applyed
	NSInteger sectionIndex = [self sectionIndex];
	
	NSArray *visibleCells = [self.parentController.tableView visibleCells];
	for (UITableViewCell *cell in visibleCells) {
		NSIndexPath *indexPath = [self.parentController.tableView indexPathForCell:cell];
		if((self.changeSet == nil || [self.changeSet containsObject:indexPath] == NO)
		   && indexPath.section == sectionIndex){
			CKTableViewCellController* controller = [self.parentController controllerForRowAtIndexPath:indexPath];
			NSAssert(controller != nil,@"invalid controller");
			
			NSMutableDictionary* controllerStyle = [controller controllerStyle];
			[controller applyStyle:controllerStyle forCell:cell];
		}
	}
	
	[self.changeSet removeAllObjects];	
}

- (void)objectControllerReloadData:(id)controller{
	[self.parentController performSelector:@selector(objectControllerReloadData:) withObject:self.objectController];
	[self updateStyleForNonNewVisibleCells];
}

- (void)objectControllerDidBeginUpdating:(id)controller{
	if(self.changeSet == nil){
		self.changeSet = [NSMutableArray array];
	}
	[self.parentController performSelector:@selector(objectControllerDidBeginUpdating:) withObject:self.objectController];
}

- (void)objectControllerDidEndUpdating:(id)controller{
	[self.parentController performSelector:@selector(objectControllerDidEndUpdating:) withObject:self.objectController];
	[self updateStyleForNonNewVisibleCells];
}

- (void)objectController:(id)controller insertObject:(id)object atIndexPath:(NSIndexPath*)indexPath{
	int headerCount = [_headerCellDescriptors count];
	NSIndexPath* theIndexPath = [NSIndexPath indexPathForRow:(indexPath.row + headerCount) inSection:self.sectionIndex];
	[self.changeSet addObject:theIndexPath];
	[self.parentController performSelector:@selector(objectController:insertObject:atIndexPath:) 
							   withObjects:[NSArray arrayWithObjects:self.objectController,object,theIndexPath,nil]];
}

- (void)objectController:(id)controller removeObject:(id)object atIndexPath:(NSIndexPath*)indexPath{
	int headerCount = [_headerCellDescriptors count];
	NSIndexPath* theIndexPath = [NSIndexPath indexPathForRow:(indexPath.row + headerCount) inSection:self.sectionIndex];
	[self.parentController performSelector:@selector(objectController:removeObject:atIndexPath:) 
								withObjects:[NSArray arrayWithObjects:self.objectController,object,theIndexPath,nil]];
}


- (void)objectController:(id)controller insertObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths{
	int headerCount = [_headerCellDescriptors count];
	NSMutableArray* newIndexPaths = [NSMutableArray array];
	for(int i=0;i<[indexPaths count];++i){
		NSIndexPath* indexPath = [indexPaths objectAtIndex:i];
		NSIndexPath* newIndexPath = [NSIndexPath indexPathForRow:indexPath.row + headerCount inSection:self.sectionIndex];
		[newIndexPaths addObject:newIndexPath];
		
		[self.changeSet addObject:newIndexPath];
	}
	[self.parentController performSelector:@selector(objectController:insertObjects:atIndexPaths:) 
							   withObjects:[NSArray arrayWithObjects:self.objectController,objects,newIndexPaths,nil]];
}

- (void)objectController:(id)controller removeObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths{
	int headerCount = [_headerCellDescriptors count];
	NSMutableArray* newIndexPaths = [NSMutableArray array];
	for(int i=0;i<[indexPaths count];++i){
		NSIndexPath* indexPath = [indexPaths objectAtIndex:i];
		NSIndexPath* newIndexPath = [NSIndexPath indexPathForRow:indexPath.row + headerCount inSection:self.sectionIndex];
		[newIndexPaths addObject:newIndexPath];
	}
	[self.parentController performSelector:@selector(objectController:removeObjects:atIndexPaths:) 
							   withObjects:[NSArray arrayWithObjects:self.objectController,objects,newIndexPaths,nil]];
}

@end


@implementation CKFormCellDescriptor
@synthesize value = _value;

- (id)initWithValue:(id)theValue controllerClass:(Class)theControllerClass withBlock:(CKFormCellInitializeBlock)initializeBlock{
	[super init];
	self.value = theValue;
	self.controllerClass = theControllerClass;
	[self.params setObject:[CKCallback callbackWithBlock:^(id controller){initializeBlock(controller); return (id)nil;}] forKey:CKObjectViewControllerFactoryItemInit];
	return self;
}

- (id)initWithValue:(id)theValue controllerClass:(Class)theControllerClass target:(id)theTarget action:(SEL)theAction{
	[super init];
	self.value = theValue;
	self.controllerClass = theControllerClass;
	[self.params setObject:[CKCallback callbackWithTarget:theTarget action:theAction] forKey:CKObjectViewControllerFactoryItemInit];
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

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	
	for(CKFormSectionBase* section in _sections){
		[section updateStyleForNonNewVisibleCells];
	}
	
	for(CKFormSectionBase* section in _sections){
		[section start];
	}
}

- (void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
	for(CKFormSectionBase* section in _sections){
		[section stop];
	}
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
	
	if([self.view superview] != nil){
		[section start];
	}
	[_sections addObject:section];
}

- (CKFormSection *)addSectionWithCellDescriptors:(NSArray *)cellDescriptors{
	CKFormSection* section = [CKFormSection sectionWithCellDescriptors:cellDescriptors];
	if(_sections == nil){
		self.sections = [NSMutableArray array];
	}
	section.parentController = self;
	
	if([self.view superview] != nil){
		[section start];
	}
	
	[_sections addObject:section];
	return section;
}

- (CKFormSection *)addSectionWithCellDescriptors:(NSArray *)cellDescriptors headerTitle:(NSString *)headerTitle{
	CKFormSection* section = [CKFormSection sectionWithCellDescriptors:cellDescriptors headerTitle:headerTitle];
	if(_sections == nil){
		self.sections = [NSMutableArray array];
	}
	section.parentController = self;
	
	if([self.view superview] != nil){
		[section start];
	}
	
	[_sections addObject:section];
	return section;
}

- (CKFormDocumentCollectionSection *)addSectionWithCollection:(CKDocumentCollection*)collection mappings:(NSArray*)mappings{
	CKFormDocumentCollectionSection* section = [CKFormDocumentCollectionSection sectionWithCollection:collection mappings:mappings];
	if(_sections == nil){
		self.sections = [NSMutableArray array];
	}
	section.parentController = self;
	
	if([self.view superview] != nil){
		[section start];
	}
	
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
