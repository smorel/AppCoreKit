//
//  CKCollectionCellControllerFactory.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKCollectionCellController.h"

/********************************* CKCollectionCellControllerFactoryItem *********************************/

typedef CKCollectionCellController*(^CKCollectionCellControllerCreationBlock)(id object, NSIndexPath* indexPath);

/**
 */
@interface CKCollectionCellControllerFactoryItem : NSObject

///-----------------------------------
/// @name Creating initialized CKCollectionCellControllerFactoryItem objects
///-----------------------------------

/**
 */
+ (CKCollectionCellControllerFactoryItem*)itemForObjectWithPredicate:(NSPredicate*)predicate 
                                         withControllerCreationBlock:(CKCollectionCellController*(^)(id object, NSIndexPath* indexPath))block;

/**
 */
+ (CKCollectionCellControllerFactoryItem*)itemForObjectOfClass:(Class)type 
                                   withControllerCreationBlock:(CKCollectionCellController*(^)(id object, NSIndexPath* indexPath))block;
///-----------------------------------
/// @name Configuring the object
///-----------------------------------

/**
 */
@property(nonatomic,copy)   CKCollectionCellControllerCreationBlock controllerCreateBlock;

/**
 */
@property(nonatomic,retain) NSPredicate* predicate;


@end



/********************************* CKCollectionCellControllerFactory *********************************/

/**
 */
@interface CKCollectionCellControllerFactory : NSObject {
}

///-----------------------------------
/// @name Creating initialized CKCollectionCellControllerFactory objects
///-----------------------------------

/**
 */
+ (CKCollectionCellControllerFactory*)factory;

///-----------------------------------
/// @name Managing items
///-----------------------------------

/**
 */
- (CKCollectionCellControllerFactoryItem*)addItem:(CKCollectionCellControllerFactoryItem*)item;

/**
 */
- (CKCollectionCellControllerFactoryItem*)addItemForObjectOfClass:(Class)type 
                                withControllerCreationBlock:(CKCollectionCellController*(^)(id object, NSIndexPath* indexPath))block;

/**
 */
- (CKCollectionCellControllerFactoryItem*)addItemForObjectWithPredicate:(NSPredicate*)predicate 
                                       withControllerCreationBlock:(CKCollectionCellController*(^)(id object, NSIndexPath* indexPath))block;


///-----------------------------------
/// @name Creating CKCollectionCellController
///-----------------------------------

/**
 */
- (id)controllerForObject:(id)object atIndexPath:(NSIndexPath*)indexPath;

@end