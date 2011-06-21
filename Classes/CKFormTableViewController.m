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
	CKFormTableViewController* _parentController;
}
@property (nonatomic, assign) id delegate;
@property (nonatomic,assign) CKFormTableViewController* parentController;
- (id)initWithParentController:(CKFormTableViewController*)controller;
@end

@implementation CKFormObjectController
@synthesize delegate = _delegate;
@synthesize parentController = _parentController;

- (id)initWithParentController:(CKFormTableViewController*)controller{
	[super init];
	self.parentController = controller;
	return self;
}

- (NSInteger)numberOfSections{
	return [self.parentController numberOfVisibleSections];
}

- (NSInteger)numberOfObjectsForSection:(NSInteger)section{
	CKFormSectionBase* formSection = (CKFormSectionBase*)[self.parentController visibleSectionAtIndex:section];
	return [formSection numberOfObjects];
}

- (NSString*)headerTitleForSection:(NSInteger)section{
	NSInteger sectionCount = [self numberOfSections];
	if(sectionCount <= 1)
		return nil;
	
	CKFormSectionBase* formSection =  (CKFormSectionBase*)[self.parentController visibleSectionAtIndex:section];
	return formSection.headerTitle;
}

- (UIView*)headerViewForSection:(NSInteger)section{
	NSInteger sectionCount = [self numberOfSections];
	if(sectionCount <= 1)
		 return nil;
	
	CKFormSectionBase* formSection =  (CKFormSectionBase*)[self.parentController visibleSectionAtIndex:section];
	if( formSection.headerView != nil ){
		NSMutableDictionary* controllerStyle = [[CKStyleManager defaultManager] styleForObject:self  propertyName:nil];
		[formSection.headerView applyStyle:controllerStyle];
	}
	return formSection.headerView;
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath{
	CKFormSectionBase* formSection =  (CKFormSectionBase*)[self.parentController visibleSectionAtIndex:indexPath.section];
	id object = [formSection objectAtIndex:indexPath.row];
	return object;
}

- (void)setDelegate:(id)theDelegate{
	_delegate = theDelegate;
}

- (void)removeObjectAtIndexPath:(NSIndexPath *)indexPath{
	CKFormSectionBase* formSection =  (CKFormSectionBase*)[self.parentController visibleSectionAtIndex:indexPath.section];
	return [formSection removeObjectAtIndex:indexPath.row];
}

- (void)fetchRange:(NSRange)range forSection:(int)section{
	CKFormSectionBase* formSection = (CKFormSectionBase*)[self.parentController visibleSectionAtIndex:section];
	[formSection fetchRange:range];
}

- (void)lock{
	for(int i=0;i<[self numberOfSections];++i){
		CKFormSectionBase* formSection =  (CKFormSectionBase*)[self.parentController visibleSectionAtIndex:i];
		[formSection lock];
	}
}

- (void)unlock{
	for(int i=0;i<[self numberOfSections];++i){
		CKFormSectionBase* formSection =  (CKFormSectionBase*)[self.parentController visibleSectionAtIndex:i];
		[formSection unlock];
	}
}

@end


@interface CKFormObjectControllerFactory : CKObjectViewControllerFactory{
}
@end

@implementation CKFormObjectControllerFactory

- (CKObjectViewControllerFactoryItem*)factoryItemAtIndexPath:(NSIndexPath*)indexPath{
	CKFormObjectController* formObjectController = (CKFormObjectController*)self.objectController;
	CKFormTableViewController* formController = (CKFormTableViewController*)formObjectController.parentController;
	CKFormSectionBase* formSection = (CKFormSectionBase*)[formController visibleSectionAtIndex:indexPath.section];
	return [formSection factoryItemForIndex:indexPath.row];
}

@end


@implementation CKFormSectionBase
@synthesize headerTitle = _headerTitle;
@synthesize headerView = _headerView;
@synthesize parentController = _parentController;
@synthesize hidden = _hidden;

- (id)init{
	[super init];
	_hidden = NO;
	return self;
}

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

- (void)lock{
}

- (void)unlock{
}

- (void)fetchRange:(NSRange)range{}

- (void)updateStyleForExistingCells{
	//Update style for indexpath that have not been applyed
	NSInteger count = [self numberOfObjects];
	for(NSInteger i = 0; i < count; ++i){
		NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:self.sectionVisibleIndex];
		CKItemViewController* controller = [self.parentController controllerAtIndexPath:indexPath];
		if(controller){
			[controller applyStyle];
		}
	}
}

