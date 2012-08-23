//
//  CKFeedSource.h
//  AppCoreKit
//
//  Created by Fred Brunel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 */
@interface CKFeedSource : NSObject

///-----------------------------------
/// @name Creating FeedSource objects
///-----------------------------------

/**
 */
+ (id)feedSource;

///-----------------------------------
/// @name Managing the delegate
///-----------------------------------

/**
 */
@property (nonatomic, assign) id delegate;

///-----------------------------------
/// @name Accessing the feed source status
///-----------------------------------

/**
 */
@property (nonatomic, assign) BOOL hasMore;

/**
 */
@property (nonatomic, readonly) BOOL isFetching;

///-----------------------------------
/// @name Executing the Request
///-----------------------------------

/**
 */
- (BOOL)fetchRange:(NSRange)range;

/**
 */
- (void)cancelFetch;

/**
 */
- (void)reset;

/** Notifying the delegate for new fetched items.
 */
- (void)addItems:(NSArray *)theItems;

@end



/**
 */
@protocol CKFeedSourceDelegate
@optional

///-----------------------------------
/// @name Reacting to feed source events
///-----------------------------------

/**
 */
- (void)feedSource:(CKFeedSource *)feedSource didFetchItems:(NSArray *)items range:(NSRange)range;

/**
 */
- (void)feedSource:(CKFeedSource *)feedSource didFailWithError:(NSError *)error;

@end
