//
//  CKMapping2.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-07-21.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKMapping2.h"
#import "CKNSValueTransformer+Additions.h"
#import "CKNSObject+Introspection.h"
#import "CKObjectProperty.h"
#import "CKDocumentCollection.h"
#import "JSONKit.h"
#import <objc/runtime.h>

//behaviour
NSString* CKMappingObjectKey = @"@object";
NSString* CKMappingClassKey = @"@class";
NSString* CKMappingMappingsKey = @"@mappings";
NSString* CKMappingReverseMappingsKey = @"@reverseMappings";
NSString* CKMappingtargetKeyPathKey = @"@keyPath";
NSString* CKMappingSelfKey = @"@self";

//defaults
NSString* CKMappingRequieredKey = @"@required";
NSString* CKMappingDefaultValueKey = @"@defaultValue";
NSString* CKMappingTransformSelectorKey = @"@transformSelector";
NSString* CKMappingTransformSelectorClassKey = @"@transformClass";

//list managememt
NSString* CKMappingClearContainerKey = @"@clearContent";
NSString* CKMappingInsertAtBeginKey = @"@insertContentAtBegin";



@implementation NSObject (CKMapping2) 

//---------------------------------- Initialization -----------------------------
- (id)initWithObject:(id)sourceObject withMappingsIdentifier:(NSString*)identifier{
    self = [self initWithObject:sourceObject withMappings:[[CKMappingManager defaultManager]mappingsForIdentifier:identifier]];
    return self;
}

- (void)setupWithObject:(id)sourceObject withMappingsIdentifier:(NSString*)identifier{
    [self setupWithObject:sourceObject withMappings:[[CKMappingManager defaultManager]mappingsForIdentifier:identifier]];
}

- (id)initWithObject:(id)sourceObject withMappings:(NSMutableDictionary*)mappings{
    self = [self init];
    [self setupWithObject:sourceObject withMappings:mappings];
    return self;
}

+ (id)objectFromValue:(id)sourceObject withMappingsIdentifier:(NSString*)identifier{
    return [[CKMappingManager defaultManager]objectFromValue:sourceObject withMappingsIdentifier:identifier];
}

// ----------------------  Dictionary parser -------------------------

//Search for @mappings key and resolve reference
- (NSMutableDictionary*)mappingsDefinition:(NSMutableDictionary*)dico{
    id mappingsDefinition = [dico objectForKey:CKMappingMappingsKey];
    if([mappingsDefinition isKindOfClass:[NSString class]]){
        return [dico dictionaryForKey:mappingsDefinition];
    }
    else if([mappingsDefinition isKindOfClass:[NSDictionary class]]){
        return mappingsDefinition;
    }
    return nil;
}

- (NSMutableDictionary*)objectDefinition:(NSMutableDictionary*)dico{
    id objectDefinition = [dico objectForKey:CKMappingObjectKey];
    if(objectDefinition && [objectDefinition isKindOfClass:[NSDictionary class]]){
        return objectDefinition;
    }
    return nil;
}

- (BOOL)boolValueForKey:(NSString*)key inDictionary:(NSMutableDictionary*)dico{
    BOOL bo = NO;
    id object = [dico objectForKey:key];
    if(object){
        bo = [NSValueTransformer convertBoolFromObject:object];
    }
    return bo;
}

- (BOOL)isRequired:(NSMutableDictionary*)dico{
    return [self boolValueForKey:CKMappingRequieredKey inDictionary:dico];
}

- (BOOL)needsToBeCleared:(NSMutableDictionary*)dico{
    return [self boolValueForKey:CKMappingClearContainerKey inDictionary:dico];
}

- (BOOL)insertAtBegin:(NSMutableDictionary*)dico{
    return [self boolValueForKey:CKMappingInsertAtBeginKey inDictionary:dico];
}

- (BOOL)reverseMappings:(NSMutableDictionary*)dico{
    return [self boolValueForKey:CKMappingReverseMappingsKey inDictionary:dico];
}

- (Class)objectClass:(NSMutableDictionary*)dico defaultClass:(Class)c{
    NSString* className = [dico objectForKey:CKMappingClassKey];
    return (className == nil) ? c : NSClassFromString(className);
}

