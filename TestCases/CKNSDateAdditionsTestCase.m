//
//  CKNSDateAdditionsTestCase.m
//  CloudKit
//
//  Created by Fred Brunel on 09-12-17.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import "CKNSDateAdditionsTestCase.h"
#import "CKNSDateAdditions.h"

@implementation CKNSDateAdditionsTestCase

- (void)setUp {
}

- (void)tearDown {
}

//

- (void)testFirst {
	NSDate *date = [NSDate dateFromString:@"09-12-10" withDateFormat:@"yy-dd-mm"];
	STAssertEqualObjects(@"09-12-10", [date stringWithDateFormat:@"yy-dd-mm"], [date stringWithDateFormat:@"yy-dd-mm"]);
}

@end
