//
//  CKReusableViewControllerFactory.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-17.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKReusableViewController.h"


// this will replace CKCollectionCellControllerFactory and create CKReusableViewController instead of CKCollectionCellController
@interface CKReusableViewControllerFactory : NSObject

+ (CKReusableViewControllerFactory*)factory;

- (CKReusableViewController*)controllerForObject:(id)object
                                                    indexPath:(NSIndexPath*)indexPath
                                          containerController:(UIViewController*)containerController;


- (void)registerFactoryForObjectOfClass:(Class)type
                                factory:(CKReusableViewController*(^)(id object, NSIndexPath* indexPath))factory;

- (void)registerFactoryWithPredicate:(NSPredicate*)predicate
                                factory:(CKReusableViewController*(^)(id object, NSIndexPath* indexPath))factory;

@end
