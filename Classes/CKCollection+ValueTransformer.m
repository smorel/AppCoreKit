//
//  CKCollection+ValueTransformer.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKCollection+ValueTransformer.h"
#import "NSArray+ValueTransformer.h"
#import "NSValueTransformer+Additions.h"


@implementation CKCollection (CKValueTransformer)

+ (CKCollection*)convertFromNSArray:(NSArray*)array withContentClassName:(NSString*)className{
	NSArray* results = [NSArray convertFromNSArray:array withContentClassName:className];
	CKCollection* result = [[[[self class] alloc]init]autorelease];
	[result addObjectsFromArray:results];
	return result;
}

+ (id)convertFromNSArray:(NSArray*)array{
    CKCollection* collection = [[[[self class] alloc]init]autorelease];
    NSArray* results = [NSArray convertFromNSArray:array];
    [collection addObjectsFromArray:results];
	return collection;
}

@end
