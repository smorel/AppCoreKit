//
//  CKStoreTestCase.m
//  CloudKit
//
//  Created by Fred Brunel on 10-01-11.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKStoreTestCase.h"
#import "CKCoreDataManager.h"
#import "CKStore.h"

@implementation CKStoreTestCase

- (void) testMath {    
    STAssertTrue(YES, @"");
}

- (void)testCreateStore {
	[CKCoreDataManager setSharedManager:[[CKCoreDataManager alloc] initWithPersistentStoreURL:[NSURL URLWithString:@"memory://store/"] storeType:NSInMemoryStoreType storeOptions:nil]];
	CKStore *store = [[CKStore alloc] initWithDomainName:@"test"];
	STAssertTrue(store != nil, @"");
}

@end
