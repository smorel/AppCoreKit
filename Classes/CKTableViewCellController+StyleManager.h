//
//  CKTableViewCellController+StyleManager.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-05-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKItemViewController.h"

@interface CKItemViewController (CKStyleManager)
+ (NSString*)identifierForClass:(Class)theClass object:(id)object indexPath:(NSIndexPath*)indexPath parentController:(id)parentController;
+ (NSMutableDictionary*)styleForClass:(Class)theClass object:(id)object indexPath:(NSIndexPath*)indexPath parentController:(id)parentController;
+ (CKItemViewController*)controllerForClass:(Class)theClass object:(id)object indexPath:(NSIndexPath*)indexPath parentController:(id)parentController;
@end
