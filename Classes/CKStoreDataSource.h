//
//  CKStoreDataSource.h
//  StoreTest
//
//  Created by Sebastien Morel on 11-06-02.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKFeedSource.h"
#import "CKStore.h"


@interface CKStoreRequest : NSOperation{
	CKStore*   _store;
	NSString* _predicateFormat;
	NSArray*  _predicateArguments;
	NSRange   _range;
	id        _delegate;
	NSArray*  _sortKeys;
	
	BOOL executing;
	BOOL finished;
	BOOL cancelled;	
}

@property (nonatomic, retain) CKStore*  store;
@property (nonatomic, retain) NSString* predicateFormat;
@property (nonatomic, retain) NSArray*  predicateArguments;
@property (nonatomic, retain) NSArray*  sortKeys;
@property (nonatomic, assign) NSRange   range;
@property (nonatomic, assign) id        delegate;

+ (CKStoreRequest*)requestWithPredicateFormat:(NSString*)format arguments:(NSArray*)arguments range:(NSRange)range sortKeys:(NSArray*)sortKeys store:(CKStore*)store;
- (id)initWithPredicateFormat:(NSString*)format arguments:(NSArray*)arguments range:(NSRange)range sortKeys:(NSArray*)sortKeys store:(CKStore*)store;
- (void)startAsynchronous;

@end


@protocol CKStoreRequestDelegate
- (void)request:(id)request didReceiveValue:(id)value;
- (void)request:(id)request didFailWithError:(NSError *)error;
@end




typedef CKStoreRequest *(^CKStoreDataSourceRequestBlock)(NSRange range);
typedef id (^CKStoreDataSourceTransformBlock)(id value);
typedef void (^CKStoreDataSourceFailureBlock)(NSError *error);
typedef void (^CKStoreDataSourceSuccessBlock)();

@interface CKStoreDataSource : CKFeedSource<CKStoreRequestDelegate> {
	CKStoreDataSourceRequestBlock _requestBlock;
	CKStoreDataSourceTransformBlock _transformBlock;
	CKStoreDataSourceFailureBlock _failureBlock;
	CKStoreDataSourceSuccessBlock _successBlock;
	id _storeDelegate;
	CKStoreRequest* _request;
	BOOL _executeInBackground;
}

+ (CKStoreDataSource*)dataSource;
+ (CKStoreDataSource*)synchronousDataSource;

@property (nonatomic, copy) CKStoreDataSourceRequestBlock requestBlock;
@property (nonatomic, copy) CKStoreDataSourceTransformBlock transformBlock;
@property (nonatomic, copy) CKStoreDataSourceFailureBlock failureBlock;
@property (nonatomic, copy) CKStoreDataSourceSuccessBlock successBlock;
@property (nonatomic, assign) id storeDelegate;
@property (nonatomic, assign) BOOL executeInBackground;

@end


@protocol CKStoreDataSourceDelegate

@required
- (CKStoreRequest*)storeSource:(CKStoreDataSource*)storeSource requestForRange:(NSRange)range;
- (id)storeSource:(CKStoreDataSource*)storeSource transform:(id)value;

@optional
- (void)storeSource:(CKStoreDataSource*)storeSource didFailWithError:(NSError*)error;

@end