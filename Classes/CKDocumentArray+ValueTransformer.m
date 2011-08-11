//
//  CKDocumentArray+ValueTransformer.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-11.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKDocumentArray+ValueTransformer.h"
#import "CKNSArray+ValueTransformer.h"
#import "CKNSValueTransformer+Additions.h"


@implementation CKDocumentArray (CKDocumentArray_ValueTransformer)

+ (CKDocumentArray*)convertFromNSArray:(NSArray*)array withContentClassName:(NSString*)className{
	NSArray* results = [NSArray convertFromNSArray:array withContentClassName:className];
	CKDocumentArray* result = [[[CKDocumentArray alloc]init]autorelease];
	[result addObjectsFromArray:results];
	return result;
}

+ (id)convertFromNSArray:(NSArray*)array{
    CKDocumentArray* collection = [[[CKDocumentArray alloc]init]autorelease];
    NSArray* results = [NSArray convertFromNSArray:array];
    [collection addObjectsFromArray:results];
	return collection;
}

@end
