//
//  CKNSArrayAdditionsTestCase.m
//  CloudKit
//
//  Created by Fred Brunel on 09-11-06.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import "CKNSArrayAdditionsTestCase.h"
#import "CKNSArrayAdditions.h"

@implementation CKNSArrayAdditionsTestCase

- (void)setUp {
	_array = [NSMutableArray array];
	[_array addObject:@"first"];
	[_array addObject:@"second"];
}

- (void)tearDown {
}

//

- (void)testFirst {
	STAssertEqualObjects([_array first], @"first", @"FAIL");
}

@end
