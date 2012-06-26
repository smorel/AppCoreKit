//
//  CKCollectionTableViewCellController+Style.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-27.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKCollectionTableViewCellController.h"
#import "CKTableViewCellController.h"


/**
 */
extern NSString* CKStyleNoItemsMessage;

/**
 */
extern NSString* CKStyleOneItemMessage;

/**
 */
extern NSString* CKStyleManyItemsMessage;

/**
 */
extern NSString* CKStyleIndicatorStyle;


/**
 */
@interface NSMutableDictionary (CKCollectionTableViewCellControllerStyle)

- (NSString*)noItemsMessage;
- (NSString*)oneItemMessage;
- (NSString*)manyItemsMessage;
- (UIActivityIndicatorViewStyle)indicatorStyle;

@end

