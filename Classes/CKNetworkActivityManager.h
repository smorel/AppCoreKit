//
//  CKNetworkActivityManager.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-02-22.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CKNetworkActivityManager : NSObject {
	NSMutableSet *_objects;
}

+ (CKNetworkActivityManager*)defaultManager;

- (void)addNetworkActivityForObject:(id)object;
- (void)removeNetworkActivityForObject:(id)object;

@end
