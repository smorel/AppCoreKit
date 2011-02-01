//
//  CKWebSource.h
//  CloudKit
//
//  Created by Fred Brunel on 11-01-14.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CloudKit/CKWebRequest2.h>
#import "CKFeedSource.h"

@class CKWebSource;

typedef CKWebRequest2 *(^CKWebSourceRequestBlock)(NSRange range);
typedef id (^CKWebSourceTransformBlock)(id value);

@interface CKWebSource : CKFeedSource <CKWebRequestDelegate> {
	CKWebRequest2 *_request;
	NSUInteger _requestedBatchSize;
	CKWebSourceRequestBlock _requestBlock;
	CKWebSourceTransformBlock _transformBlock;
}

@property (nonatomic, retain) CKWebSourceRequestBlock requestBlock;
@property (nonatomic, retain) CKWebSourceTransformBlock transformBlock;

@end
