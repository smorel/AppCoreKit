//
//  CKViewControllerFactory.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-17.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKResusableViewController.h"


// this will replace CKCollectionCellControllerFactory and create CKResusableViewController instead of CKCollectionCellController
@interface CKViewControllerFactory : NSObject

+ (CKViewControllerFactory*)factory;

- (CKResusableViewController*)controllerForObject:(id)object
                                                    indexPath:(NSIndexPath*)indexPath
                                          containerController:(UIViewController*)containerController;


- (void)registerFactoryForObjectOfClass:(Class)type
                                factory:(CKResusableViewController*(^)(id object, NSIndexPath* indexPath))factory;

- (void)registerFactoryWithPredicate:(NSPredicate*)predicate
                                factory:(CKResusableViewController*(^)(id object, NSIndexPath* indexPath))factory;

@end
