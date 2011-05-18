//
//  CKTableViewCellController+StyleManager.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-05-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKTableViewCellController.h"

@interface CKTableViewCellController (CKStyleManager)
+ (NSString*)identifierForClass:(Class)theClass object:(id)object indexPath:(NSIndexPath*)indexPath parentController:(id)parentController;
+ (NSMutableDictionary*)styleForClass:(Class)theClass object:(id)object indexPath:(NSIndexPath*)indexPath parentController:(id)parentController;
+ (CKTableViewCellController*)controllerForClass:(Class)theClass object:(id)object indexPath:(NSIndexPath*)indexPath parentController:(id)parentController;
@end
