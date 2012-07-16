//
//  CKCache.m
//  CloudKit
//
//  Created by Fred Brunel.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKCache.h"

@interface CKCache ()

@property (nonatomic, retain) NSMutableDictionary *cachedObjects;

@end

//

@implementation CKCache

@synthesize cachedObjects = _cachedObjects;

+ (CKCache *)sharedCache {
	static CKCache *cache = nil;
	if (cache == nil) {
		cache = [[CKCache alloc] init];
	}
	return cache;
}

//

- (id)init {
	if (self = [super init]) {
		self.cachedObjects = [NSMutableDictionary dictionaryWithCapacity:20];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidReceiveMemoryWarningNotification:) 
													 name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
	self.cachedObjects = nil;
    [super dealloc];
}

#pragma mark Public API

- (void)setImage:(UIImage *)image forKey:(id)key {
	NSAssert(image, @"UIImage is nil.");
	[self.cachedObjects setObject:image forKey:key];
}

- (UIImage *)imageForKey:(id)key {
	UIImage *image = [self.cachedObjects objectForKey:key];
	return image;
}

#pragma mark Low Memory Condition

- (void)applicationDidReceiveMemoryWarningNotification:(NSNotification *)notification {
	[self.cachedObjects removeAllObjects];
}

@end
