//
//  CKDocument.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-02-15.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

@protocol CKDocument

- (void)retainObjectsForKey:(NSString*)key;
- (void)releaseObjectsForKey:(NSString*)key;

@end