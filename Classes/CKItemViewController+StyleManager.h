//
//  CKTableViewCellController+StyleManager.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-05-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKItemViewController.h"
#import "CKObjectViewControllerFactory.h"


/** TODO
 */
@interface CKItemViewController (CKStyleManager)
+ (NSString*)identifierForItem:(CKObjectViewControllerFactoryItem*)item object:(id)object indexPath:(NSIndexPath*)indexPath parentController:(id)parentController;
+ (NSMutableDictionary*)styleForItem:(CKObjectViewControllerFactoryItem*)item object:(id)object indexPath:(NSIndexPath*)indexPath parentController:(id)parentController;
+ (CKItemViewController*)controllerForClass:(Class)theClass object:(id)object indexPath:(NSIndexPath*)indexPath parentController:(id)parentController;
+ (CKItemViewController*)controllerForItem:(CKObjectViewControllerFactoryItem*)item object:(id)object indexPath:(NSIndexPath*)indexPath parentController:(id)parentController;
@end