- (Class)transformClass:(NSMutableDictionary*)dico defaultClass:(Class)c{
    NSString* className = [dico objectForKey:CKMappingTransformSelectorClassKey];
    return (className == nil) ? c : NSClassFromString(className);
}

- (SEL)transformSelector:(NSMutableDictionary*)dico{
     NSString* selectorName = [dico objectForKey:CKMappingTransformSelectorKey];
    return (selectorName == nil) ? nil : NSSelectorFromString(selectorName);
}

- (BOOL)isSelf:(NSString*)s{
    return [s isEqualToString:CKMappingSelfKey];
}

- (NSString*)keyPath:(NSMutableDictionary*)dico{
    return [dico objectForKey:CKMappingtargetKeyPathKey];
}

- (NSString*)defaultValue:(NSMutableDictionary*)dico{
    return [dico objectForKey:CKMappingDefaultValueKey];
}

//------------------------------- Mapping Engine ------------------------------

- (id)createObjectOfClass:(Class)c withObject:(id)source withMappings:(NSMutableDictionary*)mappings reversed:(BOOL)reversed{
    id object = [[[c alloc]init] autorelease];
    [object setupWithObject:source withMappings:mappings reversed:reversed];
    return object;
}

+ (id)objectFromValue:(id)sourceObject withMappings:(NSMutableDictionary*)mappings{
    NSMutableDictionary* def = [self objectDefinition:mappings];
    NSAssert(def != nil,@"This method requiers an object definition as root or mappings definition");
    return [self createObjectOfClass:[self objectClass:def defaultClass:nil] withObject:sourceObject withMappings:[self mappingsDefinition:def] reversed:[self reverseMappings:def]];
}

- (void)setupWithObject:(id)sourceObject withMappings:(NSMutableDictionary*)mappings{
    [self setupWithObject:sourceObject withMappings:mappings reversed:NO];
}

- (void)setupPropertyWithKeyPath:(NSString*)keyPath fromObject:(id)other keyPath:(NSString*)otherKeyPath withOptions:(NSMutableDictionary*)options{
    if([self isSelf:keyPath])
        keyPath = nil;
    if([self isSelf:otherKeyPath])
        otherKeyPath = nil;
    
    id value = other;
    if(otherKeyPath != nil && [otherKeyPath length] > 0){
        value = [other valueForKeyPath:otherKeyPath];
    }
    
    //Source value validation
    CKObjectProperty* property = [CKObjectProperty propertyWithObject:self keyPath:keyPath];//THIS WORKS NOT FOR DICTIONARIES AS TARGET ...
    if(value == nil || [value isKindOfClass:[NSNull class]]){
        if([self isRequired:options]){
            NSAssert(NO,@"invalid value");
        }
        else{
            [NSValueTransformer transform:[self defaultValue:options] inProperty:property];
        }
    }
    //Source is ok => apply to target
    else{
        Class targetType = [property type];
        
        //property is a collection
        if([NSObject isKindOf:targetType parentType:[NSArray class]] || [NSObject isKindOf:targetType parentType:[CKDocumentCollection class]]){
            NSMutableDictionary* subObjectDefinition = [self objectDefinition:options];
            
            CKModelObjectPropertyMetaData* metaData = [property metaData];
            Class contentType = [self objectClass:subObjectDefinition defaultClass:[metaData contentType]];
            NSAssert(contentType != nil,@"no Class has been define for collection's objects either in property metaData and in the mappings definition.");
            
            if([self needsToBeCleared:options]){
                [property removeAllObjects];
            }
            
                       
            NSMutableArray* results = [NSMutableArray array];
            NSArray* ar = (NSArray*)value;
            for(id sourceSubObject in ar){
                //create sub object
                id targetSubObject = [[[contentType alloc]init]autorelease];
                //find mappings for sub objects
                id subObjectMappings = [self mappingsDefinition:subObjectDefinition];
                if(!subObjectMappings){
                    subObjectMappings = [options dictionaryForObject:targetSubObject propertyName:nil];
                }
                //map sub object
                [targetSubObject setupWithObject:sourceSubObject withMappings:subObjectMappings];
                //adds sub object
                [results addObject:targetSubObject];
            }
            
            //feed the collection with results
            if([self insertAtBegin:options]){
                [property insertObjects:results atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,[results count])]];
            }
            else{
                [property insertObjects:results atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange([property count],[results count])]];
            }

        }
        //property is an object or a simple property
        else{
            SEL transformSelector = [self transformSelector:options];
            if(transformSelector){
                Class transformSelectorClass = [self transformClass:options defaultClass:targetType];
                id transformedValue = [transformSelectorClass performSelector:transformSelector withObject:value];
                [property setValue:transformedValue];
            }
            else{
                NSMutableDictionary* subObjectDefinition = [self objectDefinition:options];
                Class contentType = [self objectClass:subObjectDefinition defaultClass:[property type]];
                                
                id subObjectMappings = [self mappingsDefinition:subObjectDefinition];
                if(!subObjectMappings){
                    subObjectMappings = [options dictionaryForClass:contentType];
                }
                                
                if(subObjectMappings && ![subObjectMappings isEmpty]){
                    id subObject = [property value];
                    if([subObject isKindOfClass:contentType]){
                        [subObject setupWithObject:value withMappings:subObjectMappings];
                    }
                    else{
                        subObject = [[contentType alloc]initWithObject:value withMappings:subObjectMappings];
                        [property setValue:subObject];
                    }
                }
                else{
                    [NSValueTransformer transform:value inProperty:property];
                }
            }
        }
    }
}

