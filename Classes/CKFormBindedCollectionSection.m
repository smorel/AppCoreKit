//
//  CKFormBindedCollectionSection.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import "CKFormBindedCollectionSection.h"
#import "CKFormTableViewController.h"
#import "CKFormBindedCollectionSection_private.h"
#import "CKFormTableViewController_private.h"
#import "CKFormSectionBase_private.h"
#import "CKObjectController.h"
#import "CKCollectionCellControllerFactory.h"
#import "NSObject+Invocation.h"
#import "CKStyleManager.h"
#import "UIView+Style.h"
#import "CKTableViewCellController+Style.h"
#import "CKTableViewCellController.h"

#import "CKDebug.h"

//Private interfaces

@interface CKCollectionCellControllerFactory ()

@property (nonatomic, assign) id objectController;
- (CKCollectionCellControllerFactoryItem*)factoryItemForObject:(id)object atIndexPath:(NSIndexPath*)indexPath;
- (id)controllerForObject:(id)object atIndexPath:(NSIndexPath*)indexPath;
@end

//CKFormBindedCollectionSection

@implementation CKFormBindedCollectionSection
@synthesize objectController = _objectController;
@synthesize controllerFactory = _controllerFactory;
@synthesize headerCellControllers = _headerCellControllers;
@synthesize footerCellControllers = _footerCellControllers;
@synthesize maximumNumberOfObjectsToDisplay;

- (void)dealloc{
    [super dealloc];
}

- (void)setMaximumNumberOfObjectsToDisplay:(NSInteger)themaximumNumberOfObjectsToDisplay{
    [_objectController setMaximumNumberOfObjectsToDisplay:themaximumNumberOfObjectsToDisplay];
}

- (NSInteger)maximumNumberOfObjectsToDisplay{
    return [_objectController maximumNumberOfObjectsToDisplay];
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
	count += [_headerCellControllers count];
	if([_objectController respondsToSelector:@selector(numberOfObjectsForSection:)]){
		count += [_objectController numberOfObjectsForSection:0];
	}
	count += [_footerCellControllers count];
	return count;
}

- (id)objectAtIndex:(NSInteger)index{
    if(index < 0)
        return nil;
    
	int headerCount = [_headerCellControllers count];
	if((NSInteger)index < (NSInteger)headerCount){
		CKTableViewCellController* controller = [_headerCellControllers objectAtIndex:index];
		id object =  controller.value;
		return object;
	}
	
	int count = [_objectController numberOfObjectsForSection:0];
	if((NSInteger)index < (NSInteger)(count + headerCount)){
		if([_objectController respondsToSelector:@selector(objectAtIndexPath:)]){
			id object = [_objectController objectAtIndexPath:[NSIndexPath indexPathForRow:(index - headerCount) inSection:0]];
			return object;
		}
	}
	
	
	int footerCount = [_footerCellControllers count];
	if((NSInteger)index < (NSInteger)(count + headerCount +footerCount)){
		CKTableViewCellController* controller = [_footerCellControllers objectAtIndex:index - (count + headerCount)];
		id object =  controller.value;
		return object;
	}
	
	return nil;
}


- (void)fetchRange:(NSRange)range{
	int headerCount = [_headerCellControllers count];
	if([_objectController respondsToSelector:@selector(objectAtIndexPath:)]){
		[_objectController fetchRange:NSMakeRange(range.location - headerCount,range.length) forSection:0];
	}
}


- (id)controllerForObject:(id)object atIndex:(NSInteger)index{
    if(index < 0)
        return nil;
    
	int headerCount = [_headerCellControllers count];
	if((NSInteger)index < (NSInteger)headerCount){
		CKTableViewCellController* controller = [_headerCellControllers objectAtIndex:index];
		return controller;
	}
	
	int count = [_objectController numberOfObjectsForSection:0];
	if((NSInteger)index < (NSInteger)(count + headerCount)){
        return [_controllerFactory controllerForObject:object atIndexPath:[NSIndexPath indexPathForRow:(index - headerCount) inSection:0]];
	}
	
	int footerCount = [_footerCellControllers count];
	if((NSInteger)index < (NSInteger)(count + headerCount +footerCount)){
		CKTableViewCellController* controller = [_footerCellControllers objectAtIndex:index - (count + headerCount)];
		return controller;
	}
	
	return nil;
}

