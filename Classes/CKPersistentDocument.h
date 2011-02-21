//
//  CKPersistentDocument.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-02-15.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKDocument.h"

@class CKPersistentDocument;
@protocol CKPersistentDocumentDelegate
- (void)document:(CKPersistentDocument*)document didLoadObjects:(NSArray*)objects forKey:(NSString*)key;
- (void)document:(CKPersistentDocument*)document didSaveObjects:(NSArray*)objects forKey:(NSString*)key;
@end

@interface CKPersistentDocument : NSObject<CKDocument> {
	NSMutableDictionary* objects;
	NSMutableArray* persistentKeys;
	BOOL autoSave;
	
	id<CKPersistentDocumentDelegate> _delegate;
}

@property (nonatomic, retain) NSMutableDictionary *objects;
@property (nonatomic, retain) NSMutableArray *persistentKeys;
@property (nonatomic, assign) BOOL autoSave;
@property (nonatomic, assign) id<CKPersistentDocumentDelegate> delegate;

- (void)save;

//Protected
- (NSMutableArray*)mutableObjectsForKey:(NSString*)key;

@end
