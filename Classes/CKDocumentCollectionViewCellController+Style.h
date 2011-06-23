//
//  CKDocumentCollectionViewCellController+Style.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-27.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKDocumentCollectionCellController.h"

extern NSString* CKStyleNoItemsMessage;
extern NSString* CKStyleOneItemMessage;
extern NSString* CKStyleManyItemsMessage;
extern NSString* CKStyleIndicatorStyle;

@interface NSMutableDictionary (CKDocumentCollectionViewCellControllerStyle)

- (NSString*)noItemsMessage;
- (NSString*)oneItemMessage;
- (NSString*)manyItemsMessage;
- (UIActivityIndicatorViewStyle)indicatorStyle;

@end

