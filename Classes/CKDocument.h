//
//  NFBDocument.h
//  NFB
//
//  Created by Sebastien Morel on 11-02-15.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKModelObjectsProtocol.h"


@interface CKDocument : NSObject<CKModelObjectsProtocol> {
	NSMutableDictionary* objects;
	NSMutableArray* onDiskStorageKeys;
}

@property (nonatomic, retain) NSMutableDictionary *objects;
@property (nonatomic, retain) NSMutableArray *onDiskStorageKeys;

- (void)saveObjectsForKey:(NSString*)key;
- (NSMutableArray*)loadObjectsForKey:(NSString*)key;

@end
