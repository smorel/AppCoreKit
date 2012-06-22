//
//  CKWebSource.h
//  CloudKit
//
//  Created by Fred Brunel on 11-01-14.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKWebRequest.h"
#import "CKFeedSource.h"

extern NSString* const CKWebSourceErrorNotification;

@class CKWebSource;

typedef CKWebRequest *(^CKWebSourceRequestBlock)(NSRange range);
typedef void (^CKWebSourceCompletionBlock)(id value, NSError *error);


/** TODO
 */
@interface CKWebSource : CKFeedSource 

///-----------------------------------
/// @name Customizing the WebSource Behaviour
///-----------------------------------

/**
 */
@property (nonatomic, copy) CKWebSourceRequestBlock requestBlock;

/**
 */
@property (nonatomic, copy) CKWebSourceCompletionBlock completionBlock;

///-----------------------------------
/// @name Managing the delegate
///-----------------------------------
/**
 */
@property (nonatomic, assign) id webSourceDelegate;


@end



/** TODO
 */
@protocol CKWebSourceDelegate

///-----------------------------------
/// @name Customizing the WebSource Behaviour
///-----------------------------------

@required
/**
 */
- (CKWebRequest*)webSource:(CKWebSource*)webSource requestForRange:(NSRange)range;

/**
 */
- (id)webSource:(CKWebSource*)webSource transform:(id)value;

/**
 */
- (id)webSourceDidSuccess:(CKWebSource*)webSource;

@optional

/**
 */
- (void)webSource:(CKWebSource*)webSource didFailWithError:(NSError*)error;

@end