//
//  CKItemViewControllerFactory.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-03-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKItemViewControllerFactory.h"
#import "CKObjectController.h"
#import "CKCollectionCellController.h"
#import "CKCollection.h"
#import <objc/runtime.h>

#import "CKStyleManager.h"
#import "CKTableViewCellController+Style.h"

//Private interface
@interface CKItemViewController()
@property (nonatomic, copy, readwrite) NSIndexPath *indexPath;
@property (nonatomic, assign, readwrite) CKItemViewContainerController* containerController;
@end

@interface CKItemViewControllerFactoryItem() 
- (id)controllerForObject:(id)object atIndexPath:(NSIndexPath*)indexPath;
@end

/********************************* CKItemViewControllerFactoryItem *********************************
 */


@implementation CKItemViewControllerFactoryItem
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

+ (CKItemViewControllerFactoryItem*)itemForObjectWithPredicate:(NSPredicate*)predicate withControllerCreationBlock:(CKItemViewController*(^)(id object, NSIndexPath* indexPath))block{
    CKItemViewControllerFactoryItem* item = [[[CKItemViewControllerFactoryItem alloc]init]autorelease];
	item.controllerCreateBlock = block;
	item.predicate = predicate;
	return item;
}

+ (CKItemViewControllerFactoryItem*)itemForObjectOfClass:(Class)type withControllerCreationBlock:(CKItemViewController*(^)(id object, NSIndexPath* indexPath))block{
    return [CKItemViewControllerFactoryItem itemForObjectWithPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject isKindOfClass:type];
    }] withControllerCreationBlock:block];
}

@end


/********************************* CKItemViewControllerFactory *********************************
 */

@interface CKItemViewControllerFactory ()
@property (nonatomic, retain) NSMutableArray* items;
@property (nonatomic, assign) id objectController;

- (CKItemViewControllerFactoryItem*)factoryItemForObject:(id)object atIndexPath:(NSIndexPath*)indexPath;
- (id)controllerForObject:(id)object atIndexPath:(NSIndexPath*)indexPath;

@end


@implementation CKItemViewControllerFactory
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

+ (CKItemViewControllerFactory*)factory{
    return [[[CKItemViewControllerFactory alloc]init]autorelease];
}

- (void)setItems:(id)theItems{
	[_items release];
	_items = [theItems retain];
    
    [self addItemForObjectOfClass:[CKCollection class] withControllerCreationBlock:^CKItemViewController *(id object, NSIndexPath *indexPath) {
        return [CKCollectionCellController cellController]; 
    }];
}

- (BOOL)doesItem:(CKItemViewControllerFactoryItem*)item matchWithObject:(id)object{
    NSPredicate* predicate = item.predicate;
    return [predicate evaluateWithObject:object];
}

- (CKItemViewControllerFactoryItem*)factoryItemForObject:(id)object atIndexPath:(NSIndexPath*)indexPath{
	for(CKItemViewControllerFactoryItem* item in _items){
		if([self doesItem:item matchWithObject:object]){
			return item;
		}
	}
	return nil;
}


- (id)controllerForObject:(id)object atIndexPath:(NSIndexPath*)indexPath{
	CKItemViewControllerFactoryItem* item = [self factoryItemForObject:object atIndexPath:indexPath];
    if(!item){
        return nil;
    }
	
    return [item controllerForObject:object atIndexPath:indexPath];
}

- (CKItemViewControllerFactoryItem*)addItem:(CKItemViewControllerFactoryItem*)item{
    [self.items addObject:item];
	return item;
}

- (CKItemViewControllerFactoryItem*)addItemForObjectOfClass:(Class)type withControllerCreationBlock:(CKItemViewController*(^)(id object, NSIndexPath* indexPath))block{
    CKItemViewControllerFactoryItem* item = [CKItemViewControllerFactoryItem itemForObjectOfClass:type withControllerCreationBlock:block];
    [self.items addObject:item];
    return item;
}

- (CKItemViewControllerFactoryItem*)addItemForObjectWithPredicate:(NSPredicate*)predicate withControllerCreationBlock:(CKItemViewController*(^)(id object, NSIndexPath* indexPath))block{
    CKItemViewControllerFactoryItem* item = [CKItemViewControllerFactoryItem itemForObjectWithPredicate:predicate withControllerCreationBlock:block];
    [self.items addObject:item];
    return item;
}

@end