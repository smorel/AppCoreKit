//
//  CKObject+Validation.m
//  CloudKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import "CKObject+Validation.h"
#import "CKNSObject+Introspection.h"
#import "CKNSObject+Introspection_private.h"
#import "CKObjectPropertyMetaData.h"
#import "CKNSObject+Bindings.h"
#import "CKNSNotificationCenter+Edition.h"

/* TODO : see how we could integrate our validation predicates from metaData in the KVO validation methods.
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
        CKObjectPropertyMetaData* metaData = [CKObjectPropertyMetaData propertyMetaDataForObject:self property:property];
        if(metaData.validationPredicate){
            id object = [self valueForKey:property.name];
            if(![metaData.validationPredicate evaluateWithObject:object]){
                [results.invalidProperties addObject:property.name];
            }
        }
            //}
    }
	return results;
}

- (void)bindValidationWithBlock:(void(^)(CKObjectValidationResults* validationResults))validationBlock{
        //Register on property edition to send validation status when editing properties
    [[NSNotificationCenter defaultCenter]bindNotificationName:CKEditionPropertyChangedNotification withBlock:^(NSNotification *notification) {
        CKObjectProperty* property = [notification objectProperty];
        if(property.object == self){
            CKObjectValidationResults* validationResults = [self validate];
            validationResults.modifiedKeyPath = property.keyPath;
            if(validationBlock){
                validationBlock(validationResults);
            }
        }
    }];
    
        //Sends validation status synchronously
    CKObjectValidationResults* validationResults = [self validate];
    if(validationBlock){
        validationBlock(validationResults);
    }
}

@end


@implementation CKObjectValidationResults
@synthesize modifiedKeyPath,invalidProperties;

- (id)init{
    self = [super init];
    self.invalidProperties = [NSMutableArray array];
    return self;
}

- (void)dealloc{
    self.modifiedKeyPath = nil;
    self.invalidProperties = nil;
    [super dealloc];
}

- (BOOL)isValid{
    return [self.invalidProperties count] == 0;
}

@end