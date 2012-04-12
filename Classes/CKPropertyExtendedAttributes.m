//
//  CKPropertyExtendedAttributes.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-12.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKPropertyExtendedAttributes.h"

static CKPropertyExtendedAttributes* CKPropertyExtendedAttributesSingleton = nil;

@implementation CKPropertyExtendedAttributes
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
@synthesize tableViewCellControllerClass;
@synthesize validationPredicate;
@synthesize options;

- (id)init{
    self = [super init];
    self.options = [NSMutableDictionary dictionary];
    return self;
}

- (void)dealloc{
	self.dateFormat = nil;
	self.validationPredicate = nil;
	self.enumDescriptor = nil;
	self.valuesAndLabels = nil;
	self.options = nil;
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
	self.tableViewCellControllerClass = nil;
	self.validationPredicate = nil;
	self.multiselectionEnabled = NO;
	[self.options removeAllObjects];
}

+ (CKPropertyExtendedAttributes*)extendedAttributesForObject:(id)object property:(CKClassPropertyDescriptor*)property{
	if(CKPropertyExtendedAttributesSingleton == nil){
		CKPropertyExtendedAttributesSingleton = [[CKPropertyExtendedAttributes alloc]init];
	}
	[CKPropertyExtendedAttributesSingleton reset];
	
	SEL extendedAttributesSelector = property.extendedAttributesSelector;
	if([object respondsToSelector:extendedAttributesSelector]){
		[object performSelector:extendedAttributesSelector withObject:CKPropertyExtendedAttributesSingleton];
	}
	
	return CKPropertyExtendedAttributesSingleton;
}

@end