//
//  CKCollectionCellController+Style.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-27.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKCollectionCellController.h"


/** TODO
 */
extern NSString* CKStyleNoItemsMessage;

/** TODO
 */
extern NSString* CKStyleOneItemMessage;

/** TODO
 */
extern NSString* CKStyleManyItemsMessage;

/** TODO
 */
extern NSString* CKStyleIndicatorStyle;


/** TODO
 */
@interface NSMutableDictionary (CKCollectionCellControllerStyle)

- (NSString*)noItemsMessage;
- (NSString*)oneItemMessage;
- (NSString*)manyItemsMessage;
- (UIActivityIndicatorViewStyle)indicatorStyle;

@end

