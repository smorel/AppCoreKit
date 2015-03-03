//
//  CKObjectGraph.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKObjectGraph.h"
#import "CKProperty.h"
#import "CKObject.h"
#import "NSValueTransformer+Additions.h"

#import "UIColor+ValueTransformer.h"
#import "UIImage+ValueTransformer.h"
#import "NSNumber+ValueTransformer.h"
#import "NSURL+ValueTransformer.h"
#import "NSDate+ValueTransformer.h"
#import "NSArray+ValueTransformer.h"
#import "CKCollection+ValueTransformer.h"
#import "NSIndexPath+ValueTransformer.h"
#import "NSObject+ValueTransformer.h"
#import "NSValueTransformer+NativeTypes.h"
#import "NSValueTransformer+CGTypes.h"
#import "CKDebug.h"


NSString* CKObjectGraphObjectKey    = @"@object";
NSString* CKObjectGraphClassKey     = @"@class";
NSString* CKObjectGraphReferenceKey = @"@reference";
NSString* CKObjectGraphVariablesKey = @"@vars";
NSString* CKObjectGraphVariableKey  = @"@var";

//We register references for arrays as property pointing on the collection, an index and the id of the referenced object.
//When an object is referenced in a collection, we'll insert a NSNull object instead and replace it at the end of the process when solving references.


@interface NSMutableDictionary (CKCascadingTreePrivate)
- (NSMutableDictionary*)parentDictionary;
@end

@interface CKObjectGraph()
@property(nonatomic,retain)NSMutableDictionary* instances;
@property(nonatomic,retain)NSMutableDictionary* references;
@property(nonatomic,retain)NSMutableDictionary* referencesForCollectionItems;
@end

@implementation CKObjectGraph
@synthesize instances;
@synthesize references;
@synthesize referencesForCollectionItems;

- (id)init{
    self = [super init];
    return self;
}

- (void)dealloc{
    self.instances = nil;
    self.references = nil;
    self.referencesForCollectionItems = nil;
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
    [self.references setObject:refDico forKey:[NSValue valueWithNonretainedObject:[property retain]]];
}


- (void)registerReferenceForCollectionProperty:(CKProperty*)property index:(NSInteger)index withUniqueId:(NSString*)uniqueId forDictionary:(NSMutableDictionary*)dico{
    NSDictionary* propertyDico = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSValue valueWithNonretainedObject:[property retain]],@"property",
                                         [NSNumber numberWithInteger:index],@"index",
                                         nil];
    
    NSMutableDictionary* refDico = [NSMutableDictionary dictionary];
    [refDico setObject:uniqueId forKey:@"id"];
    [refDico setObject:[NSValue valueWithNonretainedObject:dico] forKey:@"dico"];
    [self.referencesForCollectionItems setObject:refDico forKey:propertyDico];
}

- (void)solveReferences{
    for(NSValue* propertyValue in [references allKeys]){
        NSMutableDictionary* refDico = [references objectForKey:propertyValue];
        CKProperty* property = [propertyValue nonretainedObjectValue];
        
        NSString* uniqueId = [refDico objectForKey:@"id"];
        NSMutableDictionary* dico = [[refDico objectForKey:@"dico"]nonretainedObjectValue];
        id object = [self instanceWithUniqueId:uniqueId fromDictionary:dico];
        CKAssert(object,@"object not found");
        [property setValue:object];
        [property autorelease];
    }
    
    for(NSDictionary* keyDico in [referencesForCollectionItems allKeys]){
        NSValue* propertyValue = [keyDico objectForKey:@"property"];
        NSInteger index = [[keyDico objectForKey:@"index"]integerValue];
        
        NSMutableDictionary* refDico = [referencesForCollectionItems objectForKey:keyDico];
        CKProperty* property = [propertyValue nonretainedObjectValue];
        
        NSString* uniqueId = [refDico objectForKey:@"id"];
        NSMutableDictionary* dico = [[refDico objectForKey:@"dico"]nonretainedObjectValue];
        
        id object = [self instanceWithUniqueId:uniqueId fromDictionary:dico];
        CKAssert(object,@"object not found");
        
        [property removeObjectsAtIndexes:[NSIndexSet indexSetWithIndex:index]];
        [property insertObjects:[NSArray arrayWithObject:object] atIndexes:[NSIndexSet indexSetWithIndex:index]];
        [property autorelease];
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
            CKAssert(value,@"variable not found");
            [dico setObject:value forKey:key];
        }
        
        if(createdObject){
            CKClassPropertyDescriptor* descriptor = [createdObject propertyDescriptorForKeyPath:key];
            if(descriptor){
                CKProperty* property = [CKProperty propertyWithObject:createdObject keyPath:key];
                Class propertyType = [property type];
                
                if([NSObject isClass:propertyType kindOfClass:[NSArray class]]
                   || [NSObject isClass:propertyType kindOfClass:[CKCollection class]]){
                    CKAssert([value isKindOfClass:[NSArray class]],@"invalid type");
                    if([NSObject isClass:propertyType kindOfClass:[NSArray class]]){
                        id propertyValue = [property value];
                        if(!propertyValue){
                            [property setValue:[NSMutableArray array]];
                        }
                    }
                    NSMutableArray* array = [NSMutableArray array];
                    int i =0;
                    for(id subValue in value){
                        CKAssert([subValue isKindOfClass:[NSMutableDictionary class]],@"invalid value type");
                        
                        id referenceObject = [subValue objectForKey:CKObjectGraphReferenceKey];
                        if(referenceObject){
                            CKAssert([referenceObject isKindOfClass:[NSString class]],@"invalid value type");
                            [self registerReferenceForCollectionProperty:property index:i withUniqueId:referenceObject forDictionary:subValue];
                            [array addObject:[NSNull null]];
                        }
                        else{
                            id subObject = [self createObjectFromDictionary:subValue withUniqueId:nil];
                            if(subObject){
                                [array addObject:subObject];
                            }
                        }
                        ++i;
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
                            CKAssert([referenceObject isKindOfClass:[NSString class]],@"invalid value type");
                            [self createObjectFromDictionary:value withUniqueId:nil]; //If inherited objects, create that objects
                            [self registerReferenceForProperty:property withUniqueId:referenceObject forDictionary:value];
                            handled = YES;
                        }
                        else{
                            id subObject = [self createObjectFromDictionary:value withUniqueId:key];
                            CKAssert([NSObject isClass:[subObject class] kindOfClass:propertyType],@"invalid value type");
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
        self.referencesForCollectionItems = [NSMutableDictionary dictionary];
        
        [self createObjectFromDictionary:self.tree withUniqueId:nil];
        [self solveReferences];
        
        self.references = nil;
        self.referencesForCollectionItems = nil;
        
        return YES;
    }
    return NO;
}


@end

