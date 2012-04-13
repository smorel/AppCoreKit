//
//  CKCollectionController.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-03-16.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKObjectController.h"
#import "CKCollection.h"


/** TODO
 */
@interface CKCollectionController : NSObject<CKObjectController> {
	CKCollection* _collection;
	id _delegate;
	BOOL observing;
	BOOL animateInsertionsOnReload;
	BOOL appendCollectionCellControllerAsFooterCell;
	NSInteger numberOfFeedObjectsLimit;
	BOOL locked;
	BOOL changedWhileLocked;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) CKCollection* collection;

- (id)initWithCollection:(CKCollection*)collection;
+ (CKCollectionController*) controllerWithCollection:(CKCollection*)collection;

//FIXME : review those names ...
@property (nonatomic, assign) BOOL animateInsertionsOnReload;
@property (nonatomic, assign) BOOL appendCollectionCellControllerAsFooterCell;
@property (nonatomic, assign) NSInteger numberOfFeedObjectsLimit;

@end
