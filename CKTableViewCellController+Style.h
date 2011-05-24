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
extern NSString* CKStyleAccessoryImage;
extern NSString* CKStyleCellSize;
extern NSString* CKStyleCellFlags;

@interface NSMutableDictionary (CKTableViewCellControllerStyle)

- (UITableViewCellStyle)cellStyle;
- (UIImage*)accessoryImage;
- (CGSize)cellSize;
- (CKTableViewCellFlags)cellFlags;

@end

@interface CKTableViewCellController (CKStyle)

- (void)applyStyle:(NSMutableDictionary*)style forCell:(UITableViewCell*)cell;
- (NSMutableDictionary*)controllerStyle;
- (UIView*)parentControllerView;

@end

@interface UITableViewCell (CKStyle)

@end

@interface UITableViewCell (CKValueTransformer)
@end

@interface CKTableViewController (CKStyle)

@end
