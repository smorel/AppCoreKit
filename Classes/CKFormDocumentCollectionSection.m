//
//  CKFormDocumentCollectionSection.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-11-28.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import "CKFormDocumentCollectionSection.h"
#import "CKFormTableViewController.h"
#import "CKFormDocumentCollectionSection_private.h"
#import "CKFormTableViewController_private.h"
#import "CKFormSectionBase_private.h"
#import "CKObjectController.h"
#import "CKItemViewControllerFactory.h"
#import "CKNSObject+Invocation.h"
#import "CKStyleManager.h"
#import "CKUIView+Style.h"
#import "CKTableViewCellController+Style.h"

#import "CKDebug.h"

//Private interfaces

@interface CKItemViewControllerFactory ()

@property (nonatomic, assign) id objectController;
- (CKItemViewControllerFactoryItem*)factoryItemAtIndexPath:(NSIndexPath*)indexPath;
- (CKItemViewFlags)flagsForControllerIndexPath:(NSIndexPath*)indexPath params:(NSMutableDictionary*)params;
- (CGSize)sizeForControllerAtIndexPath:(NSIndexPath*)indexPath params:(NSMutableDictionary*)params;
- (id)controllerForObject:(id)object atIndexPath:(NSIndexPath*)indexPath;

@end

//CKFormDocumentCollectionSection

@implementation CKFormDocumentCollectionSection
@synthesize objectController = _objectController;
@synthesize controllerFactory = _controllerFactory;
@synthesize headerCellDescriptors = _headerCellDescriptors;
@synthesize footerCellDescriptors = _footerCellDescriptors;
@synthesize changeSet = _changeSet;

- (void)dealloc{
    [super dealloc];
}

- (void)start{
	if([_objectController respondsToSelector:@selector(setDelegate:)]){
		[_objectController performSelector:@selector(setDelegate:) withObject:self];
	}
}

- (void)stop{
	/*if([_objectController respondsToSelector:@selector(setDelegate:)]){
     [_objectController performSelector:@selector(setDelegate:) withObject:nil];
     }*/
}

- (void)lock{
	[_objectController lock];
}

