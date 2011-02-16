//
//  CKFeedSource.h
//  CloudKit
//
//  Created by Fred Brunel on 11-01-14.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKDocument.h"

@interface CKFeedSource : NSObject {
	id _delegate;
	NSUInteger _currentIndex;
	NSUInteger _limit;
	BOOL _hasMore;
	BOOL _fetching;
	
	id<CKDocument> _document;
	NSString* _objectsKey;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, readonly) NSUInteger currentIndex;
@property (nonatomic, readwrite) NSUInteger limit;
@property (nonatomic, readonly) BOOL hasMore;
@property (nonatomic, readonly) BOOL isFetching;

@property (nonatomic, retain, readonly) NSArray *items;
@property (nonatomic, retain, readonly) id<CKDocument> document;
@property (nonatomic, retain, readonly) NSString *objectsKey;

- (id)initWithDocument:(id<CKDocument>)document forKey:(NSString*)key;
- (void)addObserver:(id)object;
- (void)removeObserver:(id)object;

- (BOOL)fetchNextItems:(NSUInteger)batchSize;
- (void)cancelFetch;
- (void)reset;

@end

//

@protocol CKFeedSourceDelegate

- (void)feedSource:(CKFeedSource *)feedSource didAddItems:(NSArray *)items range:(NSRange)range;
- (void)feedSource:(CKFeedSource *)feedSource didFailWithError:(NSError *)error;

@end
