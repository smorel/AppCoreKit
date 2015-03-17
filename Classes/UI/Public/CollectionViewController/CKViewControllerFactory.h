//
//  CKViewControllerFactory.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-17.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKCollectionCellContentViewController.h"


// this will replace CKCollectionCellControllerFactory and create CKCollectionCellContentViewController instead of CKCollectionCellController
@interface CKViewControllerFactory : NSObject

+ (CKViewControllerFactory*)factory;

- (CKCollectionCellContentViewController*)controllerForObject:(id)object
                                                    indexPath:(NSIndexPath*)indexPath
                                          containerController:(UIViewController*)containerController;


- (void)registerFactoryForObjectOfClass:(Class)type
                                factory:(CKCollectionCellContentViewController*(^)(id object, NSIndexPath* indexPath))factory;

- (void)registerFactoryWithPredicate:(NSPredicate*)predicate
                                factory:(CKCollectionCellContentViewController*(^)(id object, NSIndexPath* indexPath))factory;

@end
