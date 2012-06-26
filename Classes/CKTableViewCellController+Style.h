//
//  CKTableViewCellController+Style.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-21.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKTableViewCellController.h"
#import "CKTableViewController.h"
#import "CKViewController+Style.h"


/**
 */
extern NSString* CKStyleCellStyle;

/**
 */
extern NSString* CKStyleAccessoryImage;

/**
 */
extern NSString* CKStyleCellSize;

/**
 */
extern NSString* CKStyleCellFlags;



/**
 */
@interface NSMutableDictionary (CKTableViewCellControllerStyle)

- (CKTableViewCellStyle)cellStyle;
- (UIImage*)accessoryImage;
- (CGSize)cellSize;
- (CKItemViewFlags)cellFlags;

@end


/**
 */
@interface CKTableViewCellController (CKStyle)

- (CKRoundedCornerViewType)view:(UIView*)view cornerStyleWithStyle:(NSMutableDictionary*)style;
- (CKStyleViewBorderLocation)view:(UIView*)view borderStyleWithStyle:(NSMutableDictionary*)style;
- (CKStyleViewSeparatorLocation)view:(UIView*)view separatorStyleWithStyle:(NSMutableDictionary*)style;

@end

/**
 */
@interface CKTableViewController (CKStyle)
@end


/**
 */
@interface CKCollectionCellController (CKStyle)

- (void)applyStyle:(NSMutableDictionary*)style forView:(UIView*)view;
- (NSMutableDictionary*)controllerStyle;
- (UIView*)parentControllerView;

@end


/**
 */
@interface UITableView (CKStyle)
@end