- (void)removeObjectAtIndex:(NSInteger)index{
    if(index < 0)
        return;
    
	int headerCount = [_headerCellControllers count];
	if((NSInteger)index < (NSInteger)headerCount){
		NSAssert(NO,@"NOT IMPLEMENTED");
	}
	
	int count = [_objectController numberOfObjectsForSection:0];
	if((NSInteger)index < (NSInteger)(count + headerCount)){
		if([_objectController respondsToSelector:@selector(removeObjectAtIndexPath:)]){
			return [_objectController removeObjectAtIndexPath:[NSIndexPath indexPathForRow:(index - headerCount) inSection:0]];
		}
	}
	
	int footerCount = [_footerCellControllers count];
	if((NSInteger)index < (NSInteger)(count + headerCount + footerCount)){
		NSAssert(NO,@"NOT IMPLEMENTED");
	}
}

- (void)objectControllerReloadData:(id)controller{
	[self.parentController performSelector:@selector(objectControllerReloadData:) withObject:self.objectController];
}

- (void)objectControllerDidBeginUpdating:(id)controller{
	if(self.hidden && self.parentController.autoHideSections){
		NSInteger objectCount = [self numberOfObjects];
		if(objectCount > 0 ){
            [self.parentController setSections:[NSArray arrayWithObject:self] hidden:NO];
			_sectionUpdate = YES;
			return;
		}
	}
	
	if(!self.hidden && self.parentController.autoHideSections){
		NSInteger objectCount = [self numberOfObjects];
		if(objectCount <= 0 ){
            [self.parentController setSections:[NSArray arrayWithObject:self] hidden:YES];
			_sectionUpdate = YES;
			return;
		}
	}
	
	[self.parentController performSelector:@selector(objectControllerDidBeginUpdating:) withObject:self.objectController];
}

- (void)objectControllerDidEndUpdating:(id)controller{
	if(_sectionUpdate){
		_sectionUpdate = NO;
		return;
	}
	[self.parentController performSelector:@selector(objectControllerDidEndUpdating:) withObject:self.objectController];
}

- (void)objectController:(id)controller insertObject:(id)object atIndexPath:(NSIndexPath*)indexPath{
	if(_sectionUpdate || self.hidden || self.collapsed){
		return;
	}
	
	int headerCount = [_headerCellControllers count];
	NSIndexPath* theIndexPath = [NSIndexPath indexPathForRow:(indexPath.row + headerCount) inSection:self.sectionVisibleIndex];
    
	[self.parentController performSelector:@selector(objectController:insertObject:atIndexPath:) 
							   withObjects:[NSArray arrayWithObjects:self.objectController,object,theIndexPath,nil]];
}

- (void)objectController:(id)controller removeObject:(id)object atIndexPath:(NSIndexPath*)indexPath{
	if(_sectionUpdate || self.hidden || self.collapsed){
		return;
	}
	
	int headerCount = [_headerCellControllers count];
	NSIndexPath* theIndexPath = [NSIndexPath indexPathForRow:(indexPath.row + headerCount) inSection:self.sectionVisibleIndex];
	[self.parentController performSelector:@selector(objectController:removeObject:atIndexPath:) 
                               withObjects:[NSArray arrayWithObjects:self.objectController,object,theIndexPath,nil]];
}


- (void)objectController:(id)controller insertObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths{
	if(_sectionUpdate || self.hidden || self.collapsed){
		return;
	}
	int headerCount = [_headerCellControllers count];
	NSMutableArray* newIndexPaths = [NSMutableArray array];
	for(int i=0;i<[indexPaths count];++i){
		NSIndexPath* indexPath = [indexPaths objectAtIndex:i];
		NSIndexPath* newIndexPath = [NSIndexPath indexPathForRow:indexPath.row + headerCount inSection:self.sectionVisibleIndex];
		[newIndexPaths addObject:newIndexPath];
	}
	[self.parentController performSelector:@selector(objectController:insertObjects:atIndexPaths:) 
							   withObjects:[NSArray arrayWithObjects:self.objectController,objects,newIndexPaths,nil]];
}