- (void)start{}
- (void)stop{}

- (NSInteger)sectionVisibleIndex{
	return [_parentController indexOfVisibleSection:self];
}

- (void)setHidden:(BOOL)bo{
	if([_parentController reloading]){
		_hidden = bo;
	}
	else if(_hidden != bo){
		[_parentController objectControllerDidBeginUpdating:_parentController.objectController];
		_hidden = bo;
		if(bo){
			[_parentController objectController:_parentController.objectController removeSectionAtIndex:self.sectionVisibleIndex];
		}
		else{
			[_parentController objectController:_parentController.objectController insertSectionAtIndex:self.sectionVisibleIndex];
		}
		[_parentController objectControllerDidEndUpdating:_parentController.objectController];
	}
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

- (CKFormCellDescriptor*)insertCellDescriptor:(CKFormCellDescriptor *)cellDescriptor atIndex:(NSUInteger)index{
	if(_cellDescriptors == nil){
		self.cellDescriptors = [NSMutableArray array];
	}
	[_cellDescriptors insertObject:cellDescriptor atIndex:index];
	return cellDescriptor;
}

- (CKFormCellDescriptor*)addCellDescriptor:(CKFormCellDescriptor *)cellDescriptor{
	if(_cellDescriptors == nil){
		self.cellDescriptors = [NSMutableArray array];
	}
	[_cellDescriptors addObject:cellDescriptor];
	return cellDescriptor;
}

- (void)removeCellDescriptorAtIndex:(NSUInteger)index{
	[_cellDescriptors removeObjectAtIndex:index];
}


- (NSInteger)numberOfObjects{
	return [_cellDescriptors count];
}

- (id)objectAtIndex:(NSInteger)index{
	CKFormCellDescriptor* cellDescriptor = [_cellDescriptors objectAtIndex:index];
	id object =  cellDescriptor.value;
	return object;
}

- (CKObjectViewControllerFactoryItem*)factoryItemForIndex:(NSInteger)index{
	CKFormCellDescriptor* cellDescriptor = [_cellDescriptors objectAtIndex:index];
	return (CKObjectViewControllerFactoryItem*)cellDescriptor;
}

- (void)updateStyleForNonNewVisibleCells{
	//Update style for indexpath that have not been applyed
	NSInteger sectionIndex = [self sectionVisibleIndex];
	
	NSArray *visibleCells = [self.parentController.tableView visibleCells];
	for (UITableViewCell *cell in visibleCells) {
		NSIndexPath *indexPath = [self.parentController.tableView indexPathForCell:cell];
		if(indexPath.section == sectionIndex){
			CKItemViewController* controller = [self.parentController controllerAtIndexPath:indexPath];
			NSAssert(controller != nil,@"invalid controller");
			[controller applyStyle];
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

@property (nonatomic,retain,readwrite) NSMutableArray* headerCellDescriptors;
@property (nonatomic,retain,readwrite) NSMutableArray* footerCellDescriptors;
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
	
	if(collection.count <= 0){
		_hidden = YES;
	}
	
	sectionUpdate = NO;
	
	self.headerCellDescriptors = [NSMutableArray array];
	self.footerCellDescriptors = [NSMutableArray array];
	
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

- (void)lock{
	[_objectController lock];
}

- (void)unlock{
	[_objectController unlock];
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

+ (CKFormDocumentCollectionSection*)sectionWithCollection:(CKDocumentCollection*)collection mappings:(NSArray*)mappings displayFeedSourceCell:(BOOL)displayFeedSourceCell{
	CKFormDocumentCollectionSection* section = [[[CKFormDocumentCollectionSection alloc]initWithCollection:collection mappings:mappings]autorelease];
	section.objectController.displayFeedSourceCell = displayFeedSourceCell;
	return section;
}

+ (CKFormDocumentCollectionSection*)sectionWithCollection:(CKDocumentCollection*)collection mappings:(NSArray*)mappings headerTitle:(NSString*)title displayFeedSourceCell:(BOOL)displayFeedSourceCell{
	CKFormDocumentCollectionSection* section = [CKFormDocumentCollectionSection sectionWithCollection:collection mappings:mappings displayFeedSourceCell:displayFeedSourceCell];
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
		id object =  cellDescriptor.value;
		return object;
	}
	
	int count = [_objectController numberOfObjectsForSection:0];
	if(index < count + headerCount){
		if([_objectController respondsToSelector:@selector(objectAtIndexPath:)]){
			id object = [_objectController objectAtIndexPath:[NSIndexPath indexPathForRow:(index - headerCount) inSection:0]];
			return object;
		}
	}
	
	
	int footerCount = [_footerCellDescriptors count];
	if(index < count + headerCount +footerCount){
		CKFormCellDescriptor* cellDescriptor = [_footerCellDescriptors objectAtIndex:index - (count + headerCount)];
		id object =  cellDescriptor.value;
		return object;
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
	NSInteger sectionIndex = [self sectionVisibleIndex];
	
	NSArray *visibleCells = [self.parentController.tableView visibleCells];
	for (UITableViewCell *cell in visibleCells) {
		NSIndexPath *indexPath = [self.parentController.tableView indexPathForCell:cell];
		if((self.changeSet == nil || [self.changeSet containsObject:indexPath] == NO)
		   && indexPath.section == sectionIndex){
			CKItemViewController* controller = [self.parentController controllerAtIndexPath:indexPath];
			if(controller != nil){
				[controller applyStyle];
			}
		}
	}
	
	[self.changeSet removeAllObjects];	
}

- (void)objectControllerReloadData:(id)controller{
	[self.parentController performSelector:@selector(objectControllerReloadData:) withObject:self.objectController];
	[self updateStyleForNonNewVisibleCells];
}

- (void)objectControllerDidBeginUpdating:(id)controller{
	if(_hidden){
		NSInteger objectCount = [self numberOfObjects];
		if(objectCount > 0 ){
			self.hidden = NO;
			sectionUpdate = YES;
			return;
		}
	}
	
	if(!_hidden){
		NSInteger objectCount = [self numberOfObjects];
		if(objectCount <= 0 ){
			self.hidden = YES;
			sectionUpdate = YES;
			return;
		}
	}
	
	
	if(self.changeSet == nil){
		self.changeSet = [NSMutableArray array];
	}
	[self.parentController performSelector:@selector(objectControllerDidBeginUpdating:) withObject:self.objectController];
}

- (void)objectControllerDidEndUpdating:(id)controller{
	if(sectionUpdate){
		sectionUpdate = NO;
		return;
	}
	[self.parentController performSelector:@selector(objectControllerDidEndUpdating:) withObject:self.objectController];
	[self updateStyleForNonNewVisibleCells];
}

- (void)objectController:(id)controller insertObject:(id)object atIndexPath:(NSIndexPath*)indexPath{
	if(sectionUpdate){
		return;
	}
	
	int headerCount = [_headerCellDescriptors count];
	NSIndexPath* theIndexPath = [NSIndexPath indexPathForRow:(indexPath.row + headerCount) inSection:self.sectionVisibleIndex];
	[self.changeSet addObject:theIndexPath];
	[self.parentController performSelector:@selector(objectController:insertObject:atIndexPath:) 
							   withObjects:[NSArray arrayWithObjects:self.objectController,object,theIndexPath,nil]];
}

- (void)objectController:(id)controller removeObject:(id)object atIndexPath:(NSIndexPath*)indexPath{
	if(sectionUpdate){
		return;
	}
	
	int headerCount = [_headerCellDescriptors count];
	NSIndexPath* theIndexPath = [NSIndexPath indexPathForRow:(indexPath.row + headerCount) inSection:self.sectionVisibleIndex];
	[self.parentController performSelector:@selector(objectController:removeObject:atIndexPath:) 
								withObjects:[NSArray arrayWithObjects:self.objectController,object,theIndexPath,nil]];
}


- (void)objectController:(id)controller insertObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths{
	if(sectionUpdate){
		return;
	}
	int headerCount = [_headerCellDescriptors count];
	NSMutableArray* newIndexPaths = [NSMutableArray array];
	for(int i=0;i<[indexPaths count];++i){
		NSIndexPath* indexPath = [indexPaths objectAtIndex:i];
		NSIndexPath* newIndexPath = [NSIndexPath indexPathForRow:indexPath.row + headerCount inSection:self.sectionVisibleIndex];
		[newIndexPaths addObject:newIndexPath];
		
		[self.changeSet addObject:newIndexPath];
	}
	[self.parentController performSelector:@selector(objectController:insertObjects:atIndexPaths:) 
							   withObjects:[NSArray arrayWithObjects:self.objectController,objects,newIndexPaths,nil]];
}

- (void)objectController:(id)controller removeObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths{
	if(sectionUpdate){
		return;
	}
	int headerCount = [_headerCellDescriptors count];
	NSMutableArray* newIndexPaths = [NSMutableArray array];
	for(int i=0;i<[indexPaths count];++i){
		NSIndexPath* indexPath = [indexPaths objectAtIndex:i];
		NSIndexPath* newIndexPath = [NSIndexPath indexPathForRow:indexPath.row + headerCount inSection:self.sectionVisibleIndex];
		[newIndexPaths addObject:newIndexPath];
	}
	[self.parentController performSelector:@selector(objectController:removeObjects:atIndexPaths:) 
							   withObjects:[NSArray arrayWithObjects:self.objectController,objects,newIndexPaths,nil]];
}

- (void)objectController:(id)controller insertSectionAtIndex:(NSInteger)i{}
- (void)objectController:(id)controller removeSectionAtIndex:(NSInteger)i{}


- (CKFormCellDescriptor*)addFooterCellDescriptor:(CKFormCellDescriptor*)descriptor{
	int headerCount = [_headerCellDescriptors count];
	int count = [_objectController numberOfObjectsForSection:0];
	int footerCount = [_footerCellDescriptors count];
	int index = headerCount + count + footerCount;
	
	[self.footerCellDescriptors addObject:descriptor];
	
	if(![_parentController reloading]){
		[self objectControllerDidBeginUpdating:self.objectController];
		[self objectController:self.objectController insertObject:descriptor.value atIndexPath:[NSIndexPath indexPathForRow:index inSection:self.sectionVisibleIndex]];
		[self objectControllerDidEndUpdating:self.objectController];
	}
	
	return descriptor;
}

- (CKFormCellDescriptor*)addHeaderCellDescriptor:(CKFormCellDescriptor*)descriptor{
	int headerCount = [_headerCellDescriptors count];
	int index = headerCount;
	
	[self.headerCellDescriptors addObject:descriptor];
	
	if(![_parentController reloading]){
		[self objectControllerDidBeginUpdating:self.objectController];
		[self objectController:self.objectController insertObject:descriptor.value atIndexPath:[NSIndexPath indexPathForRow:index inSection:self.sectionVisibleIndex]];
		[self objectControllerDidEndUpdating:self.objectController];
	}
	
	return descriptor;
}

@end


@implementation CKFormCellDescriptor
@synthesize value = _value;

- (id)initWithValue:(id)theValue controllerClass:(Class)theControllerClass{
	[super init];
	self.value = theValue;
	self.controllerClass = theControllerClass;
	return self;
}

+ (CKFormCellDescriptor*)cellDescriptorWithValue:(id)value controllerClass:(Class)controllerClass{
	return [[[CKFormCellDescriptor alloc]initWithValue:value controllerClass:controllerClass]autorelease];
}

@end


@interface CKFormTableViewController()
@property (nonatomic,retain, readwrite) NSMutableArray* sections;
@property (nonatomic,readwrite) BOOL reloading;
@end

@implementation CKFormTableViewController
@synthesize sections = _sections;
@synthesize reloading;

- (void)postInit{
	[super postInit];
	self.objectController = [[[CKFormObjectController alloc]initWithParentController:self]autorelease];
	self.controllerFactory = [[[CKFormObjectControllerFactory alloc]init]autorelease];
	self.sections = [NSMutableArray array];
}

- (void)dealloc{
	[_sections release];
	_sections = nil;
	[super dealloc];
}

- (void)viewWillAppear:(BOOL)animated{
	for(CKFormSectionBase* section in _sections){
		[section start];
		if([section isKindOfClass:[CKFormDocumentCollectionSection class]]){
			section.hidden = ([section numberOfObjects] <= 0);
		}
	 }
	
	[super viewWillAppear:animated];
}


- (void)clear{
	self.reloading = YES;
	self.sections = [NSMutableArray array];
	[super reload];
}

- (void)reload{
	self.reloading = YES;
	if(self.viewIsOnScreen){
		for(CKFormSectionBase* section in _sections){
			[section start];
			
			if([section isKindOfClass:[CKFormDocumentCollectionSection class]]){
				section.hidden = ([section numberOfObjects] <= 0);
				if(section.hidden){
					CKFormDocumentCollectionSection* collecSection = (CKFormDocumentCollectionSection*)section;
					[collecSection.objectController.collection.feedSource fetchRange:NSMakeRange(0, self.numberOfObjectsToprefetch)];
				}
			}
		}
	}
	
	self.reloading = NO;
	[super reload];
	
	if(self.viewIsOnScreen){
		for(CKFormSectionBase* section in _sections){
			[section updateStyleForNonNewVisibleCells];
		}
	}
}

- (void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
	for(CKFormSectionBase* section in _sections){
		[section stop];
	}
}


- (id)initWithSections:(NSArray*)theSections withNibName:(NSString*)nibName{
	[super initWithNibName:nibName bundle:[NSBundle mainBundle]];
	self.sections = [NSMutableArray arrayWithArray:theSections];
	for(CKFormSectionBase* section in theSections){
		section.parentController = self;
		if(section.hidden == YES){
			if([section isKindOfClass:[CKFormDocumentCollectionSection class]]){
				CKFormDocumentCollectionSection* collecSection = (CKFormDocumentCollectionSection*)section;
				[collecSection.objectController.collection.feedSource fetchRange:NSMakeRange(0, self.numberOfObjectsToprefetch)];
			}
		}
	}
	return self;
}

- (id)initWithSections:(NSArray*)theSections{
	[self initWithSections:theSections withNibName:nil];
	return self;
}

- (CKFormSectionBase*)addSection:(CKFormSectionBase *)section{
	section.parentController = self;
	[_sections addObject:section];
	if(section.hidden == YES){
		if([section isKindOfClass:[CKFormDocumentCollectionSection class]]){
			CKFormDocumentCollectionSection* collecSection = (CKFormDocumentCollectionSection*)section;
			[collecSection.objectController.collection.feedSource fetchRange:NSMakeRange(0, self.numberOfObjectsToprefetch)];
		}
	}
	return section;
}

- (CKFormSection *)addSectionWithCellDescriptors:(NSArray *)cellDescriptors{
	return [self addSectionWithCellDescriptors:cellDescriptors headerTitle:@""];
}

- (CKFormSection *)addSectionWithCellDescriptors:(NSArray *)cellDescriptors headerTitle:(NSString *)headerTitle{
	return [self insertSectionWithCellDescriptors:cellDescriptors headerTitle:headerTitle atIndex:[_sections count]];
}

- (CKFormDocumentCollectionSection *)addSectionWithCollection:(CKDocumentCollection*)collection mappings:(NSArray*)mappings{
	return [self insertSectionWithCollection:collection mappings:mappings atIndex:[_sections count]];
}

- (CKFormSection *)insertSectionWithCellDescriptors:(NSArray *)cellDescriptors atIndex:(NSInteger)index{
	return [self insertSectionWithCellDescriptors:cellDescriptors headerTitle:@"" atIndex:index];
}

- (CKFormSection *)insertSectionWithCellDescriptors:(NSArray *)cellDescriptors headerTitle:(NSString *)headerTitle  atIndex:(NSInteger)index{
	CKFormSection* section = [CKFormSection sectionWithCellDescriptors:cellDescriptors headerTitle:headerTitle];
	section.parentController = self;
	[_sections insertObject:section atIndex:index];
	return section;
}

- (CKFormDocumentCollectionSection *)insertSectionWithCollection:(CKDocumentCollection*)collection mappings:(NSArray*)mappings atIndex:(NSInteger)index{
	CKFormDocumentCollectionSection* section = [CKFormDocumentCollectionSection sectionWithCollection:collection mappings:mappings];
	section.parentController = self;
	[_sections insertObject:section atIndex:index];
	
	if(section.hidden == YES){
		[collection.feedSource fetchRange:NSMakeRange(0, self.numberOfObjectsToprefetch)];
	}
	return section;
	
}

- (CKFormSectionBase*)sectionAtIndex:(NSUInteger)index{
	if(index >= 0 && index < [_sections count]){
		CKFormSectionBase* section = [_sections objectAtIndex:index];
		return section;
	}
	return nil;
}

- (NSInteger)indexOfSection:(CKFormSectionBase *)section{
	return [_sections indexOfObject:section];
}


- (NSInteger)numberOfVisibleSections{
	NSInteger count = 0;
	for(CKFormSectionBase* section in _sections){
		if(!section.hidden){
			++count;
		}
	}
	return count;
}

- (CKFormSectionBase*)visibleSectionAtIndex:(NSInteger)index{
	NSInteger count = 0;
	for(CKFormSectionBase* section in _sections){
		if(!section.hidden){
			if(index == count){
				return section;
			}
			++count;
		}
	}	
	return nil;
}

- (NSInteger)indexOfVisibleSection:(CKFormSectionBase*)thesection{
	NSInteger count = 0;
	for(CKFormSectionBase* section in _sections){
		if(!section.hidden){
			if(section == thesection){
				return count;
			}
			++count;
		}
	}	
	return -1;
}

@end
