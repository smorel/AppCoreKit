//
//  CKTableViewCellController+Style.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-21.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKTableViewCellController.h"
#import "CKUIViewController+Style.h"


/** TODO
 */
extern NSString* CKStyleCellType;

/** TODO
 */
extern NSString* CKStyleAccessoryImage;

/** TODO
 */
extern NSString* CKStyleCellSize;

/** TODO
 */
extern NSString* CKStyleCellFlags;


/** TODO
 */
@interface NSMutableDictionary (CKTableViewCellControllerStyle)

- (CKTableViewCellStyle)cellStyle;
- (UIImage*)accessoryImage;
- (CGSize)cellSize;
- (CKItemViewFlags)cellFlags;

@end


/** TODO
 */
@interface CKTableViewCellController (CKStyle)
@end


/** TODO
 */
@interface UITableViewCell (CKStyle)
@end


/** TODO
 */
@interface CKTableViewController (CKStyle)
@end


/** TODO
 */
@interface CKItemViewController (CKStyle)

- (void)applyStyle:(NSMutableDictionary*)style forView:(UIView*)view;
- (NSMutableDictionary*)controllerStyle;
- (UIView*)parentControllerView;

@end