- (void)unlock{
	[_objectController unlock];
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
    if(index < 0)
        return nil;
    
	int headerCount = [_headerCellDescriptors count];
	if((NSInteger)index < (NSInteger)headerCount){
		CKFormCellDescriptor* cellDescriptor = [_headerCellDescriptors objectAtIndex:index];
		id object =  cellDescriptor.value;
		return object;
	}
	
	int count = [_objectController numberOfObjectsForSection:0];
	if((NSInteger)index < (NSInteger)(count + headerCount)){
		if([_objectController respondsToSelector:@selector(objectAtIndexPath:)]){
			id object = [_objectController objectAtIndexPath:[NSIndexPath indexPathForRow:(index - headerCount) inSection:0]];
			return object;
		}
	}
	
	
	int footerCount = [_footerCellDescriptors count];
	if((NSInteger)index < (NSInteger)(count + headerCount +footerCount)){
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

- (CKItemViewControllerFactoryItem*)factoryItemForIndex:(NSInteger)index{
    if(index < 0)
        return nil;
    
	int headerCount = [_headerCellDescriptors count];
	if((NSInteger)index < (NSInteger)headerCount){
		CKFormCellDescriptor* cellDescriptor = [_headerCellDescriptors objectAtIndex:index];
		return cellDescriptor;
	}
	
	int count = [_objectController numberOfObjectsForSection:0];
	if((NSInteger)index < (NSInteger)(count + headerCount)){
		return [_controllerFactory factoryItemAtIndexPath:[NSIndexPath indexPathForRow:(index - headerCount) inSection:0]];
	}
	
	int footerCount = [_footerCellDescriptors count];
	if((NSInteger)index < (NSInteger)(count + headerCount +footerCount)){
		CKFormCellDescriptor* cellDescriptor = [_footerCellDescriptors objectAtIndex:index - (count + headerCount)];
		return cellDescriptor;
	}
	
	return nil;
}

- (void)removeObjectAtIndex:(NSInteger)index{
    if(index < 0)
        return;
    
	int headerCount = [_headerCellDescriptors count];
	if((NSInteger)index < (NSInteger)headerCount){
		NSAssert(NO,@"NOT IMPLEMENTED");
	}
	
	int count = [_objectController numberOfObjectsForSection:0];
	if((NSInteger)index < (NSInteger)(count + headerCount)){
		if([_objectController respondsToSelector:@selector(removeObjectAtIndexPath:)]){
			return [_objectController removeObjectAtIndexPath:[NSIndexPath indexPathForRow:(index - headerCount) inSection:0]];
		}
	}
	
	int footerCount = [_footerCellDescriptors count];
	if((NSInteger)index < (NSInteger)(count + headerCount + footerCount)){
		NSAssert(NO,@"NOT IMPLEMENTED");
	}
}

- (void)updateStyleForNonNewVisibleCells{
    [self.parentController updateVisibleViewsIndexPath];
        //Update style for indexpath that have not been applyed
	NSInteger sectionIndex = [self sectionVisibleIndex];
	
	NSArray *visibleIndexPaths = [self.parentController visibleIndexPaths];
	for (NSIndexPath *indexPath in visibleIndexPaths) {
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
	if(_hidden && _parentController.autoHideSections){
		NSInteger objectCount = [self numberOfObjects];
		if(objectCount > 0 ){
            [_parentController setSections:[NSArray arrayWithObject:self] hidden:NO];
			sectionUpdate = YES;
			return;
		}
	}
	
	if(!_hidden && _parentController.autoHideSections){
		NSInteger objectCount = [self numberOfObjects];
		if(objectCount <= 0 ){
            [_parentController setSections:[NSArray arrayWithObject:self] hidden:YES];
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
	if(sectionUpdate || self.hidden || self.collapsed){
		return;
	}
	
	int headerCount = [_headerCellDescriptors count];
	NSIndexPath* theIndexPath = [NSIndexPath indexPathForRow:(indexPath.row + headerCount) inSection:self.sectionVisibleIndex];
	[self.changeSet addObject:theIndexPath];
	[self.parentController performSelector:@selector(objectController:insertObject:atIndexPath:) 
							   withObjects:[NSArray arrayWithObjects:self.objectController,object,theIndexPath,nil]];
}

- (void)objectController:(id)controller removeObject:(id)object atIndexPath:(NSIndexPath*)indexPath{
	if(sectionUpdate || self.hidden || self.collapsed){
		return;
	}
	
	int headerCount = [_headerCellDescriptors count];
	NSIndexPath* theIndexPath = [NSIndexPath indexPathForRow:(indexPath.row + headerCount) inSection:self.sectionVisibleIndex];
	[self.parentController performSelector:@selector(objectController:removeObject:atIndexPath:) 
                               withObjects:[NSArray arrayWithObjects:self.objectController,object,theIndexPath,nil]];
}


- (void)objectController:(id)controller insertObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths{
	if(sectionUpdate || self.hidden || self.collapsed){
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
	if(sectionUpdate || self.hidden || self.collapsed){
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
	
	if(![_parentController reloading] && !self.collapsed){
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
	
	if(![_parentController reloading] && !self.collapsed){
		[self objectControllerDidBeginUpdating:self.objectController];
		[self objectController:self.objectController insertObject:descriptor.value atIndexPath:[NSIndexPath indexPathForRow:index inSection:self.sectionVisibleIndex]];
		[self objectControllerDidEndUpdating:self.objectController];
	}
	
	return descriptor;
}

- (void)removeFooterCellDescriptor:(CKFormCellDescriptor*)descriptor{
    NSInteger footerIndex = [_footerCellDescriptors indexOfObjectIdenticalTo:descriptor];
    NSAssert(footerIndex != NSNotFound,@"cannot find %@",descriptor);
    int headerCount = [_headerCellDescriptors count];
	int count = [_objectController numberOfObjectsForSection:0];
	int index = headerCount + count + footerIndex;
	
	[self.footerCellDescriptors removeObjectAtIndex:footerIndex];
	
	if(![_parentController reloading] && !self.collapsed){
		[self objectControllerDidBeginUpdating:self.objectController];
		[self objectController:self.objectController removeObject:descriptor.value atIndexPath:[NSIndexPath indexPathForRow:index inSection:self.sectionVisibleIndex]];
		[self objectControllerDidEndUpdating:self.objectController];
	}
}

- (void)removeHeaderCellDescriptor:(CKFormCellDescriptor*)descriptor{
    NSInteger headerIndex = [_headerCellDescriptors indexOfObjectIdenticalTo:descriptor];
	int index = headerIndex;
	
	[self.headerCellDescriptors removeObjectAtIndex:headerIndex];
	
	if(![_parentController reloading] && !self.collapsed){
		[self objectControllerDidBeginUpdating:self.objectController];
		[self objectController:self.objectController removeObject:descriptor.value atIndexPath:[NSIndexPath indexPathForRow:index inSection:self.sectionVisibleIndex]];
		[self objectControllerDidEndUpdating:self.objectController];
	}
}

- (id)initWithCollection:(CKCollection*)collection factory:(CKItemViewControllerFactory*)factory{
    [super init];
	self.objectController = [CKCollectionController controllerWithCollection:collection];
	self.controllerFactory = factory;
    
	if([_controllerFactory respondsToSelector:@selector(setObjectController:)]){
		[_controllerFactory performSelector:@selector(setObjectController:) withObject:_objectController];
	}
	
	if(_parentController.autoHideSections && (collection.count <= 0)) {
		self.hidden = YES;
	}
	
	sectionUpdate = NO;
	
	self.headerCellDescriptors = [NSMutableArray array];
	self.footerCellDescriptors = [NSMutableArray array];
	
	return self;

}

+ (CKFormDocumentCollectionSection*)sectionWithCollection:(CKCollection*)collection factory:(CKItemViewControllerFactory*)factory{
	CKFormDocumentCollectionSection* section = [[[CKFormDocumentCollectionSection alloc]initWithCollection:collection factory:factory]autorelease];
	return section;
}

+ (CKFormDocumentCollectionSection*)sectionWithCollection:(CKCollection*)collection factory:(CKItemViewControllerFactory*)factory headerTitle:(NSString*)title{
	CKFormDocumentCollectionSection* section = [[[CKFormDocumentCollectionSection alloc]initWithCollection:collection factory:factory]autorelease];
	section.headerTitle = title;
	return section;
}

+ (CKFormDocumentCollectionSection*)sectionWithCollection:(CKCollection*)collection factory:(CKItemViewControllerFactory*)factory appendCollectionCellControllerAsFooterCell:(BOOL)appendCollectionCellControllerAsFooterCell{
	CKFormDocumentCollectionSection* section = [[[CKFormDocumentCollectionSection alloc]initWithCollection:collection factory:factory]autorelease];
	section.objectController.appendCollectionCellControllerAsFooterCell = appendCollectionCellControllerAsFooterCell;
	return section;
}

+ (CKFormDocumentCollectionSection*)sectionWithCollection:(CKCollection*)collection factory:(CKItemViewControllerFactory*)factory headerTitle:(NSString*)title appendCollectionCellControllerAsFooterCell:(BOOL)appendCollectionCellControllerAsFooterCell{
	CKFormDocumentCollectionSection* section = [CKFormDocumentCollectionSection sectionWithCollection:collection factory:factory appendCollectionCellControllerAsFooterCell:appendCollectionCellControllerAsFooterCell];
	section.headerTitle = title;
	return section;
}


- (CKFormCellDescriptor*)addFooterCellController:(CKTableViewCellController*)controller{
    return [self addFooterCellDescriptor:[CKFormCellDescriptor cellDescriptorWithCellController:controller]];
}

- (void)removeFooterCellController:(CKTableViewCellController*)controller{
    [self removeFooterCellDescriptor:[self footerCellDescriptorForCellController:controller]];
}

- (CKFormCellDescriptor*)addHeaderCellController:(CKTableViewCellController*)controller{
    return [self addHeaderCellDescriptor:[CKFormCellDescriptor cellDescriptorWithCellController:controller]];
}

- (void)removeHeaderCellController:(CKTableViewCellController*)controller{
    [self removeHeaderCellDescriptor:[self headerCellDescriptorForCellController:controller]];
}

- (CKFormCellDescriptor*)headerCellDescriptorForCellController:(CKTableViewCellController*)controller{
    for(CKFormCellDescriptor* descriptor in self.headerCellDescriptors){
        if(descriptor.cellController == controller){
            return descriptor;
        }
    }
    return nil;
}

- (CKFormCellDescriptor*)footerCellDescriptorForCellController:(CKTableViewCellController*)controller{
    for(CKFormCellDescriptor* descriptor in self.footerCellDescriptors){
        if(descriptor.cellController == controller){
            return descriptor;
        }
    }
    return nil;
}

@end