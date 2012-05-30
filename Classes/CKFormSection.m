//
//  CKFormSection.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-11-28.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import "CKFormSection.h"
#import "CKFormSectionBase_private.h"
#import "CKFormTableViewController.h"
#import "CKObjectController.h"
#import "CKItemViewControllerFactory.h"
#import "CKNSObject+Invocation.h"
#import "CKStyleManager.h"
#import "CKUIView+Style.h"
#import "CKTableViewCellController+Style.h"
#import "CKTableViewCellController.h"

#import "CKDebug.h"

//CKFormSection

@interface CKFormSection()
@property (nonatomic,retain) NSArray* cellControllers;
@end

@implementation CKFormSection
@synthesize cellControllers = _cellControllers;

- (NSInteger)count{
    return [_cellControllers count];
}

- (id)initWithCellControllers:(NSArray*)theCellControllers headerTitle:(NSString*)title{
	if (self = [super init]) {
      	self.headerTitle = title;
        self.cellControllers = [NSMutableArray arrayWithArray:theCellControllers];
    }
	return self;
}

- (id)initWithCellControllers:(NSArray*)theCellControllers headerView:(UIView*)view{
	if (self = [super init]) {
      	self.headerView = view;
        self.cellControllers = [NSMutableArray arrayWithArray:theCellControllers];
    }
	return self;
}

- (id)initWithCellControllers:(NSArray*)theCellControllers{
	if (self = [super init]) {
      	self.headerTitle = @"";
        self.cellControllers = [NSMutableArray arrayWithArray:theCellControllers];
    }
	return self;
}

- (id)initWithCellControllers:(NSArray*)theCellControllers footerTitle:(NSString*)title{
    if (self = [super init]) {
      	self.footerTitle = title;
        self.cellControllers = [NSMutableArray arrayWithArray:theCellControllers];
    }
	return self;
}

- (id)initWithCellControllers:(NSArray*)theCellControllers footerView:(UIView*)view{
    if (self = [super init]) {
        self.footerView = view;
        self.cellControllers = [NSMutableArray arrayWithArray:theCellControllers];
    }
	return self;
}

+ (CKFormSection*)section{
	return [[[CKFormSection alloc]initWithCellControllers:nil headerTitle:@""]autorelease];
}

+ (CKFormSection*)sectionWithHeaderTitle:(NSString*)title{
	return [[[CKFormSection alloc]initWithCellControllers:nil headerTitle:title]autorelease];
}

+ (CKFormSection*)sectionWithHeaderView:(UIView*)view{
	return [[[CKFormSection alloc]initWithCellControllers:nil headerView:view]autorelease];
}

+ (CKFormSection*)sectionWithFooterTitle:(NSString*)title{
	return [[[CKFormSection alloc]initWithCellControllers:nil footerTitle:title]autorelease];
}

+ (CKFormSection*)sectionWithFooterView:(UIView*)view{
	return [[[CKFormSection alloc]initWithCellControllers:nil footerView:view]autorelease];
}

- (void)insertCellController:(CKTableViewCellController *)cellController atIndex:(NSUInteger)index{
	if(_cellControllers == nil){
		self.cellControllers = [NSMutableArray array];
	}
	[_cellControllers insertObject:cellController atIndex:index];
    
    if([self.parentController viewIsOnScreen] && !self.collapsed){
        [self.parentController performSelector:@selector(objectControllerDidBeginUpdating:) withObject:self];
        NSIndexPath* theIndexPath = [NSIndexPath indexPathForRow:index inSection:self.sectionVisibleIndex];
        [self.parentController performSelector:@selector(objectController:insertObject:atIndexPath:) 
                                   withObjects:[NSArray arrayWithObjects:self.parentController.objectController,cellController.value,theIndexPath,nil]];
        [self.parentController performSelector:@selector(objectControllerDidEndUpdating:) withObject:self];
    }
}

- (void)addCellController:(CKTableViewCellController *)cellController{
	if(_cellControllers == nil){
		self.cellControllers = [NSMutableArray array];
	}
	[_cellControllers addObject:cellController];
    
    if([self.parentController viewIsOnScreen] && !self.collapsed){
        [self.parentController performSelector:@selector(objectControllerDidBeginUpdating:) withObject:self];
        NSIndexPath* theIndexPath = [NSIndexPath indexPathForRow:[_cellControllers count] -1 inSection:self.sectionVisibleIndex];
        [self.parentController performSelector:@selector(objectController:insertObject:atIndexPath:) 
                                   withObjects:[NSArray arrayWithObjects:self.parentController.objectController,cellController.value,theIndexPath,nil]];
        [self.parentController performSelector:@selector(objectControllerDidEndUpdating:) withObject:self];
    }
}

- (void)removeCellControllerAtIndex:(NSUInteger)index{
    CKTableViewCellController* controller = [_cellControllers objectAtIndex:index];
    
	[_cellControllers removeObjectAtIndex:index];
    
    if([self.parentController viewIsOnScreen] && !self.collapsed){
        [self.parentController performSelector:@selector(objectControllerDidBeginUpdating:) withObject:self];
        NSIndexPath* theIndexPath = [NSIndexPath indexPathForRow:index inSection:self.sectionVisibleIndex];
        [self.parentController performSelector:@selector(objectController:removeObject:atIndexPath:) 
                                   withObjects:[NSArray arrayWithObjects:self.parentController.objectController,controller.value,theIndexPath,nil]];
        [self.parentController performSelector:@selector(objectControllerDidEndUpdating:) withObject:self];
    }
}

- (void)removeCellController:(CKTableViewCellController *)cellController{
    NSInteger index = [_cellControllers indexOfObjectIdenticalTo:cellController];
    NSAssert(index != NSNotFound,@"cannot find %@",cellController);
    [self removeCellControllerAtIndex:index];
}

+ (CKFormSection*)sectionWithCellControllers:(NSArray*)cellcontrollers{
	return [[[CKFormSection alloc]initWithCellControllers:cellcontrollers]autorelease];
}

+ (CKFormSection*)sectionWithCellControllers:(NSArray*)cellcontrollers headerTitle:(NSString*)title{
	return [[[CKFormSection alloc]initWithCellControllers:cellcontrollers headerTitle:title]autorelease];
}

+ (CKFormSection*)sectionWithCellControllers:(NSArray*)cellcontrollers headerView:(UIView*)view{
	return [[[CKFormSection alloc]initWithCellControllers:cellcontrollers headerView:view]autorelease];
}

+ (CKFormSection*)sectionWithCellControllers:(NSArray*)cellcontrollers footerTitle:(NSString*)title{
	return [[[CKFormSection alloc]initWithCellControllers:cellcontrollers footerTitle:title]autorelease];
}

+ (CKFormSection*)sectionWithCellControllers:(NSArray*)cellcontrollers footerView:(UIView*)view{
	return [[[CKFormSection alloc]initWithCellControllers:cellcontrollers footerView:view]autorelease];
}

- (NSInteger)numberOfObjects{
	return [_cellControllers count];
}

- (id)objectAtIndex:(NSInteger)index{
    if(index < [_cellControllers count]){
        CKTableViewCellController* controller = [_cellControllers objectAtIndex:index];
        id object =  controller.value;
        return object;
    }
    return nil;
}

- (id)controllerForObject:(id)object atIndex:(NSInteger)index{
    if([_cellControllers count] > index){
        CKTableViewCellController* controller = [_cellControllers objectAtIndex:index];
        return controller;
    }
    return nil; 
}


- (void)removeObjectAtIndex:(NSInteger)index{
	NSAssert(NO,@"NOT IMPLEMENTED");
}

@end