//
//  CKCache.h
//  CloudKit
//
//  Created by Fred Brunel.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/** TODO
 */
@interface CKCache : NSObject {
	NSMutableDictionary *_cachedObjects;
}

+ (CKCache *)sharedCache;

- (void)setImage:(UIImage *)image forKey:(id)key;
- (UIImage *)imageForKey:(id)key;

@end
