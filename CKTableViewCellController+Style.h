//
//  CKTableViewCellController+Style.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-21.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKTableViewCellController.h"
#import "CKUIViewController+Style.h"

extern NSString* CKStyleCellType;
extern NSString* CKStyleAccessoryType;
extern NSString* CKStyleAccessoryImage;
extern NSString* CKStyleSelectionStyle;

@interface NSMutableDictionary (CKTableViewCellControllerStyle)

- (UITableViewCellStyle)cellStyle;
- (UITableViewCellAccessoryType)accessoryType;
- (UITableViewCellSelectionStyle)selectionStyle;
- (UIImage*)accessoryImage;

@end

@interface CKTableViewCellController (CKStyle)

- (void)applyStyle:(NSMutableDictionary*)style forCell:(UITableViewCell*)cell;
- (NSMutableDictionary*)controllerStyle;
- (UIView*)parentControllerView;

@end

@interface UITableViewCell (CKStyle)

@end
