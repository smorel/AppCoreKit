//
//  CKConverter.m
//  CloudKitApp
//
//  Created by Sebastien Morel on 11-01-22.
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
