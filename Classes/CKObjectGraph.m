//
//  CKObjectGraph.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-09-01.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKObjectGraph.h"
#import "CKProperty.h"
#import "CKObject.h"
#import "CKNSValueTransformer+Additions.h"

#import "CKUIColor+ValueTransformer.h"
#import "CKUIImage+ValueTransformer.h"
#import "CKNSNumber+ValueTransformer.h"
#import "CKNSURL+ValueTransformer.h"
#import "CKNSDate+ValueTransformer.h"
#import "CKNSArray+ValueTransformer.h"
#import "CKCollection+ValueTransformer.h"
#import "CKNSIndexPath+ValueTransformer.h"
#import "CKNSObject+ValueTransformer.h"
#import "CKNSValueTransformer+NativeTypes.h"
#import "CKNSValueTransformer+CGTypes.h"


NSString* CKObjectGraphObjectKey    = @"@object";
NSString* CKObjectGraphClassKey     = @"@class";
NSString* CKObjectGraphReferenceKey = @"@reference";
NSString* CKObjectGraphVariablesKey = @"@vars";
NSString* CKObjectGraphVariableKey  = @"@var";


@interface NSMutableDictionary (CKCascadingTreePrivate)
- (NSMutableDictionary*)parentDictionary;
@end

@interface CKObjectGraph()
@property(nonatomic,retain)NSMutableDictionary* instances;
@property(nonatomic,retain)NSMutableDictionary* references;
@end

@implementation CKObjectGraph
@synthesize instances;
@synthesize references;

- (id)init{
    self = [super init];
    return self;
}

- (void)dealloc{
    self.instances = nil;
    self.references = nil;
    [super dealloc];
}

- (void)registerInstance:(id)instance withUniqueId:(NSString*)uniqueId forDictionary:(NSMutableDictionary*)dico{
    NSMutableDictionary* theinstances = [self.instances objectForKey:[NSValue valueWithNonretainedObject:dico]];
    if(!theinstances){
        theinstances = [NSMutableDictionary dictionary];
        [self.instances setObject:theinstances forKey:[NSValue valueWithNonretainedObject:dico]];
    }
    
    [theinstances setObject:instance forKey:uniqueId];
}

- (id)instanceWithUniqueId:(NSString*)uniqueId fromDictionary:(NSMutableDictionary*)dico{
    NSMutableDictionary* currentDico = dico;
    while(currentDico){
        NSMutableDictionary* theinstances = [self.instances objectForKey:[NSValue valueWithNonretainedObject:currentDico]];
        if(theinstances){
            id instance = [theinstances objectForKey:uniqueId];
            if(instance){
                return instance;
            }
        }
        currentDico = [currentDico parentDictionary];
    }
    return nil;
}

- (id)objectWithUniqueId:(NSString*)uniqueId{
    return [self instanceWithUniqueId:uniqueId fromDictionary:self.tree];
}

- (id)variableNamed:(NSString*)name fromDictionary:(NSMutableDictionary*)dico{
    NSMutableDictionary* currentDico = dico;
    while(currentDico){
        NSMutableDictionary* variables = [currentDico objectForKey:CKObjectGraphVariablesKey];
        if(variables){
            id variable = [variables objectForKey:name];
            if(variable){
                //in case the variable refers to another variable
                if([variable isKindOfClass:[NSMutableDictionary class]] && [variable containsObjectForKey:CKObjectGraphVariableKey]){
                    NSString* varName = [variable objectForKey:CKObjectGraphVariableKey];
                    return [self variableNamed:varName fromDictionary:[varName isEqualToString:name] ? [currentDico parentDictionary] : currentDico];
                }
                return variable;
            }
        }
        currentDico = [currentDico parentDictionary];
    }
    return nil;
}

- (void)registerReferenceForProperty:(CKProperty*)property withUniqueId:(NSString*)uniqueId forDictionary:(NSMutableDictionary*)dico{
    NSMutableDictionary* refDico = [NSMutableDictionary dictionary];
    [refDico setObject:uniqueId forKey:@"id"];
    [refDico setObject:[NSValue valueWithNonretainedObject:dico] forKey:@"dico"];
    [self.references setObject:refDico forKey:property];
}

- (void)solveReferences{
    for(CKProperty* property in [references allKeys]){
        NSMutableDictionary* refDico = [references objectForKey:property];
        NSString* uniqueId = [refDico objectForKey:@"id"];
        NSMutableDictionary* dico = [[refDico objectForKey:@"dico"]nonretainedObjectValue];
        id object = [self instanceWithUniqueId:uniqueId fromDictionary:dico];
        NSAssert(object,@"object not found");
        [property setValue:object];
    }
}

