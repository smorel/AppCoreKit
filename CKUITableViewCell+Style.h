//
//  CKUITableViewCell+Style.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-20.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKUIView+Style.h"

extern NSString* CKStyleCellType;
extern NSString* CKStyleAccessoryType;

@interface NSDictionary (CKUITableViewCellStyle)

- (UITableViewCellStyle)cellStyle;
- (UITableViewCellAccessoryType)accessoryType;

@end

/* SUPPORTS :
 * #tableViewCell
 * #textLabel
 * #detailTextLabel
 * #imageView
 * #backgroundView
 * #selectedBackgroundView
 * CKStyleCellType
 * CKStyleAccessoryType
 */

@interface UITableViewCell (CKStyle)

- (void)applyStyle:(NSDictionary*)style atIndexPath:(NSIndexPath*)indexPath parentController:(id)parentController;

@end
