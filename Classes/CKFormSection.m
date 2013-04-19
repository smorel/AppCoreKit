//
//  CKFormSection.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import "CKFormSection.h"
#import "CKFormSectionBase_private.h"
#import "CKFormTableViewController.h"
#import "CKObjectController.h"
#import "CKCollectionCellControllerFactory.h"
#import "NSObject+Invocation.h"
#import "CKStyleManager.h"
#import "UIView+Style.h"
#import "CKTableViewCellController+Style.h"
#import "CKTableViewCellController.h"

#import "CKDebug.h"

@interface CKCollectionViewController()

@property (nonatomic, retain) NSMutableDictionary* viewsToControllers;
@property (nonatomic, retain) NSMutableDictionary* viewsToIndexPath;
@property (nonatomic, retain) NSMutableDictionary* indexPathToViews;
@property (nonatomic, retain) NSMutableArray* weakViews;
@property (nonatomic, retain) NSMutableArray* sectionsToControllers;

@property (nonatomic, retain) id objectController;
@property (nonatomic, retain) CKCollectionCellControllerFactory* controllerFactory;

- (void)updateVisibleViewsIndexPath;
- (void)updateVisibleViewsRotation;
- (void)updateViewsVisibility:(BOOL)visible;

@end

//CKFormSection

@interface CKFormSection()
@property (nonatomic,retain,readwrite) NSArray* cellControllers;
@end

@implementation CKFormSection{
	NSMutableArray* _cellControllers;
}

@synthesize cellControllers = _cellControllers;

- (void)dealloc{
    [super dealloc];
    [_cellControllers release];
    _cellControllers = nil;
}

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

- (void)insertCellControllers:(NSArray *)controllers atIndexes:(NSIndexSet*)indexes{
    if(_cellControllers == nil){
		self.cellControllers = [NSMutableArray array];
	}
	[_cellControllers insertObjects:controllers atIndexes:indexes];
    
    if(self.parentController.state != CKViewControllerStateNone && self.parentController.state != CKViewControllerStateDidLoad && !self.collapsed){
        [self.parentController performSelector:@selector(objectControllerDidBeginUpdating:) withObject:self];
        
        NSMutableArray* objects = [NSMutableArray array];
        for(CKTableViewCellController* cellController in controllers){
            [objects addObject:cellController.value ? cellController.value : [NSNull null]];
        }
        
        NSMutableArray* indexPaths = [NSMutableArray array];
        unsigned currentIndex = [indexes firstIndex];
        while (currentIndex != NSNotFound) {
            NSIndexPath* theIndexPath = [NSIndexPath indexPathForRow:currentIndex inSection:self.sectionVisibleIndex];
            [indexPaths addObject:theIndexPath];
            currentIndex = [indexes indexGreaterThanIndex: currentIndex];
        }
        
        [self.parentController performSelector:@selector(objectController:insertObjects:atIndexPaths:)
                                   withObjects:[NSArray arrayWithObjects:self.parentController.objectController,objects,indexPaths,nil]];
        [self.parentController performSelector:@selector(objectControllerDidEndUpdating:) withObject:self];
    }
}

- (void)insertCellController:(CKTableViewCellController *)cellController atIndex:(NSUInteger)index{
	[self insertCellControllers:[NSArray arrayWithObject:cellController] atIndexes:[NSIndexSet indexSetWithIndex:index]];
}

- (void)addCellController:(CKTableViewCellController *)cellController{
	if(_cellControllers == nil){
		self.cellControllers = [NSMutableArray array];
	}
	[_cellControllers addObject:cellController];
    
    if(self.parentController.state != CKViewControllerStateNone && self.parentController.state != CKViewControllerStateDidLoad && !self.collapsed){
        [self.parentController performSelector:@selector(objectControllerDidBeginUpdating:) withObject:self];
        NSIndexPath* theIndexPath = [NSIndexPath indexPathForRow:[_cellControllers count] -1 inSection:self.sectionVisibleIndex];
        [self.parentController performSelector:@selector(objectController:insertObject:atIndexPath:) 
                                   withObjects:[NSArray arrayWithObjects:self.parentController.objectController,cellController.value ? cellController.value : [NSNull null],theIndexPath,nil]];
        [self.parentController performSelector:@selector(objectControllerDidEndUpdating:) withObject:self];
    }
}



- (void)removeCellControllersAtIndexes:(NSIndexSet*)indexes{
    
    if(self.parentController.state != CKViewControllerStateNone && self.parentController.state != CKViewControllerStateDidLoad && !self.collapsed){
        [self.parentController performSelector:@selector(objectControllerDidBeginUpdating:) withObject:self];
        
        NSMutableArray* objects = [NSMutableArray array];
        NSMutableArray* indexPaths = [NSMutableArray array];
        unsigned currentIndex = [indexes firstIndex];
        while (currentIndex != NSNotFound) {
            CKTableViewCellController* cellController = [_cellControllers objectAtIndex:currentIndex];
            [objects addObject:cellController.value ? cellController.value : [NSNull null]];
            
            NSIndexPath* theIndexPath = [NSIndexPath indexPathForRow:currentIndex inSection:self.sectionVisibleIndex];
            [indexPaths addObject:theIndexPath];
            currentIndex = [indexes indexGreaterThanIndex: currentIndex];
        }
        
        [_cellControllers removeObjectsAtIndexes:indexes];
        
        [self.parentController performSelector:@selector(objectController:removeObjects:atIndexPaths:)
                                   withObjects:[NSArray arrayWithObjects:self.parentController.objectController,objects,indexPaths,nil]];
        
        [self.parentController performSelector:@selector(objectControllerDidEndUpdating:) withObject:self];
    }else{
        [_cellControllers removeObjectsAtIndexes:indexes];
    }
}

- (void)removeCellControllerAtIndex:(NSUInteger)index{
    [self removeCellControllersAtIndexes:[NSIndexSet indexSetWithIndex:index]];
}


- (void)removeCellControllers:(NSArray *)controllers{
    NSMutableIndexSet* indexes = [NSMutableIndexSet indexSet];
    for(CKTableViewCellController* cellController in controllers){
        NSInteger index = [_cellControllers indexOfObjectIdenticalTo:cellController];
        [indexes addIndex:index];
    }
    [self removeCellControllersAtIndexes:indexes];
}

- (void)removeCellController:(CKTableViewCellController *)cellController{
    NSInteger index = [_cellControllers indexOfObjectIdenticalTo:cellController];
    CKAssert(index != NSNotFound,@"cannot find %@",cellController);
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
	CKAssert(NO,@"NOT IMPLEMENTED");
}

@end