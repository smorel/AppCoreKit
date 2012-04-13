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
@synthesize attributes;

- (id)init{
    self = [super init];
    self.attributes = [NSMutableDictionary dictionary];
    return self;
}

- (void)dealloc{
	self.attributes = nil;
	[super dealloc];
}

- (void)reset{
	[self.attributes removeAllObjects];
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