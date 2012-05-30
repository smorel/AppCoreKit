//
//  CKPropertyExtendedAttributes.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-12.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKPropertyExtendedAttributes.h"

static NSMutableDictionary* CKPropertyExtendedAttributesPerThreadSingleton = nil;

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
    NSThread* currentThread = [NSThread currentThread];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CKPropertyExtendedAttributesPerThreadSingleton = [[NSMutableDictionary alloc]init];
    });
    
    CKPropertyExtendedAttributes* attributes = [CKPropertyExtendedAttributesPerThreadSingleton objectForKey:[NSValue valueWithNonretainedObject: currentThread]];
    if(!attributes){
        attributes = [[[CKPropertyExtendedAttributes alloc]init]autorelease];
        [CKPropertyExtendedAttributesPerThreadSingleton setObject:attributes forKey:[NSValue valueWithNonretainedObject: currentThread]];
    }
    
	[attributes reset];
	
	SEL extendedAttributesSelector = property.extendedAttributesSelector;
	if([object respondsToSelector:extendedAttributesSelector]){
		[object performSelector:extendedAttributesSelector withObject:attributes];
	}
	
	return attributes;
}

@end