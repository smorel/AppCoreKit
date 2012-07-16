//
//  CKConverter.m
//  CloudKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKValueTransformer.h"
#import "CKNSObject+Introspection.h"
#import "CKNSValueTransformer+Additions.h"

@implementation CKValueTransformer


+ (id)transformValue:(id)value toClass:(Class)type{
	return [NSValueTransformer transform:value toClass:type];
}

@end
