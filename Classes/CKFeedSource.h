//
//  CKFeedSource.h
//  CloudKit
//
//  Created by Fred Brunel on 11-01-14.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/** TODO
 */
@interface CKFeedSource : NSObject {
	id _delegate;
	BOOL _hasMore;
	BOOL _isFetching;
	NSRange _range;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, readonly) BOOL hasMore;
@property (nonatomic, readonly) BOOL isFetching;

- (BOOL)fetchRange:(NSRange)range;
- (void)cancelFetch;
- (void)reset;

@end

//

/** TODO
 */
@protocol CKFeedSourceDelegate
@optional
- (void)feedSource:(CKFeedSource *)feedSource didFetchItems:(NSArray *)items range:(NSRange)range;
- (void)feedSource:(CKFeedSource *)feedSource didFailWithError:(NSError *)error;

@end
