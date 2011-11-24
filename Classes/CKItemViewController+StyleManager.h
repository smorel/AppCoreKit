//
//  CKTableViewCellController+StyleManager.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-05-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKItemViewController.h"
#import "CKItemViewControllerFactory.h"


/** TODO : This is used only in CKItemViewControllerFactory to create static view controllers to compute sizes dynamically.
 */
@interface CKItemViewController (CKStyleManager)
+ (CKItemViewController*)controllerForClass:(Class)theClass object:(id)object indexPath:(NSIndexPath*)indexPath parentController:(id)parentController;
+ (CKItemViewController*)controllerForItem:(CKItemViewControllerFactoryItem*)item object:(id)object indexPath:(NSIndexPath*)indexPath parentController:(id)parentController;
@end
