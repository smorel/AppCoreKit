//
//  CKDocumentArray+ValueTransformer.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-11.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKDocumentCollection+ValueTransformer.h"
#import "CKNSArray+ValueTransformer.h"
#import "CKNSValueTransformer+Additions.h"


@implementation CKDocumentCollection (CKDocumentArray_ValueTransformer)

+ (CKDocumentCollection*)convertFromNSArray:(NSArray*)array withContentClassName:(NSString*)className{
	NSArray* results = [NSArray convertFromNSArray:array withContentClassName:className];
	CKDocumentCollection* result = [[[[self class] alloc]init]autorelease];
	[result addObjectsFromArray:results];
	return result;
}

+ (id)convertFromNSArray:(NSArray*)array{
    CKDocumentCollection* collection = [[[[self class] alloc]init]autorelease];
    NSArray* results = [NSArray convertFromNSArray:array];
    [collection addObjectsFromArray:results];
	return collection;
}

@end
