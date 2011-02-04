//
//  CKFeedSource.h
//  CloudKit
//
//  Created by Fred Brunel on 11-01-14.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKFeedSource : NSObject {
	id _delegate;
	NSMutableArray *_items;
	NSUInteger _currentIndex;
	NSUInteger _limit;
	BOOL _hasMore;
	BOOL _fetching;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain, readonly) NSArray *items;
@property (nonatomic, readonly) NSUInteger currentIndex;
@property (nonatomic, readwrite) NSUInteger limit;
@property (nonatomic, readonly) BOOL hasMore;
@property (nonatomic, readonly) BOOL isFetching;

- (BOOL)fetchNextItems:(NSUInteger)batchSize;
- (void)cancelFetch;
- (void)reset;

@end

//

@protocol CKFeedSourceDelegate

- (void)feedSource:(CKFeedSource *)feedSource didAddItems:(NSArray *)items range:(NSRange)range;
- (void)feedSource:(CKFeedSource *)feedSource didFailWithError:(NSError *)error;

@end
