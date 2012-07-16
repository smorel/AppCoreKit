//
//  CKNetworkActivityManager.h
//  CloudKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


/** TODO
 */
@interface CKNetworkActivityManager : NSObject {
	NSMutableSet *_objects;
}

+ (CKNetworkActivityManager*)defaultManager;

- (void)addNetworkActivityForObject:(id)object;
- (void)removeNetworkActivityForObject:(id)object;

@end
