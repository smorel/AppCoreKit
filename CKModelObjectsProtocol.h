//
//  CKModelObjectsProtocol.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-02-15.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//


@protocol CKModelObjectsProtocol
- (NSMutableArray*)objectsForKey:(NSString*)key;
- (void)addObjects:(NSArray*)newItems forKey:(NSString*)key;
- (void)removeObjects:(NSArray*)items forKey:(NSString*)key;
- (void)registerAsObserver:(id)object forKey:(NSString*)key;
- (void)unregisterAsObserver:(id)object forKey:(NSString*)key;
@end