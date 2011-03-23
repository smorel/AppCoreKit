//
//  CKDocument.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-02-15.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

@protocol CKDocument

- (NSArray*)objectsForKey:(NSString*)key;
- (void)addObjects:(NSArray*)newItems forKey:(NSString*)key;
- (void)addObjects:(NSArray*)newItems atIndex:(NSUInteger)index forKey:(NSString*)key;
- (void)removeObjects:(NSArray*)items forKey:(NSString*)key;
- (void)removeAllObjectsForKey:(NSString*)key;
- (void)addObserver:(id)object forKey:(NSString*)key;
- (void)removeObserver:(id)object forKey:(NSString*)key;
- (void)retainObjectsForKey:(NSString*)key;
- (void)releaseObjectsForKey:(NSString*)key;
- (void)fetchRange:(NSRange)range forKey:(NSString*)key;
- (void)setDataSource:(id)source forKey:(NSString*)key;
- (id)dataSourceForKey:(NSString*)key;

@end