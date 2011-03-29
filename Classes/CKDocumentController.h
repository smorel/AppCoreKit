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
}

@property (nonatomic, assign) id document;
@property (nonatomic, retain) NSString* key;
@property (nonatomic, assign) id delegate;

- (id)initWithDocument:(id)document key:(NSString*)key;

@end
