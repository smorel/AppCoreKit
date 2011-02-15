//
//  CKFeedSource.h
//  CloudKit
//
//  Created by Fred Brunel on 11-01-14.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKModelObjectsProtocol.h"

@interface CKFeedSource : NSObject {
	id _delegate;
	NSUInteger _currentIndex;
	NSUInteger _limit;
	BOOL _hasMore;
	BOOL _fetching;
	
	//We can choose wheter to use an external model via this protocol or the items if the external model is not set
	id<CKModelObjectsProtocol> _externalModel;
	NSString* _externalModelKey;
	NSMutableArray *_items;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, readonly) NSUInteger currentIndex;
@property (nonatomic, readwrite) NSUInteger limit;
@property (nonatomic, readonly) BOOL hasMore;
@property (nonatomic, readonly) BOOL isFetching;

@property (nonatomic, retain, readonly) NSArray *items;
@property (nonatomic, retain, readonly) id<CKModelObjectsProtocol> externalModel;
@property (nonatomic, retain, readonly) NSString *externalModelKey;

- (id)initWithExternalModel:(id<CKModelObjectsProtocol>)model forKey:(NSString*)key;
- (void)registerAsModelObserver:(id)object;
- (void)unregisterAsModelObserver:(id)object;

- (BOOL)fetchNextItems:(NSUInteger)batchSize;
- (void)cancelFetch;
- (void)reset;

@end

//

@protocol CKFeedSourceDelegate

- (void)feedSource:(CKFeedSource *)feedSource didAddItems:(NSArray *)items range:(NSRange)range;
- (void)feedSource:(CKFeedSource *)feedSource didFailWithError:(NSError *)error;

@end