- (void)setupWithObject:(id)sourceObject withMappings:(NSMutableDictionary*)mappings reversed:(BOOL)reversed{
    if(mappings){
        for(NSString* targetKeyPath in [mappings allKeys]){
            if([mappings isReservedKeyWord:targetKeyPath]){
                continue;
            }
            
            id targetObject = [mappings objectForKey:targetKeyPath];
            if([targetObject isKindOfClass:[NSString class]]){
                if(reversed){
                    [self setupPropertyWithKeyPath:(NSString*)targetObject fromObject:sourceObject keyPath:targetKeyPath withOptions:nil];
                }
                else{
                    [self setupPropertyWithKeyPath:targetKeyPath fromObject:sourceObject keyPath:(NSString*)targetObject withOptions:nil];
                }
            }
            else if([targetObject isKindOfClass:[NSDictionary class]]){
                if(reversed){
                    [self setupPropertyWithKeyPath:[self keyPath:targetObject] fromObject:sourceObject keyPath:targetKeyPath withOptions:targetObject];
                }
                else{
                    [self setupPropertyWithKeyPath:targetKeyPath fromObject:sourceObject keyPath:[self keyPath:targetObject] withOptions:targetObject];
                }
            }
        }
    }
}


@end




static CKMappingManager* CKMappingManagerDefault = nil;

@implementation CKMappingManager

+ (CKMappingManager*)defaultManager{
	if(CKMappingManagerDefault == nil){
		CKMappingManagerDefault = [[CKMappingManager alloc]init];
	}
	return CKMappingManagerDefault;
}

- (NSMutableDictionary*)mappingsForObject:(id)object propertyName:(NSString*)propertyName{
	return [self dictionaryForObject:object propertyName:propertyName];
}

- (NSMutableDictionary*)mappingsForIdentifier:(NSString*)identifier{
    if(identifier == nil)
        return nil;
    return [self dictionaryForKey:identifier];
}

- (void)loadContentOfFileNamed:(NSString*)name{
	NSString* path = [[NSBundle mainBundle]pathForResource:name ofType:@"mappings"];
	[self loadContentOfFile:path];
}

- (BOOL)importContentOfFileNamed:(NSString*)name{
	NSString* path = [[NSBundle mainBundle]pathForResource:name ofType:@"mappings"];
	return [self appendContentOfFile:path];
}

- (id)objectFromValue:(id)sourceObject withMappings:(NSMutableDictionary*)mappings{
    return [NSObject objectFromValue:sourceObject withMappings:mappings];
}

- (id)objectFromValue:(id)sourceObject withMappingsIdentifier:(NSString*)identifier{
    return [NSObject objectFromValue:sourceObject withMappings:[self mappingsForIdentifier:identifier]];
}

@end


@implementation NSMutableDictionary (CKStyleManager)

- (NSMutableDictionary*)mappingsForObject:(id)object propertyName:(NSString*)propertyName{
    return [self dictionaryForObject:object propertyName:propertyName];
}

@end