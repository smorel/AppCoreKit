//
//  NFBDocument.h
//  NFB
//
//  Created by Sebastien Morel on 11-02-15.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKDocument.h"


@interface CKPersistentDocument : NSObject<CKDocument> {
	NSMutableDictionary* objects;
	NSMutableArray* persistentKeys;
	BOOL autoSave;
}

@property (nonatomic, retain) NSMutableDictionary *objects;
@property (nonatomic, retain) NSMutableArray *persistentKeys;
@property (nonatomic, assign) BOOL autoSave;

- (void)save;

@end
