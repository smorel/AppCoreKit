//
//  CKDocumentCollectionViewCellController+Style.h
//  CloudKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKDocumentCollectionCellController.h"


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
@interface NSMutableDictionary (CKDocumentCollectionViewCellControllerStyle)

- (NSString*)noItemsMessage;
- (NSString*)oneItemMessage;
- (NSString*)manyItemsMessage;
- (UIActivityIndicatorViewStyle)indicatorStyle;

@end

