//
//  CKItemViewControllerFactory.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-03-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKNSDictionary+TableViewAttributes.h"
#import "CKItemViewController.h"
#import "CKItemViewControllerFactoryItem.h"


/********************************* CKItemViewControllerFactory *********************************
 */

/** TODO
 */
@interface CKItemViewControllerFactory : NSObject {
}

- (CKItemViewControllerFactoryItem*)addItem:(CKItemViewControllerFactoryItem*)item;

- (CKItemViewControllerFactoryItem*)addItemForObjectOfClass:(Class)type 
                                      withControllerOfClass:(Class)controllerClass;

- (CKItemViewControllerFactoryItem*)addItemForObjectOfClass:(Class)type 
                                withControllerCreationBlock:(CKItemViewController*(^)(id object, NSIndexPath* indexPath))block;

- (CKItemViewControllerFactoryItem*)addItemForObjectWithPredicate:(NSPredicate*)predicate 
                                             withControllerOfClass:(Class)controllerClass;

- (CKItemViewControllerFactoryItem*)addItemForObjectWithPredicate:(NSPredicate*)predicate 
                                       withControllerCreationBlock:(CKItemViewController*(^)(id object, NSIndexPath* indexPath))block;

@end


/********************************* DEPRECATED *********************************
 */


//DEPRECATED_IN_CLOUDKIT_VERSION_1_7_14_AND_LATER
@interface CKObjectViewControllerFactory : CKItemViewControllerFactory
@end

@interface CKItemViewControllerFactory(DEPRECATED_IN_CLOUDKIT_VERSION_1_7_14_AND_LATER)
//construction
+ (CKItemViewControllerFactory*)factoryWithMappings:(NSArray*)mappings DEPRECATED_ATTRIBUTE;
+ (id)factoryWithMappings:(NSArray*)mappings withFactoryClass:(Class)type DEPRECATED_ATTRIBUTE;
@end

@interface NSMutableArray (CKObjectViewControllerFactory_DEPRECATED_IN_CLOUDKIT_VERSION_1_7_14_AND_LATER)
- (CKItemViewControllerFactoryItem*)mapControllerClass:(Class)controllerClass withParams:(NSMutableDictionary*)params DEPRECATED_ATTRIBUTE;
- (CKItemViewControllerFactoryItem*)mapControllerClass:(Class)controllerClass withObjectClass:(Class)objectClass DEPRECATED_ATTRIBUTE;
@end