- (id)createObjectFromDictionary:(NSMutableDictionary*)dico withUniqueId:(NSString*)uniqueId{
    if([uniqueId hasPrefix:@"$"])
        return nil;
        
    id createdObject = nil;
    id classObject = [dico objectForKey:CKObjectGraphClassKey];
    if(classObject){
        Class theClass = [NSValueTransformer convertClassFromObject:classObject];
        if(theClass){
            createdObject = [[[theClass alloc]init] autorelease];
            if(uniqueId){
                if([createdObject respondsToSelector:@selector(setUniqueId:)]){
                    [createdObject setUniqueId:uniqueId];
                }
                [self registerInstance:createdObject withUniqueId:uniqueId forDictionary:[dico parentDictionary]];
            }
        }
    }
    
    for(id key in [dico allKeys]){
        id value = [dico objectForKey:key];
        if([value isKindOfClass:[NSMutableDictionary class]] && [value containsObjectForKey:CKObjectGraphVariableKey]){
            NSString* varName = [value objectForKey:CKObjectGraphVariableKey];
            value = [self variableNamed:varName fromDictionary:dico];
            NSAssert(value,@"variable not found");
            [dico setObject:value forKey:key];
        }
        
        if(createdObject){
            CKClassPropertyDescriptor* descriptor = [createdObject propertyDescriptorForKeyPath:key];
            if(descriptor){
                CKProperty* property = [CKProperty propertyWithObject:createdObject keyPath:key];
                Class propertyType = [property type];
                
                if([NSObject isClass:propertyType kindOfClass:[NSArray class]]
                   || [NSObject isClass:propertyType kindOfClass:[CKCollection class]]){
                    NSAssert([value isKindOfClass:[NSArray class]],@"invalid type");
                    if([NSObject isClass:propertyType kindOfClass:[NSArray class]]){
                        id propertyValue = [property value];
                        if(!propertyValue){
                            [property setValue:[NSMutableArray array]];
                        }
                    }
                    NSMutableArray* array = [NSMutableArray array];
                    for(id subValue in value){
                        NSAssert([subValue isKindOfClass:[NSMutableDictionary class]],@"invalid value type");
                        id subObject = [self createObjectFromDictionary:subValue withUniqueId:nil];
                        if(subObject){
                            [array addObject:subObject];
                        }
                    }
                    [property insertObjects:array atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [array count])]];
                }
                else if(descriptor.propertyType == CKClassPropertyDescriptorTypeObject){
                    BOOL handled = NO;
                    if([value isKindOfClass:[NSString class]]){
                        Class theClass = NSClassFromString(value);
                        if(theClass){
                            [property setValue:theClass];
                            handled = YES;
                        }
                    }
                    else if([value isKindOfClass:[NSDictionary class]]){
                        id referenceObject = [value objectForKey:CKObjectGraphReferenceKey];
                        if([referenceObject isKindOfClass:[NSMutableDictionary class]] && [referenceObject containsObjectForKey:CKObjectGraphVariableKey]){
                            NSString* varName = [referenceObject objectForKey:CKObjectGraphVariableKey];
                            referenceObject = [self variableNamed:varName fromDictionary:referenceObject];
                            if(referenceObject){
                                [value setObject:referenceObject forKey:CKObjectGraphReferenceKey];
                            }
                        }
                        
                        if(referenceObject){
                            NSAssert([referenceObject isKindOfClass:[NSString class]],@"invalid value type");
                            [self createObjectFromDictionary:value withUniqueId:nil]; //If inherited objects, create that objects
                            [self registerReferenceForProperty:property withUniqueId:referenceObject forDictionary:value];
                            handled = YES;
                        }
                        else{
                            id subObject = [self createObjectFromDictionary:value withUniqueId:key];
                            NSAssert([NSObject isClass:[subObject class] kindOfClass:propertyType],@"invalid value type");
                            [property setValue:subObject];
                            handled = YES;
                        }
                    }
                    
                    if(!handled){
                        [NSValueTransformer transform:value inProperty:property];
                    }
                }
                else{
                    [NSValueTransformer transform:value inProperty:property];
                }
            }
            else if([value isKindOfClass:[NSDictionary class]]){
                [self createObjectFromDictionary:value withUniqueId:key];
            }
        }
        else if([value isKindOfClass:[NSDictionary class]]){
            [self createObjectFromDictionary:value withUniqueId:key];
        }
    }
    
    return createdObject;
}



+ (CKObjectGraph*)objectGraphWithContentOfFileNamed:(NSString*)name{
    CKObjectGraph* graph = [[[CKObjectGraph alloc]init]autorelease];
    
	NSString* path = [[NSBundle mainBundle]pathForResource:name ofType:@"objectgraph"];
	[graph loadContentOfFile:path];
    
    return graph;
}

- (BOOL)loadContentOfFile:(NSString*)path{
    if([super loadContentOfFile:path]){
        self.instances = [NSMutableDictionary dictionary];
        
        self.references = [NSMutableDictionary dictionary];
        [self createObjectFromDictionary:self.tree withUniqueId:nil];
        [self solveReferences];
        self.references = nil;
        
        return YES;
    }
    return NO;
}


@end