- (void)objectController:(id)controller removeObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths{
	if(_sectionUpdate || self.hidden || self.collapsed){
		return;
	}
	int headerCount = [_headerCellControllers count];
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


- (void)addFooterCellController:(CKTableViewCellController*)cellController{
	int headerCount = [_headerCellControllers count];
	int count = [_objectController numberOfObjectsForSection:0];
	int footerCount = [_footerCellControllers count];
	int index = headerCount + count + footerCount;
	
	[self.footerCellControllers addObject:cellController];
	
	if(![self.parentController reloading] && !self.collapsed){
		[self objectControllerDidBeginUpdating:self.objectController];
		[self objectController:self.objectController insertObject:cellController.value atIndexPath:[NSIndexPath indexPathForRow:index inSection:self.sectionVisibleIndex]];
		[self objectControllerDidEndUpdating:self.objectController];
	}
}

- (void)addHeaderCellController:(CKTableViewCellController*)cellController{
	int headerCount = [_headerCellControllers count];
	int index = headerCount;
	
	[self.headerCellControllers addObject:cellController];
	
	if(![self.parentController reloading] && !self.collapsed){
		[self objectControllerDidBeginUpdating:self.objectController];
		[self objectController:self.objectController insertObject:cellController.value atIndexPath:[NSIndexPath indexPathForRow:index inSection:self.sectionVisibleIndex]];
		[self objectControllerDidEndUpdating:self.objectController];
	}
}

- (void)removeFooterCellController:(CKTableViewCellController*)cellController{
    NSInteger footerIndex = [_footerCellControllers indexOfObjectIdenticalTo:cellController];
    NSAssert(footerIndex != NSNotFound,@"cannot find %@",cellController);
    
    int headerCount = [_headerCellControllers count];
	int count = [_objectController numberOfObjectsForSection:0];
	int index = headerCount + count + footerIndex;
	
    [cellController retain];
	[self.footerCellControllers removeObjectAtIndex:footerIndex];
	
	if(![self.parentController reloading] && !self.collapsed){
		[self objectControllerDidBeginUpdating:self.objectController];
		[self objectController:self.objectController removeObject:cellController.value atIndexPath:[NSIndexPath indexPathForRow:index inSection:self.sectionVisibleIndex]];
		[self objectControllerDidEndUpdating:self.objectController];
	}
    [cellController autorelease];
}

- (void)removeHeaderCellController:(CKTableViewCellController*)cellController{
    NSInteger headerIndex = [_headerCellControllers indexOfObjectIdenticalTo:cellController];
	int index = headerIndex;
	
    [cellController retain];
	[self.headerCellControllers removeObjectAtIndex:headerIndex];
	
	if(![self.parentController reloading] && !self.collapsed){
		[self objectControllerDidBeginUpdating:self.objectController];
		[self objectController:self.objectController removeObject:cellController.value atIndexPath:[NSIndexPath indexPathForRow:index inSection:self.sectionVisibleIndex]];
		[self objectControllerDidEndUpdating:self.objectController];
	}
    [cellController autorelease];
}

- (id)initWithCollection:(CKCollection*)collection factory:(CKCollectionCellControllerFactory*)factory{
    if (self = [super init]) {
        self.objectController = [CKCollectionController controllerWithCollection:collection];
        self.controllerFactory = factory;
        
        if([_controllerFactory respondsToSelector:@selector(setObjectController:)]){
            [_controllerFactory performSelector:@selector(setObjectController:) withObject:_objectController];
        }
        
        if(self.parentController.autoHideSections && (collection.count <= 0)) {
            self.hidden = YES;
        }
        
        _sectionUpdate = NO;
        
        self.headerCellControllers = [NSMutableArray array];
        self.footerCellControllers = [NSMutableArray array];
    }
	
	return self;
}

+ (CKFormBindedCollectionSection*)sectionWithCollection:(CKCollection*)collection factory:(CKCollectionCellControllerFactory*)factory{
	CKFormBindedCollectionSection* section = [[[CKFormBindedCollectionSection alloc]initWithCollection:collection factory:factory]autorelease];
	return section;
}

+ (CKFormBindedCollectionSection*)sectionWithCollection:(CKCollection*)collection factory:(CKCollectionCellControllerFactory*)factory headerTitle:(NSString*)title{
	CKFormBindedCollectionSection* section = [[[CKFormBindedCollectionSection alloc]initWithCollection:collection factory:factory]autorelease];
	section.headerTitle = title;
	return section;
}

+ (CKFormBindedCollectionSection*)sectionWithCollection:(CKCollection*)collection factory:(CKCollectionCellControllerFactory*)factory appendSpinnerAsFooterCell:(BOOL)appendSpinnerAsFooterCell{
	CKFormBindedCollectionSection* section = [[[CKFormBindedCollectionSection alloc]initWithCollection:collection factory:factory]autorelease];
	section.objectController.appendSpinnerAsFooterCell = appendSpinnerAsFooterCell;
	return section;
}

+ (CKFormBindedCollectionSection*)sectionWithCollection:(CKCollection*)collection factory:(CKCollectionCellControllerFactory*)factory headerTitle:(NSString*)title appendSpinnerAsFooterCell:(BOOL)appendSpinnerAsFooterCell{
	CKFormBindedCollectionSection* section = [CKFormBindedCollectionSection sectionWithCollection:collection factory:factory appendSpinnerAsFooterCell:appendSpinnerAsFooterCell];
	section.headerTitle = title;
	return section;
}

@end