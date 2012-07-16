//
//  CKWebSource.h
//  CloudKit
//
//  Created by Fred Brunel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKWebRequest2.h"
#import "CKFeedSource.h"

extern NSString* const CKWebSourceErrorNotification;

@class CKWebSource;

typedef CKWebRequest2 *(^CKWebSourceRequestBlock)(NSRange range);
typedef id (^CKWebSourceTransformBlock)(id value);
typedef void (^CKWebSourceFailureBlock)(NSError *error);
typedef void (^CKWebSourceSuccessBlock)();
typedef void (^CKWebSourceStartBlock)(CKWebRequest2* request);


/** TODO
 */
@interface CKWebSource : CKFeedSource <CKWebRequestDelegate> {
	CKWebRequest2 *_request;
	NSUInteger _requestedBatchSize;
	CKWebSourceRequestBlock _requestBlock;
	CKWebSourceTransformBlock _transformBlock;
	CKWebSourceFailureBlock _failureBlock;
	CKWebSourceSuccessBlock _successBlock;
	CKWebSourceStartBlock _launchRequestBlock;
	
	id _webSourceDelegate;
}

@property (nonatomic, copy) CKWebSourceRequestBlock requestBlock;
@property (nonatomic, copy) CKWebSourceTransformBlock transformBlock;
@property (nonatomic, copy) CKWebSourceFailureBlock failureBlock;
@property (nonatomic, copy) CKWebSourceSuccessBlock successBlock;
@property (nonatomic, copy) CKWebSourceStartBlock launchRequestBlock;
@property (nonatomic, assign) id webSourceDelegate;


@end



/** TODO
 */
@protocol CKWebSourceDelegate

@required
- (CKWebRequest2*)webSource:(CKWebSource*)webSource requestForRange:(NSRange)range;
- (id)webSource:(CKWebSource*)webSource transform:(id)value;
- (id)webSourceDidSuccess:(CKWebSource*)webSource;

@optional
- (void)webSource:(CKWebSource*)webSource didFailWithError:(NSError*)error;

@end