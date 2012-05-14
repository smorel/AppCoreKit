//
//  CKItemViewControllerFactory.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-03-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKItemViewController.h"

/********************************* CKItemViewControllerFactoryItem *********************************/

typedef CKItemViewController*(^CKItemViewControllerCreationBlock)(id object, NSIndexPath* indexPath);

/** TODO
 */
@interface CKItemViewControllerFactoryItem : NSObject

@property(nonatomic,copy)   CKItemViewControllerCreationBlock controllerCreateBlock;
@property(nonatomic,retain) NSPredicate* predicate;

+ (CKItemViewControllerFactoryItem*)itemForObjectWithPredicate:(NSPredicate*)predicate 
                                   withControllerCreationBlock:(CKItemViewController*(^)(id object, NSIndexPath* indexPath))block;

+ (CKItemViewControllerFactoryItem*)itemForObjectOfClass:(Class)type 
                             withControllerCreationBlock:(CKItemViewController*(^)(id object, NSIndexPath* indexPath))block;

@end



/********************************* CKItemViewControllerFactory *********************************/

/** TODO
 */
@interface CKItemViewControllerFactory : NSObject {
}

+ (CKItemViewControllerFactory*)factory;

- (CKItemViewControllerFactoryItem*)addItem:(CKItemViewControllerFactoryItem*)item;

- (CKItemViewControllerFactoryItem*)addItemForObjectOfClass:(Class)type 
                                withControllerCreationBlock:(CKItemViewController*(^)(id object, NSIndexPath* indexPath))block;

- (CKItemViewControllerFactoryItem*)addItemForObjectWithPredicate:(NSPredicate*)predicate 
                                       withControllerCreationBlock:(CKItemViewController*(^)(id object, NSIndexPath* indexPath))block;


- (id)controllerForObject:(id)object atIndexPath:(NSIndexPath*)indexPath;

@end