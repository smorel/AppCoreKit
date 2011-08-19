//
//  CKDocumentArray.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKDocumentArray.h"
#import "CKNSNotificationCenter+Edition.h"

@interface CKDocumentArray()
@property (nonatomic,retain) NSMutableArray* objects;
@end

@implementation CKDocumentArray
@synthesize objects = _objects;

- (void)postInit{
	[super postInit];
	self.property = [CKObjectProperty propertyWithObject:self keyPath:@"objects"];
}

- (void)objectsMetaData:(CKObjectPropertyMetaData*)metaData{
	metaData.creatable = YES;
}

@end
