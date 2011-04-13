//
//  CKFeedController.h
//  FeedView
//
//  Created by Sebastien Morel on 11-03-16.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKObjectController.h"
#import <CloudKit/CKModelObserver.h>


@interface CKDocumentController : NSObject<CKObjectController> {
	id _document;
	NSString* _key;
	id _delegate;
	BOOL observing;
	BOOL animateFirstInsertion;
	BOOL displayFeedSourceCell;
	NSInteger numberOfFeedObjectsLimit;
}

@property (nonatomic, assign) id document;
@property (nonatomic, retain) NSString* key;
@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) BOOL animateFirstInsertion;
@property (nonatomic, assign) BOOL displayFeedSourceCell;
@property (nonatomic, assign) NSInteger numberOfFeedObjectsLimit;

- (id)initWithDocument:(id)document key:(NSString*)key;

@end
