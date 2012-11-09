//
//  CKFeedSource.h
//  AppCoreKit
//
//  Created by Fred Brunel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CKFeedSource;
typedef void(^CKFeedSourceFetchBlock)(CKFeedSource* feedSource,NSRange range);

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

/** When you asynchronously get your results, calls addItems: on the feedSource to notify the delegate that new objects have been received
 */
@property(nonatomic,copy) CKFeedSourceFetchBlock fetchBlock;

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
