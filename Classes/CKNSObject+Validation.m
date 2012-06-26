//
//  CKNSObject+Validation.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-11-30.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import "CKNSObject+Validation.h"
#import "CKNSObject+CKRuntime.h"
#import "CKNSObject+CKRuntime_private.h"
#import "CKPropertyExtendedAttributes.h"
#import "CKNSObject+Bindings.h"

/* TODO : see how we could integrate our validation predicates from attributes in the KVO validation methods.
        by swizzling for example ...
 
 - (BOOL)validateValue:(id *)ioValue forKey:(NSString *)key error:(NSError **)outError;
 - (BOOL)validateValue:(id *)ioValue forKeyPath:(NSString *)inKeyPath error:(NSError **)outError;
 */

@implementation NSObject (CKValidation)

- (CKObjectValidationResults*)validate{
    CKObjectValidationResults* results = [[[CKObjectValidationResults alloc]init]autorelease];
	NSArray* allProperties = [self allPropertyDescriptors];
    for(CKClassPropertyDescriptor* property in allProperties){
            // if(property.isReadOnly == NO){
        CKPropertyExtendedAttributes* attributes = [property extendedAttributesForInstance:self];
        if(attributes.validationPredicate){
            id object = [self valueForKey:property.name];
            if(![attributes.validationPredicate evaluateWithObject:object]){
                [results.invalidProperties addObject:property.name];
            }
        }
            //}
    }
	return results;
}

@end


@implementation CKObjectValidationResults
@synthesize invalidProperties;

- (id)init{
    self = [super init];
    self.invalidProperties = [NSMutableArray array];
    return self;
}

- (void)dealloc{
    self.invalidProperties = nil;
    [super dealloc];
}

- (BOOL)isValid{
    return [self.invalidProperties count] == 0;
}

@end