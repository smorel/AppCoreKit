//
//  CKFeedController.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-03-16.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKObjectController.h"
#import "CKDocumentCollection.h"


/** TODO
 */
@interface CKDocumentCollectionController : NSObject<CKObjectController> {
	CKDocumentCollection* _collection;
	id _delegate;
	BOOL observing;
	BOOL animateFirstInsertion;
	BOOL displayFeedSourceCell;
	NSInteger numberOfFeedObjectsLimit;
	BOOL locked;
	BOOL changedWhileLocked;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) CKDocumentCollection* collection;

- (id)initWithCollection:(CKDocumentCollection*)collection;
+ (CKDocumentCollectionController*) controllerWithCollection:(CKDocumentCollection*)collection;

//FIXME : review those names ...
@property (nonatomic, assign) BOOL animateFirstInsertion;
@property (nonatomic, assign) BOOL displayFeedSourceCell;
@property (nonatomic, assign) NSInteger numberOfFeedObjectsLimit;

@end


/** 
 DEPRECATED_IN_CLOUDKIT_1.7
 @see CKDocumentCollectionController
 */
@interface CKDocumentController : CKDocumentCollectionController{}
@end