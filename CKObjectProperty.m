//
//  CKObjectKeyValue.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-01.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKObjectProperty.h"


@implementation CKObjectProperty
@synthesize object,keyPath;

- (id)initWithObject:(id)theobject keyPath:(NSString*)thekeyPath{
	[super init];
	self.object = theobject;
	self.keyPath = thekeyPath;
	return self;
}

- (CKClassPropertyDescriptor*)descriptor{
	return [NSObject propertyDescriptor:[object class] forKeyPath:keyPath];
}

- (id)value{
	return [object valueForKeyPath:keyPath];
}

- (void)setValue:(id)value{
	[object setValue:value forKeyPath:keyPath];
}

@end
