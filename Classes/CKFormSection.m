//
//  CKFormSection.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-11-28.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import "CKFormSection.h"
#import "CKFormTableViewController.h"
#import "CKObjectController.h"
#import "CKItemViewControllerFactory.h"
#import "CKNSObject+Invocation.h"
#import "CKStyleManager.h"
#import "CKUIView+Style.h"
#import "CKTableViewCellController+Style.h"

#import "CKDebug.h"

    //CKFormSection

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

- (id)initWithCellDescriptors:(NSArray*)theCellDescriptors footerTitle:(NSString*)title{
    [super init];
	self.footerTitle = title;
	self.cellDescriptors = [NSMutableArray arrayWithArray:theCellDescriptors];
	return self;
}

- (id)initWithCellDescriptors:(NSArray*)theCellDescriptors footerView:(UIView*)view{
    [super init];
	self.footerView = view;
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

+ (CKFormSection*)sectionWithFooterTitle:(NSString*)title{
	return [[[CKFormSection alloc]initWithCellDescriptors:nil footerTitle:title]autorelease];
}

+ (CKFormSection*)sectionWithFooterView:(UIView*)view{
	return [[[CKFormSection alloc]initWithCellDescriptors:nil footerView:view]autorelease];
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

+ (CKFormSection*)sectionWithCellDescriptors:(NSArray*)cellDescriptors footerTitle:(NSString*)title{
	return [[[CKFormSection alloc]initWithCellDescriptors:cellDescriptors footerTitle:title]autorelease];
}

+ (CKFormSection*)sectionWithCellDescriptors:(NSArray*)cellDescriptors footerView:(UIView*)view{
	return [[[CKFormSection alloc]initWithCellDescriptors:cellDescriptors footerView:view]autorelease];
}

- (CKFormCellDescriptor*)insertCellDescriptor:(CKFormCellDescriptor *)cellDescriptor atIndex:(NSUInteger)index{
	if(_cellDescriptors == nil){
		self.cellDescriptors = [NSMutableArray array];
	}
	[_cellDescriptors insertObject:cellDescriptor atIndex:index];
    
    if([self.parentController viewIsOnScreen]){
        [self.parentController performSelector:@selector(objectControllerDidBeginUpdating:) withObject:self];
        NSIndexPath* theIndexPath = [NSIndexPath indexPathForRow:index inSection:self.sectionVisibleIndex];
        [self.parentController performSelector:@selector(objectController:insertObject:atIndexPath:) 
                                   withObjects:[NSArray arrayWithObjects:self.parentController.objectController,cellDescriptor.value,theIndexPath,nil]];
        [self.parentController performSelector:@selector(objectControllerDidEndUpdating:) withObject:self];
    }
    
	return cellDescriptor;
}

- (CKFormCellDescriptor*)addCellDescriptor:(CKFormCellDescriptor *)cellDescriptor{
	if(_cellDescriptors == nil){
		self.cellDescriptors = [NSMutableArray array];
	}
	[_cellDescriptors addObject:cellDescriptor];
    
    if([self.parentController viewIsOnScreen]){
        [self.parentController performSelector:@selector(objectControllerDidBeginUpdating:) withObject:self];
        NSIndexPath* theIndexPath = [NSIndexPath indexPathForRow:[_cellDescriptors count] -1 inSection:self.sectionVisibleIndex];
        [self.parentController performSelector:@selector(objectController:insertObject:atIndexPath:) 
                                   withObjects:[NSArray arrayWithObjects:self.parentController.objectController,cellDescriptor.value,theIndexPath,nil]];
        [self.parentController performSelector:@selector(objectControllerDidEndUpdating:) withObject:self];
    }
    
	return cellDescriptor;
}

- (void)removeCellDescriptorAtIndex:(NSUInteger)index{
    CKFormCellDescriptor* descriptor = [_cellDescriptors objectAtIndex:index];
    
	[_cellDescriptors removeObjectAtIndex:index];
    
    if([self.parentController viewIsOnScreen]){
        [self.parentController performSelector:@selector(objectControllerDidBeginUpdating:) withObject:self];
        NSIndexPath* theIndexPath = [NSIndexPath indexPathForRow:index inSection:self.sectionVisibleIndex];
        [self.parentController performSelector:@selector(objectController:removeObject:atIndexPath:) 
                                   withObjects:[NSArray arrayWithObjects:self.parentController.objectController,descriptor.value,theIndexPath,nil]];
        [self.parentController performSelector:@selector(objectControllerDidEndUpdating:) withObject:self];
    }
}

- (void)removeCellDescriptor:(CKFormCellDescriptor *)descriptor{
    NSInteger index = [_cellDescriptors indexOfObjectIdenticalTo:descriptor];
    NSAssert(index != NSNotFound,@"cannot find %@",descriptor);
    [self removeCellDescriptorAtIndex:index];
}

- (NSInteger)numberOfObjects{
	return [_cellDescriptors count];
}

- (id)objectAtIndex:(NSInteger)index{
    if(index < [_cellDescriptors count]){
        CKFormCellDescriptor* cellDescriptor = [_cellDescriptors objectAtIndex:index];
        id object =  cellDescriptor.value;
        return object;
    }
    return nil;
}

- (CKItemViewControllerFactoryItem*)factoryItemForIndex:(NSInteger)index{
    if([_cellDescriptors count] > index){
        CKFormCellDescriptor* cellDescriptor = [_cellDescriptors objectAtIndex:index];
        return (CKItemViewControllerFactoryItem*)cellDescriptor;
    }
    return nil;
}

- (void)updateStyleForNonNewVisibleCells{
        //Update style for indexpath that have not been applyed
	NSInteger sectionIndex = [self sectionVisibleIndex];
	
	NSArray *visibleIndexPaths = [self.parentController visibleIndexPaths];
	for (NSIndexPath *indexPath in visibleIndexPaths) {
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