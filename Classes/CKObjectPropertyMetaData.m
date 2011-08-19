//
//  CKObjectPropertyMetaData.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-12.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKObjectPropertyMetaData.h"

static CKObjectPropertyMetaData* CKObjectPropertyMetaDataSingleton = nil;

@implementation CKObjectPropertyMetaData
@synthesize comparable;
@synthesize serializable;
@synthesize creatable;
@synthesize hashable;
@synthesize copiable;
@synthesize deepCopy;
@synthesize editable;
@synthesize multiselectionEnabled;
@synthesize enumDescriptor;
@synthesize contentType;
@synthesize dateFormat;
@synthesize valuesAndLabels;
@synthesize contentProtocol;
@synthesize propertyCellControllerClass;
@synthesize validationPredicate;

- (void)dealloc{
	self.enumDescriptor = nil;
	self.dateFormat = nil;
	self.contentProtocol = nil;
	[super dealloc];
}

- (void)reset{
	self.comparable = YES;
	self.serializable = YES;
	self.creatable = NO;
	self.hashable = YES;
	self.copiable = YES;
	self.deepCopy = NO;
	self.editable = YES;
	self.enumDescriptor = nil;
	self.valuesAndLabels = nil;
	self.contentType = nil;
	self.contentProtocol = nil;
	self.dateFormat = nil;
	self.propertyCellControllerClass = nil;
	self.validationPredicate = nil;
}

+ (CKObjectPropertyMetaData*)propertyMetaDataForObject:(id)object property:(CKClassPropertyDescriptor*)property{
	if(CKObjectPropertyMetaDataSingleton == nil){
		CKObjectPropertyMetaDataSingleton = [[CKObjectPropertyMetaData alloc]init];
	}
	[CKObjectPropertyMetaDataSingleton reset];
	
	SEL metaDataSelector = property.metaDataSelector;
	if([object respondsToSelector:metaDataSelector]){
		[object performSelector:metaDataSelector withObject:CKObjectPropertyMetaDataSingleton];
	}
	
	return CKObjectPropertyMetaDataSingleton;
}

@end


@implementation CKModelObjectPropertyMetaData
@end
