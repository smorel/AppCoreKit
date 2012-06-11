//
//  CKPropertyExtendedAttributes.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-12.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKPropertyExtendedAttributes.h"
#import "CKCollection.h"
#import "CKPropertyExtendedAttributes+CKAttributes.h"

#include <ext/hash_map>

using namespace __gnu_cxx;

namespace __gnu_cxx{
    template<> struct hash< NSThread* >
    {
        size_t operator()( NSThread* x ) const{
            return (size_t)x;
        }
    };
}

static __gnu_cxx::hash_map<NSThread*, CKPropertyExtendedAttributes*> CKPropertyExtendedAttributesPerThreadSingleton;

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
    
    CKPropertyExtendedAttributes* attributes = CKPropertyExtendedAttributesPerThreadSingleton[currentThread];
    if(!attributes){
        attributes = [[CKPropertyExtendedAttributes alloc]init];
        CKPropertyExtendedAttributesPerThreadSingleton[currentThread] = attributes;
    }
    
	[attributes reset];
    
    if([NSObject isClass:property.type kindOfClass:[CKCollection class]]){
        attributes.creatable = YES;
    }
	
	SEL extendedAttributesSelector = property.extendedAttributesSelector;
	if([object respondsToSelector:extendedAttributesSelector]){
		[object performSelector:extendedAttributesSelector withObject:attributes];
	}
	
	return attributes;
}

@end