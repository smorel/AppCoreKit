//
//  NSObject+Validation.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import "NSObject+Validation.h"
#import "NSObject+Runtime.h"
#import "NSObject+Runtime_private.h"
#import "CKPropertyExtendedAttributes.h"
#import "CKProperty.h"

/* TODO : see how we could integrate our validation predicates from attributes in the KVO validation methods.
        by swizzling for example ...
 
 - (BOOL)validateValue:(id *)ioValue forKey:(NSString *)key error:(NSError **)outError;
 - (BOOL)validateValue:(id *)ioValue forKeyPath:(NSString *)inKeyPath error:(NSError **)outError;
 */

@implementation NSObject (CKValidation)

- (CKObjectValidationResults*)validate{
    CKObjectValidationResults* results = [[[CKObjectValidationResults alloc]init]autorelease];
	NSArray* allProperties = [self allPropertyDescriptors];
    for(CKClassPropertyDescriptor* descriptor in allProperties){
        CKPropertyExtendedAttributes* attributes = [descriptor extendedAttributesForInstance:self];
        if(attributes.validationPredicate){
            id object = [self valueForKey:descriptor.name];
            if(![attributes.validationPredicate evaluateWithObject:object]){
                [(NSMutableSet*)results.invalidProperties addObject:[CKProperty propertyWithObject:self keyPath:descriptor.name]];
            }
        }
    }
	return results;
}

- (CKObjectValidationResults*)validatePropertiesNamed:(NSArray*)propertyNames{
    CKObjectValidationResults* results = [[[CKObjectValidationResults alloc]init]autorelease];
    for(NSString* propertyName in propertyNames){
        CKClassPropertyDescriptor* descriptor = [self propertyDescriptorForKeyPath:propertyName];
        if(descriptor){
            CKPropertyExtendedAttributes* attributes = [descriptor extendedAttributesForInstance:self];
            if(attributes.validationPredicate){
                id object = [self valueForKey:descriptor.name];
                if(![attributes.validationPredicate evaluateWithObject:object]){
                    [(NSMutableSet*)results.invalidProperties addObject:[CKProperty propertyWithObject:self keyPath:descriptor.name]];
                }
            }
        }
    }
	return results;
}

@end


@implementation CKObjectValidationResults
@synthesize invalidProperties;

- (id)init{
    self = [super init];
    self.invalidProperties = [NSMutableSet set];
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