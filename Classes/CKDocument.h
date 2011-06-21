//
//  CKDocument.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKDocumentArray.h"


@interface CKDocument : NSObject {
	NSMutableDictionary* _objects;
//	NSMutableDictionary* _retainCounts;
}

+ (id)sharedDocument;

- (void)clear;

//- (void)retainObjectsForKey:(NSString*)key;
//- (void)releaseObjectsForKey:(NSString*)key;

- (CKDocumentCollection*)collectionForKey:(NSString*)key;
- (void)removeCollectionForKey:(NSString*)key;
- (void)setCollection:(CKDocumentCollection*)collection forKey:(NSString*)key;

//Helpers to create and set collections
- (CKDocumentArray*)arrayWithFeedSource:(CKFeedSource*)source forKey:(NSString*)key;
- (CKDocumentArray*)arrayWithFeedSource:(CKFeedSource*)source withStorage:(id)storage forKey:(NSString*)key;
- (CKDocumentArray*)arrayWithStorage:(id)storage forKey:(NSString*)key;

- (CKDocumentArray*)arrayWithFeedSource:(CKFeedSource*)source withStorage:(id)storage autoSave:(BOOL)autoSave forKey:(NSString*)key;
- (CKDocumentArray*)arrayWithStorage:(id)storage autoSave:(BOOL)autoSave forKey:(NSString*)key;
- (CKDocumentArray*)arrayForKey:(NSString*)key;

@end
