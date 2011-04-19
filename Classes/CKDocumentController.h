//
//  CKFeedController.h
//  FeedView
//
//  Created by Sebastien Morel on 11-03-16.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKObjectController.h"
#import "CKDocumentCollection.h"


@interface CKDocumentController : NSObject<CKObjectController> {
	CKDocumentCollection* _collection;
	id _delegate;
	BOOL observing;
	BOOL animateFirstInsertion;
	BOOL displayFeedSourceCell;
	NSInteger numberOfFeedObjectsLimit;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) BOOL animateFirstInsertion;
@property (nonatomic, assign) BOOL displayFeedSourceCell;
@property (nonatomic, assign) NSInteger numberOfFeedObjectsLimit;
@property (nonatomic, retain) CKDocumentCollection* collection;

- (id)initWithCollection:(CKDocumentCollection*)collection;
+ (CKDocumentController*) controllerWithCollection:(CKDocumentCollection*)collection;

@end
