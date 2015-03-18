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

#import "CKTableViewControllerOld.h"
#import "CKTableViewContentCellController.h"

#import "CKCollectionViewLayoutController.h"
#import "CKCollectionContentCellController.h"

//Private interface
@interface CKCollectionCellController()
@property (nonatomic, copy, readwrite) NSIndexPath *indexPath;
@property (nonatomic, assign, readwrite) CKCollectionViewController* containerController;
@end

@interface CKCollectionCellControllerFactoryItem() 
- (id)controllerForObject:(id)object atIndexPath:(NSIndexPath*)indexPath collectionViewController:(CKCollectionViewController*)collectionViewController;
@end

/********************************* CKCollectionCellControllerFactoryItem *********************************
 */


@implementation CKCollectionCellControllerFactoryItem
@synthesize predicate = _predicate;
@synthesize controllerCreateBlock = _controllerCreateBlock;
@synthesize contentControllerCreateBlock = _contentControllerCreateBlock;


- (void)dealloc{
	[_predicate release];
	_predicate = nil;
	[_controllerCreateBlock release];
    _controllerCreateBlock = nil;
    [_contentControllerCreateBlock release];
    _contentControllerCreateBlock = nil;
	[super dealloc];
}

- (id)controllerForObject:(id)object atIndexPath:(NSIndexPath*)indexPath collectionViewController:(CKCollectionViewController*)collectionViewController{
    if(_controllerCreateBlock){
        CKCollectionCellController* controller = _controllerCreateBlock(object,indexPath);
        if(controller.name == nil){
            controller.name = [NSString stringWithFormat:@"<%p>",self];
        }
        return controller;
    }else if(_contentControllerCreateBlock){
        if([collectionViewController isKindOfClass:[CKTableViewControllerOld class]]){
            CKCollectionCellContentViewController* content = _contentControllerCreateBlock(object,indexPath);
            
            CKTableViewContentCellController* cellController = [[CKTableViewContentCellController alloc]initWithContentViewController:content];
            if(cellController.name == nil){
                cellController.name = [NSString stringWithFormat:@"<%p>",self];
            }
            return cellController;
        }else if([collectionViewController isKindOfClass:[CKCollectionViewLayoutController class]]){
            CKCollectionCellContentViewController* content = _contentControllerCreateBlock(object,indexPath);
            
            CKCollectionContentCellController* cellController = [[CKCollectionContentCellController alloc]initWithContentViewController:content];
            if(cellController.name == nil){
                cellController.name = [NSString stringWithFormat:@"<%p>",self];
            }
            return cellController;
        }else{
            NSAssert(NO,@"Unsupported method of creation for content cell controller with collection view controller fo type %@",[collectionViewController class]);
        }
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

+ (CKCollectionCellControllerFactoryItem*)itemForObjectWithPredicate:(NSPredicate*)predicate
                                  withContentControllerCreationBlock:(CKCollectionCellContentViewController*(^)(id object, NSIndexPath* indexPath))block{
    CKCollectionCellControllerFactoryItem* item = [[[CKCollectionCellControllerFactoryItem alloc]init]autorelease];
    item.contentControllerCreateBlock = block;
    item.predicate = predicate;
    return item;
}

+ (CKCollectionCellControllerFactoryItem*)itemForObjectOfClass:(Class)type
                            withContentControllerCreationBlock:(CKCollectionCellContentViewController*(^)(id object, NSIndexPath* indexPath))block{
    return [CKCollectionCellControllerFactoryItem itemForObjectWithPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject isKindOfClass:type];
    }] withContentControllerCreationBlock:block];
}

@end


/********************************* CKCollectionCellControllerFactory *********************************
 */

@interface CKCollectionCellControllerFactory ()
@property (nonatomic, retain) NSMutableArray* items;
@property (nonatomic, assign) id objectController;

- (CKCollectionCellControllerFactoryItem*)factoryItemForObject:(id)object atIndexPath:(NSIndexPath*)indexPath collectionViewController:(CKCollectionViewController *)collectionViewController;
- (id)controllerForObject:(id)object atIndexPath:(NSIndexPath*)indexPath collectionViewController:(CKCollectionViewController *)collectionViewController;

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

- (CKCollectionCellControllerFactoryItem*)factoryItemForObject:(id)object atIndexPath:(NSIndexPath*)indexPath collectionViewController:(CKCollectionViewController*)collectionViewController{
	for(CKCollectionCellControllerFactoryItem* item in _items){
		if([self doesItem:item matchWithObject:object]){
			return item;
		}
	}
	return nil;
}


- (id)controllerForObject:(id)object atIndexPath:(NSIndexPath*)indexPath collectionViewController:(CKCollectionViewController*)collectionViewController{
    CKCollectionCellControllerFactoryItem* item = [self factoryItemForObject:object atIndexPath:indexPath collectionViewController:collectionViewController];
    if(!item){
        return nil;
    }
	
    return [item controllerForObject:object atIndexPath:indexPath collectionViewController:collectionViewController];
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

- (CKCollectionCellControllerFactoryItem*)addItemForObjectOfClass:(Class)type
                               withContentControllerCreationBlock:(CKCollectionCellContentViewController*(^)(id object, NSIndexPath* indexPath))block{
    CKCollectionCellControllerFactoryItem* item = [CKCollectionCellControllerFactoryItem itemForObjectOfClass:type withContentControllerCreationBlock:block];
    [self.items addObject:item];
    return item;
}

- (CKCollectionCellControllerFactoryItem*)addItemForObjectWithPredicate:(NSPredicate*)predicate
                                     withContentControllerCreationBlock:(CKCollectionCellContentViewController*(^)(id object, NSIndexPath* indexPath))block{
    CKCollectionCellControllerFactoryItem* item = [CKCollectionCellControllerFactoryItem itemForObjectWithPredicate:predicate withContentControllerCreationBlock:block];
    [self.items addObject:item];
    return item;
}

@end