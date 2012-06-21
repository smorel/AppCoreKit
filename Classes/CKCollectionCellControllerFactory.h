//
//  CKCollectionCellControllerFactory.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-03-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKCollectionCellController.h"

/********************************* CKCollectionCellControllerFactoryItem *********************************/

typedef CKCollectionCellController*(^CKCollectionCellControllerCreationBlock)(id object, NSIndexPath* indexPath);

/** TODO
 */
@interface CKCollectionCellControllerFactoryItem : NSObject

@property(nonatomic,copy)   CKCollectionCellControllerCreationBlock controllerCreateBlock;
@property(nonatomic,retain) NSPredicate* predicate;

+ (CKCollectionCellControllerFactoryItem*)itemForObjectWithPredicate:(NSPredicate*)predicate 
                                   withControllerCreationBlock:(CKCollectionCellController*(^)(id object, NSIndexPath* indexPath))block;

+ (CKCollectionCellControllerFactoryItem*)itemForObjectOfClass:(Class)type 
                             withControllerCreationBlock:(CKCollectionCellController*(^)(id object, NSIndexPath* indexPath))block;

@end



/********************************* CKCollectionCellControllerFactory *********************************/

/** TODO
 */
@interface CKCollectionCellControllerFactory : NSObject {
}

+ (CKCollectionCellControllerFactory*)factory;

- (CKCollectionCellControllerFactoryItem*)addItem:(CKCollectionCellControllerFactoryItem*)item;

- (CKCollectionCellControllerFactoryItem*)addItemForObjectOfClass:(Class)type 
                                withControllerCreationBlock:(CKCollectionCellController*(^)(id object, NSIndexPath* indexPath))block;

- (CKCollectionCellControllerFactoryItem*)addItemForObjectWithPredicate:(NSPredicate*)predicate 
                                       withControllerCreationBlock:(CKCollectionCellController*(^)(id object, NSIndexPath* indexPath))block;


- (id)controllerForObject:(id)object atIndexPath:(NSIndexPath*)indexPath;

@end