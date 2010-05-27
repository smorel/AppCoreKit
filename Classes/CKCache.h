//
//  CKCache.h
//  CloudKit
//
//  Created by Fred Brunel on 10-05-20.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CKCache : NSObject {
	NSMutableDictionary *_cachedObjects;
}

+ (CKCache *)sharedCache;

- (void)setImage:(UIImage *)image forKey:(id)key;
- (UIImage *)imageForKey:(id)key;

@end
