//
//  CKCollectionCellControllerFactory.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKCollectionCellControllerFactory.h"
#import "CKObjectController.h"
#import "CKCollectionTableViewCellController.h"
#import "CKCollection.h"
#import <objc/runtime.h>

#import "CKStyleManager.h"
#import "CKTableViewCellController+Style.h"

//Private interface
@interface CKCollectionCellController()
@property (nonatomic, copy, readwrite) NSIndexPath *indexPath;
@property (nonatomic, assign, readwrite) CKCollectionViewController* containerController;
@end

@interface CKCollectionCellControllerFactoryItem() 
- (id)controllerForObject:(id)object atIndexPath:(NSIndexPath*)indexPath;
@end

/********************************* CKCollectionCellControllerFactoryItem *********************************
 */


@implementation CKCollectionCellControllerFactoryItem
@synthesize predicate = _predicate;
@synthesize controllerCreateBlock = _controllerCreateBlock;


- (void)dealloc{
	[_predicate release];
	_predicate = nil;
	[_controllerCreateBlock release];
	_controllerCreateBlock = nil;
	[super dealloc];
}

- (id)controllerForObject:(id)object atIndexPath:(NSIndexPath*)indexPath{
    if(_controllerCreateBlock){
        return _controllerCreateBlock(object,indexPath);
    }
   	return nil;
}

+ (CKCollectionCellControllerFactoryItem*)itemForObjectWithPredicate:(NSPredicate*)predicate withControllerCreationBlock:(CKCollectionCellController*(^)(id object, NSIndexPath* indexPath))block{
    CKCollectionCellControllerFactoryItem* item = [[[CKCollectionCellControllerFactoryItem alloc]init]autorelease];
	item.controllerCreateBlock = block;
	item.predicate = predicate;
	return item;
}

+ (CKCollectionCellControllerFactoryItem*)itemForObjectOfClass:(Class)type withControllerCreationBlock:(CKCollectionCellController*(^)(id object, NSIndexPath* indexPath))block{
    return [CKCollectionCellControllerFactoryItem itemForObjectWithPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject isKindOfClass:type];
    }] withControllerCreationBlock:block];
}

@end


/********************************* CKCollectionCellControllerFactory *********************************
 */

@interface CKCollectionCellControllerFactory ()
@property (nonatomic, retain) NSMutableArray* items;
@property (nonatomic, assign) id objectController;

- (CKCollectionCellControllerFactoryItem*)factoryItemForObject:(id)object atIndexPath:(NSIndexPath*)indexPath;
- (id)controllerForObject:(id)object atIndexPath:(NSIndexPath*)indexPath;

@end


@implementation CKCollectionCellControllerFactory
@synthesize items = _items;
@synthesize objectController;

- (void)dealloc{
	[_items release];
	_items = nil;
	[super dealloc];
}

- (id)init{
    self = [super init];
    self.items = [NSMutableArray array];
    return self;
}

+ (CKCollectionCellControllerFactory*)factory{
    return [[[CKCollectionCellControllerFactory alloc]init]autorelease];
}

- (void)setItems:(id)theItems{
	[_items release];
	_items = [theItems retain];
    
    [self addItemForObjectOfClass:[CKCollection class] withControllerCreationBlock:^CKCollectionCellController *(id object, NSIndexPath *indexPath) {
        return [CKCollectionTableViewCellController cellController]; 
    }];
}

- (BOOL)doesItem:(CKCollectionCellControllerFactoryItem*)item matchWithObject:(id)object{
    NSPredicate* predicate = item.predicate;
    return [predicate evaluateWithObject:object];
}

- (CKCollectionCellControllerFactoryItem*)factoryItemForObject:(id)object atIndexPath:(NSIndexPath*)indexPath{
	for(CKCollectionCellControllerFactoryItem* item in _items){
		if([self doesItem:item matchWithObject:object]){
			return item;
		}
	}
	return nil;
}


- (id)controllerForObject:(id)object atIndexPath:(NSIndexPath*)indexPath{
	CKCollectionCellControllerFactoryItem* item = [self factoryItemForObject:object atIndexPath:indexPath];
    if(!item){
        return nil;
    }
	
    return [item controllerForObject:object atIndexPath:indexPath];
}

- (CKCollectionCellControllerFactoryItem*)addItem:(CKCollectionCellControllerFactoryItem*)item{
    [self.items addObject:item];
	return item;
}

- (CKCollectionCellControllerFactoryItem*)addItemForObjectOfClass:(Class)type withControllerCreationBlock:(CKCollectionCellController*(^)(id object, NSIndexPath* indexPath))block{
    CKCollectionCellControllerFactoryItem* item = [CKCollectionCellControllerFactoryItem itemForObjectOfClass:type withControllerCreationBlock:block];
    [self.items addObject:item];
    return item;
}

- (CKCollectionCellControllerFactoryItem*)addItemForObjectWithPredicate:(NSPredicate*)predicate withControllerCreationBlock:(CKCollectionCellController*(^)(id object, NSIndexPath* indexPath))block{
    CKCollectionCellControllerFactoryItem* item = [CKCollectionCellControllerFactoryItem itemForObjectWithPredicate:predicate withControllerCreationBlock:block];
    [self.items addObject:item];
    return item;
}

@end