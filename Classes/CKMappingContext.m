//
//  CKMappingContext.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKMappingContext.h"
#import "NSValueTransformer+Additions.h"
#import "NSObject+Runtime.h"
#import "CKProperty.h"
#import "CKCollection.h"
#import "CKCallback.h"
#import <VendorsKit/VendorsKit.h>
#import <objc/runtime.h>
#import "NSError+Additions.h"
#import "NSObject+Invocation.h"



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

NSString * const CKMappingErrorDomain = @"CKMappingErrorDomain";

//behaviour
NSString* CKMappingObjectKey = @"@object";
NSString* CKMappingClassKey = @"@class";
NSString* CKMappingMappingsKey = @"@mappings";
NSString* CKMappingReverseMappingsKey = @"@reverseMappings";
NSString* CKMappingtargetKeyPathKey = @"@keyPath";
NSString* CKMappingSelfKey = @"@self";

//defaults
NSString* CKMappingOptionalKey = @"@optional";
NSString* CKMappingDefaultValueKey = @"@defaultValue";
NSString* CKMappingTransformSelectorKey = @"@transformSelector";
NSString* CKMappingTransformSelectorClassKey = @"@transformClass";
NSString* CKMappingTransformUserDataKey = @"@transformUserData";
NSString* CKMappingTransformCallbackKey = @"@transformCallback";

//list managememt
NSString* CKMappingClearContainerKey = @"@clearContent";
NSString* CKMappingInsertAtBeginKey = @"@insertContentAtBegin";


/**
 */
@interface NSDictionary ()
- (BOOL)isReservedKeyWord:(NSString*)key;
@end

//CKMappingManager

@interface CKMappingManager : CKCascadingTree {
}

+ (CKMappingManager*)defaultManager;

- (void)loadContentOfFileNamed:(NSString*)name;
- (BOOL)importContentOfFileNamed:(NSString*)name;


- (id)objectFromValue:(id)sourceObject withMappings:(NSMutableDictionary*)mappings reversed:(BOOL)reversed error:(NSError**)error;
- (id)objectFromValue:(id)sourceObject withMappingsIdentifier:(id)identifier reversed:(BOOL)reversed error:(NSError**)error;

- (NSMutableDictionary*)mappingsForObject:(id)object propertyName:(NSString*)propertyName;
- (NSMutableDictionary*)mappingsForIdentifier:(id)identifier;

@end

//NSMutableDictionary (CKMappingManager)

@interface NSMutableDictionary (CKMappingManager)

- (NSMutableDictionary*)mappingsForObject:(id)object propertyName:(NSString*)propertyName;

@end


@implementation NSMutableDictionary (CKStyleManager)

- (NSMutableDictionary*)mappingsForObject:(id)object propertyName:(NSString*)propertyName{
    return [self dictionaryForObject:object propertyName:propertyName];
}

@end

//NSObject (CKMapping2) 

@interface NSObject (CKMapping2) 

- (id)initWithObject:(id)sourceObject withMappings:(NSMutableDictionary*)mappings error:(NSError**)error;
- (BOOL)setupWithObject:(id)sourceObject withMappings:(NSMutableDictionary*)mappings error:(NSError**)error;
- (BOOL)setupWithObject:(id)sourceObject withMappings:(NSMutableDictionary*)mappings reversed:(BOOL)reversed error:(NSError**)error;

- (id)initWithObject:(id)sourceObject withMappingsIdentifier:(id)identifier error:(NSError**)error;
- (BOOL)setupWithObject:(id)sourceObject withMappingsIdentifier:(id)identifier error:(NSError**)error;

+ (id)objectFromValue:(id)sourceObject withMappings:(NSMutableDictionary*)mappings reversed:(BOOL)reversed error:(NSError**)error;
+ (id)objectFromValue:(id)sourceObject withMappingsIdentifier:(id)identifier reversed:(BOOL)reversed error:(NSError**)error;

@end


@implementation NSObject (CKMapping2) 

//---------------------------------- Initialization -----------------------------
- (id)initWithObject:(id)sourceObject withMappingsIdentifier:(id)identifier error:(NSError**)error{
    self = [self initWithObject:sourceObject withMappings:[[CKMappingManager defaultManager]mappingsForIdentifier:identifier] error:error];
    return self;
}

- (BOOL)setupWithObject:(id)sourceObject withMappingsIdentifier:(id)identifier error:(NSError**)error{
    return [self setupWithObject:sourceObject withMappings:[[CKMappingManager defaultManager]mappingsForIdentifier:identifier] error:error];
}

- (id)initWithObject:(id)sourceObject withMappings:(NSMutableDictionary*)mappings error:(NSError**)error{
    self = [self init];
    [self setupWithObject:sourceObject withMappings:mappings error:error];
    return self;
}

+ (id)objectFromValue:(id)sourceObject withMappingsIdentifier:(id)identifier reversed:(BOOL)reversed error:(NSError**)error{
    return [[CKMappingManager defaultManager]objectFromValue:sourceObject withMappingsIdentifier:identifier reversed:reversed error:error];
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
    return ![self boolValueForKey:CKMappingOptionalKey inDictionary:dico];
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
    if(!className){
        id subObjectMappings = [self mappingsDefinition:dico];
        if(subObjectMappings){
            className = [subObjectMappings objectForKey:CKMappingClassKey];
        }
    }
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

- (CKCallback*)transformCallback:(NSMutableDictionary*)dico{
    return [dico objectForKey:CKMappingTransformCallbackKey];
}

- (id)transformUserData:(NSMutableDictionary*)dico{
    return [dico objectForKey:CKMappingTransformUserDataKey];
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

- (id)createObjectOfClass:(Class)c withObject:(id)source withMappings:(NSMutableDictionary*)mappings reversed:(BOOL)reversed error:(NSError**)error{
    id object = [[[c alloc]init] autorelease];
    [object setupWithObject:source withMappings:mappings reversed:reversed error:error];
    return object;
}

+ (id)objectFromValue:(id)sourceObject withMappings:(NSMutableDictionary*)mappings reversed:(BOOL)reversed error:(NSError**)error{
    NSMutableDictionary* def = [self objectDefinition:mappings];
    id result = nil;
    if(def != nil){
        result = [self createObjectOfClass:[self objectClass:def defaultClass:nil] withObject:sourceObject withMappings:[self mappingsDefinition:def] reversed:(reversed || [self reverseMappings:def]) error:error];
    }
    else{
        NSString* className = [mappings objectForKey:CKMappingClassKey];
        if(className){
            Class c = NSClassFromString(className);
            result = [self createObjectOfClass:c withObject:sourceObject withMappings:mappings reversed:NO error:error];
        }
    }
    
    return result;
}

- (BOOL)setupWithObject:(id)sourceObject withMappings:(NSMutableDictionary*)mappings error:(NSError**)error{
    return [self setupWithObject:sourceObject withMappings:mappings reversed:NO error:error];
}

- (BOOL)setupPropertyWithKeyPath:(NSString*)keyPath fromValue:(id)other keyPath:(NSString*)otherKeyPath withOptions:(NSMutableDictionary*)options reversed:(BOOL)reversed error:(NSError**)error{
    
    if([self isSelf:keyPath])
        keyPath = nil;
    if([self isSelf:otherKeyPath])
        otherKeyPath = nil;
    
    id value = other;
    if(otherKeyPath != nil && [otherKeyPath length] > 0){
        value = [other valueForKeyPath:otherKeyPath];
    }
    
    //Source value validation
    CKProperty* property = [CKProperty propertyWithObject:self keyPath:keyPath];//THIS WORKS NOT FOR DICTIONARIES AS TARGET ...
    CKClassPropertyDescriptor* descriptor = [property descriptor];
	if(keyPath && !descriptor){
		NSString* details = [NSString stringWithFormat:@"Trying to access to a property that doesn't exist : %@",property];
        *error = aggregateError(*error,CKMappingErrorDomain,CKMappingErrorCodeInvalidProperty,details);
		return NO;
	}
	if(value == nil || [value isKindOfClass:[NSNull class]]){
        if([self isRequired:options]){
            NSString* details = [NSString stringWithFormat:@"Missing requiered value with keyPath : '%@' in source value : %@",otherKeyPath,other];
            *error = aggregateError(*error,CKMappingErrorDomain,CKMappingErrorCodeMissingRequieredValue,details);
            return NO;
        }
        else if([options containsObjectForKey:CKMappingDefaultValueKey]){
            [NSValueTransformer transform:[self defaultValue:options] inProperty:property];
        }
    }
    //Source is ok => apply to target
    else{
        Class targetType = [property type];
        
        //property is a collection
        if([NSObject isClass:targetType kindOfClass:[NSArray class]] || [NSObject isClass:targetType kindOfClass:[CKCollection class]]){
            NSMutableDictionary* subObjectDefinition = [self objectDefinition:options];
            
            CKPropertyExtendedAttributes* attributes = [property extendedAttributes];
            Class contentType = [self objectClass:subObjectDefinition defaultClass:[attributes contentType]];
            
            id subObjectMappings = [self mappingsDefinition:subObjectDefinition];
            if(!subObjectMappings && contentType != nil){
                subObjectMappings = [options dictionaryForClass:contentType];
            }
            else if((contentType == nil || contentType == [attributes contentType]) && subObjectMappings){
                NSString* className = [subObjectMappings objectForKey:CKMappingClassKey];
                if(className){
                    contentType = NSClassFromString(className);
                }
            }
            
            if(contentType == nil){
                NSString* details = [NSString stringWithFormat:@"Could not find any valid class to create an object in property : %@",property];
                NSString* details2 = [NSString stringWithFormat:@"The class could be defined in JSON object definition using '%@' or in property attributes",CKMappingClassKey];
                *error = aggregateError(*error,CKMappingErrorDomain,CKMappingErrorCodeInvalidObjectClass,[NSString stringWithFormat:@"%@\n%@",details,details2]);
                return NO;
            }
			
			if([NSObject isClass:targetType kindOfClass:[NSArray class]]){
				id propertyArray = [property value];
				if(!propertyArray){
					[property setValue:[NSMutableArray array]];
				}
				else if(![propertyArray isKindOfClass:[NSMutableArray class]]){
					NSString* details = [NSString stringWithFormat:@"The property %@ must inherit NSMutableArray",property];
                    *error = aggregateError(*error,CKMappingErrorDomain,CKMappingErrorCodeInvalidProperty,details);
					return NO;
                    
				}
			}
			else{
				id propertyCollection = [property value];
				if(!propertyCollection){
					NSString* details = [NSString stringWithFormat:@"The property %@ is a nil collection and must be instanciated. \nYou should set its attributes as creatable or set the property in the postInit method of its object.",property];
                    *error = aggregateError(*error,CKMappingErrorDomain,CKMappingErrorCodeInvalidProperty,details);
					return NO;
				}
			}
            
            if([self needsToBeCleared:options]){
                [property removeAllObjects];
            }
            
            NSArray* ar = nil;
            if([value isKindOfClass:[NSArray class]]){
                ar = value;
            }
            else if([value isKindOfClass:[CKCollection class]]){
                CKCollection* collection = (CKCollection*)value;
                ar = [collection allObjects];
            }
            
            NSArray* results = nil;
            if(subObjectMappings){
                NSMutableArray* createdObjects = [NSMutableArray array];
                for(id sourceSubObject in ar){
                    //create sub object
                    id targetSubObject = [[[contentType alloc]init]autorelease];
                    //map sub object
                    [targetSubObject setupWithObject:sourceSubObject withMappings:subObjectMappings reversed:([self reverseMappings:subObjectMappings] || reversed) error:error];
                    //adds sub object
                    [createdObjects addObject:targetSubObject];
                }
                results = createdObjects;
            }
            else if(contentType){
                NSMutableArray* createdObjects = [NSMutableArray array];
                for(id sourceSubObject in ar){
                    id targetSubObject = [NSValueTransformer transform:sourceSubObject toClass:contentType];
                    [createdObjects addObject:targetSubObject];
                }
                results = createdObjects;
            }
            else{
                results = ar;
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
            //FIXME regroup the error for requiered and optional in a method not to repeet code !
            SEL transformSelector = [self transformSelector:options];
            CKCallback* callback = [self transformCallback:options];
            if(callback){
                id transformUserData = [self transformUserData:options];
                if(transformUserData){
                    NSString* details = [NSString stringWithFormat:@"Transform selectors are not supported for value with keyPath : '%@' in source value : %@",otherKeyPath,other];
                    *error = aggregateError(*error,CKMappingErrorDomain,CKMappingErrorCodeTransformNotSupported,details);
                }
                
                id transformedValue = [callback execute:value];
                if(!transformedValue){
                    if([self isRequired:options]){
                        NSString* details = [NSString stringWithFormat:@"Transform problem for requiered value with keyPath : '%@' in source value : %@",otherKeyPath,other];
                        *error = aggregateError(*error,CKMappingErrorDomain,CKMappingErrorCodeMissingRequieredValue,details);
                        return NO;
                    }
                    else if([options containsObjectForKey:CKMappingDefaultValueKey]){
                        [NSValueTransformer transform:[self defaultValue:options] inProperty:property];
                    }
                }
                else{
                    [property setValue:transformedValue];
                }
            }
            else if(transformSelector){
                id transformUserData = [self transformUserData:options];
                Class transformSelectorClass = [self transformClass:options defaultClass:targetType];
                id transformedValue = nil;
                if(transformUserData){
                    NSMethodSignature *signature = [transformSelectorClass methodSignatureForSelector:transformSelector];
                    
                    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
                    [invocation setSelector:transformSelector];
                    [invocation setTarget:transformSelectorClass];
                    [invocation setArgument:&value
                                    atIndex:2];
                    [invocation setArgument:&transformUserData
                                    atIndex:3];
                    [invocation setArgument:&error
                                    atIndex:4];
                    [invocation invoke];
                    
                    void* returnValue = nil;
                    [invocation getReturnValue:&returnValue];
                    transformedValue = (id)returnValue;
                }
                else{
                    transformedValue = [transformSelectorClass performSelector:transformSelector withObject:value withObject:(id)error];
                }
                
                if(!transformedValue){
                    if([self isRequired:options]){
                        NSString* details = [NSString stringWithFormat:@"Transform problem for requiered value with keyPath : '%@' in source value : %@",otherKeyPath,other];
                        *error = aggregateError(*error,CKMappingErrorDomain,CKMappingErrorCodeMissingRequieredValue,details);
                        return NO;
                    }
                    else if([options containsObjectForKey:CKMappingDefaultValueKey]){
                        [NSValueTransformer transform:[self defaultValue:options] inProperty:property];
                    }
                }
                else{
                    [property setValue:transformedValue];
                }
            }
            else{
                NSMutableDictionary* subObjectDefinition = [self objectDefinition:options];
                Class contentType = [self objectClass:subObjectDefinition defaultClass:[property type]];
                
                id subObjectMappings = [self mappingsDefinition:subObjectDefinition];
                if(!subObjectMappings && contentType){
                    subObjectMappings = [options dictionaryForClass:contentType];
                }
                else if((contentType == nil || contentType == [property type]) && subObjectMappings){
                    NSString* className = [subObjectMappings objectForKey:CKMappingClassKey];
                    if(className){
                        contentType = NSClassFromString(className);
                    }
                }
                
                if(subObjectMappings && ![subObjectMappings isEmpty]){
                    id subObject = [property value];
                    if([subObject isKindOfClass:contentType]){
                        [subObject setupWithObject:value withMappings:subObjectMappings reversed:([self reverseMappings:subObjectMappings] || reversed) error:error];
                    }
                    else{
                        subObject = [[[contentType alloc]init]autorelease];
                        [subObject setupWithObject:value withMappings:subObjectMappings reversed:([self reverseMappings:subObjectMappings] || reversed) error:error];
                        [property setValue:subObject];
                    }
                }
                else{
                    [NSValueTransformer transform:value inProperty:property];
                }
            }
        }
    }
    
    return (*error != nil);
}

- (BOOL)setupWithObject:(id)sourceObject withMappings:(NSMutableDictionary*)mappings reversed:(BOOL)reversed error:(NSError**)error{
    BOOL success = NO;
    
    if(mappings){
        for(NSString* targetKeyPath in [mappings allKeys]){
            if([mappings isReservedKeyWord:targetKeyPath]
               || [targetKeyPath isEqualToString:CKMappingClassKey]
               || [targetKeyPath isEqualToString:CKMappingObjectKey]
               || [targetKeyPath isEqualToString:CKMappingMappingsKey]
               || [targetKeyPath isEqualToString:CKMappingMappingsKey]
               || [targetKeyPath isEqualToString:CKMappingReverseMappingsKey]
               || [targetKeyPath isEqualToString:CKMappingtargetKeyPathKey]
               || [targetKeyPath isEqualToString:CKMappingOptionalKey]
               || [targetKeyPath isEqualToString:CKMappingDefaultValueKey]
               || [targetKeyPath isEqualToString:CKMappingTransformSelectorKey]
               || [targetKeyPath isEqualToString:CKMappingTransformSelectorClassKey]
               || [targetKeyPath isEqualToString:CKMappingTransformCallbackKey]
               || [targetKeyPath isEqualToString:CKMappingClearContainerKey]
               || [targetKeyPath isEqualToString:CKMappingInsertAtBeginKey]){
                continue;
            }
            
            id targetObject = [mappings objectForKey:targetKeyPath];
            if([targetObject isKindOfClass:[NSString class]]){
                if(reversed){
                    success = [self setupPropertyWithKeyPath:(NSString*)targetObject fromValue:sourceObject keyPath:targetKeyPath withOptions:nil reversed:reversed error:error];
                }
                else{
                    success = [self setupPropertyWithKeyPath:targetKeyPath fromValue:sourceObject keyPath:(NSString*)targetObject withOptions:nil reversed:reversed error:error];
                }
            }
            else if([targetObject isKindOfClass:[NSDictionary class]]){
                if(reversed){
                    success = [self setupPropertyWithKeyPath:[self keyPath:targetObject] fromValue:sourceObject keyPath:targetKeyPath withOptions:targetObject reversed:reversed error:error];
                }
                else{
                    success = [self setupPropertyWithKeyPath:targetKeyPath fromValue:sourceObject keyPath:[self keyPath:targetObject] withOptions:targetObject reversed:reversed error:error];
                }
            }
        }
    }
    
    return success;
}


@end

//CKMappingManager

static CKMappingManager* CKMappingManagerDefault = nil;

@implementation CKMappingManager

+ (CKMappingManager*)defaultManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CKMappingManagerDefault = [[CKMappingManager alloc]init];
    });
	return CKMappingManagerDefault;
}



- (NSMutableDictionary*)mappingsForObject:(id)object propertyName:(NSString*)propertyName{
	return [self dictionaryForObject:object propertyName:propertyName];
}

- (NSMutableDictionary*)mappingsForIdentifier:(id)identifier{
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

- (id)objectFromValue:(id)sourceObject withMappings:(NSMutableDictionary*)mappings reversed:(BOOL)reversed error:(NSError**)error{
    return [NSObject objectFromValue:sourceObject withMappings:mappings reversed:reversed error:error];
}

- (id)objectFromValue:(id)sourceObject withMappingsIdentifier:(id)identifier reversed:(BOOL)reversed error:(NSError**)error{
    return [NSObject objectFromValue:sourceObject withMappings:[self mappingsForIdentifier:identifier] reversed:reversed error:error];
}

@end


@interface CKMappingContext()
@property(nonatomic,retain)NSMutableDictionary* dictionary;
- (id)initWithDictionary:(NSMutableDictionary*)dictionary identifier:(id)theidentifier;
@end


@implementation CKMappingContext{
    NSMutableDictionary* _dictionary;
    id _identifier;
}

@synthesize  dictionary = _dictionary;
@synthesize  identifier = _identifier;

- (id)initWithDictionary:(NSMutableDictionary*)thedictionary identifier:(id)theidentifier{
    self = [super init];
    self.dictionary = thedictionary;
    self.identifier = theidentifier;
    return self;
}

- (void)dealloc{
    [_dictionary release];
    _dictionary = nil;
    [_identifier release];
    _identifier = nil;
    [super dealloc];
}

+ (void)loadContentOfFileNamed:(NSString*)name{
    [[CKMappingManager defaultManager]loadContentOfFileNamed:name];
}

+ (CKMappingContext*)contextWithIdentifier:(id)identifier{
    NSMutableDictionary* dico = [[CKMappingManager defaultManager]mappingsForIdentifier:identifier];
    if(dico){
        return [[[CKMappingContext alloc]initWithDictionary:dico identifier:identifier]autorelease];
    }
    return [[[CKMappingContext alloc]initWithDictionary:[NSMutableDictionary dictionary] identifier:identifier]autorelease];
}

+ (void)clearMappingsContextWithIdentifier:(id)identifier{
    [[CKMappingManager defaultManager]removeDictionaryForKey:identifier];
}

- (BOOL)isEmpty{
    return [[self dictionary]isEmpty];
}

- (NSMutableDictionary*)arrayDefinitionWithMappings:(NSMutableDictionary*)mappings objectClass:(Class)type{
    NSMutableDictionary* dico = [NSMutableDictionary dictionary];
    [dico setObject:@"NSMutableArray" forKey:CKMappingClassKey];
    NSMutableDictionary* selfDefinition = [NSMutableDictionary dictionary];
    [selfDefinition setObject:CKMappingSelfKey forKey:CKMappingtargetKeyPathKey];
    NSMutableDictionary* objectDefinition = [NSMutableDictionary dictionary];
    if(type){
        [objectDefinition setObject:[type description] forKey:CKMappingClassKey];
    }
    [objectDefinition setObject:mappings forKey:CKMappingMappingsKey];
    [selfDefinition setObject:objectDefinition forKey:CKMappingObjectKey];
    [dico setObject:selfDefinition forKey:CKMappingSelfKey];
    return dico;
}

//ARRAYS

- (NSArray*)objectsFromValue:(id)value ofClass:(Class)type error:(NSError**)error{
    return (NSArray*)[self objectsFromValue:value ofClass:type reversed:NO error:error];
}

- (NSArray*)objectsFromValue:(id)value ofClass:(Class)type reversed:(BOOL)reversed error:(NSError**)error{
    if(![value isKindOfClass:[NSArray class]] && ![value isKindOfClass:[CKCollection class]]){
        *error = aggregateError(*error,CKMappingErrorDomain,CKMappingErrorCodeInvalidSourceData,@"'value' must be a NSArray or a CKCollection");
        return nil;
    }
    return [NSObject objectFromValue:value withMappings:[self arrayDefinitionWithMappings:[self dictionary] objectClass:type] reversed:reversed error:error];
}

- (NSArray*)objectsFromValue:(id)value error:(NSError**)error{
    return [self objectsFromValue:(id)value ofClass:nil error:error];
}

- (NSArray*)objectsFromValue:(id)value reversed:(BOOL)reversed error:(NSError**)error{
    return [self objectsFromValue:(id)value ofClass:nil reversed:reversed error:error];
}

//OBJECT
- (id)objectFromValue:(id)value error:(NSError**)error{
    return [self objectFromValue:value reversed:NO error:error];
}

- (id)objectFromValue:(id)value reversed:(BOOL)reversed error:(NSError**)error{
    /*if(![value isKindOfClass:[NSDictionary class]]){
     *error = [NSError errorWithDomain:CKMappingErrorDomain code:CKMappingErrorCodeInvalidSourceData 
     userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"'value' must be a NSDictionary",CKMappingErrorDetailsKey, nil]];
     return nil;
     }*/
    return [[CKMappingManager defaultManager]objectFromValue:value withMappings:[self dictionary] reversed:reversed error:error];
}

- (id)objectFromValue:(id)value ofClass:(Class)type error:(NSError**)error{
    return [self objectFromValue:value ofClass:type reversed:NO error:error];
}

- (id)objectFromValue:(id)value ofClass:(Class)type reversed:(BOOL)reversed error:(NSError**)error{
    if(![value isKindOfClass:[NSDictionary class]]){
        *error = aggregateError(*error,CKMappingErrorDomain,CKMappingErrorCodeInvalidSourceData,@"'value' must be a NSDictionary");
        return nil;
    }
    id object = [[[type alloc]init] autorelease];
    [self mapValue:value toObject:object reversed:reversed error:error];
    return object;
}

//INSTANCE
- (id)mapValue:(id)value toObject:(id)object error:(NSError**)error{
    return [self mapValue:value toObject:object reversed:NO error:error];
}

- (id)mapValue:(id)value toObject:(id)object reversed:(BOOL)reversed error:(NSError**)error{
    [object setupWithObject:value withMappings:[self dictionary] reversed:reversed error:error];
    return object;
}


//SETUP
- (void)setObjectClass:(Class)type{
    NSMutableDictionary* dictionary = [self  dictionary];
    [dictionary setObject:[type description] forKey:CKMappingClassKey];
}

- (void)setKeyPath:(NSString*)keyPath fromKeyPath:(NSString*)sourceKeyPath{
    NSMutableDictionary* dictionary = [self  dictionary];
    [dictionary setObject:sourceKeyPath forKey:keyPath];
}

- (void)setKeyPath:(NSString*)keyPath fromKeyPath:(NSString*)sourceKeyPath transformBlock:(id(^)(id source))transformBlock{
    NSMutableDictionary* dictionary = [self  dictionary];
    NSMutableDictionary* mapping = [NSMutableDictionary dictionary];
    [mapping setObject:sourceKeyPath forKey:CKMappingtargetKeyPathKey];
    [mapping setObject:[CKCallback callbackWithBlock:transformBlock] forKey:CKMappingTransformCallbackKey];
    [dictionary setObject:mapping forKey:keyPath];
}

- (void)setKeyPath:(NSString*)keyPath fromKeyPath:(NSString*)sourceKeyPath transformTarget:(id)target action:(SEL)action{
    NSMutableDictionary* dictionary = [self  dictionary];
    NSMutableDictionary* mapping = [NSMutableDictionary dictionary];
    [mapping setObject:sourceKeyPath forKey:CKMappingtargetKeyPathKey];
    [mapping setObject:[CKCallback callbackWithTarget:target action:action] forKey:CKMappingTransformCallbackKey];
    [dictionary setObject:mapping forKey:keyPath];
}

- (void)setKeyPath:(NSString*)keyPath fromKeyPath:(NSString*)sourceKeyPath defaultValue:(id)value{
    NSMutableDictionary* dictionary = [self  dictionary];
    NSMutableDictionary* mapping = [NSMutableDictionary dictionary];
    [mapping setObject:sourceKeyPath forKey:CKMappingtargetKeyPathKey];
    [mapping setObject:value forKey:CKMappingDefaultValueKey];
    [dictionary setObject:mapping forKey:keyPath];
}

- (void)setKeyPath:(NSString*)keyPath fromKeyPath:(NSString*)sourceKeyPath defaultValue:(id)value transformBlock:(id(^)(id source))transformBlock{
    NSMutableDictionary* dictionary = [self dictionary];
    NSMutableDictionary* mapping = [NSMutableDictionary dictionary];
    [mapping setObject:sourceKeyPath forKey:CKMappingtargetKeyPathKey];
    [mapping setObject:[CKCallback callbackWithBlock:transformBlock] forKey:CKMappingTransformCallbackKey];
    [mapping setObject:value forKey:CKMappingDefaultValueKey];
    [dictionary setObject:mapping forKey:keyPath];
}

- (void)setKeyPath:(NSString*)keyPath fromKeyPath:(NSString*)sourceKeyPath defaultValue:(id)value transformTarget:(id)target action:(SEL)action{
    NSMutableDictionary* dictionary = [self  dictionary];
    NSMutableDictionary* mapping = [NSMutableDictionary dictionary];
    [mapping setObject:sourceKeyPath forKey:CKMappingtargetKeyPathKey];
    [mapping setObject:[CKCallback callbackWithTarget:target action:action] forKey:CKMappingTransformCallbackKey];
    [mapping setObject:value forKey:CKMappingDefaultValueKey];
    [dictionary setObject:mapping forKey:keyPath];
}

- (void)setKeyPath:(NSString*)keyPath fromKeyPath:(NSString*)sourceKeyPath optional:(BOOL)optional{
    NSMutableDictionary* dictionary = [self  dictionary];
    NSMutableDictionary* mapping = [NSMutableDictionary dictionary];
    [mapping setObject:sourceKeyPath forKey:CKMappingtargetKeyPathKey];
    [mapping setObject:[NSNumber numberWithBool:optional] forKey:CKMappingOptionalKey];
    [dictionary setObject:mapping forKey:keyPath];
}

- (void)setKeyPath:(NSString*)keyPath fromKeyPath:(NSString*)sourceKeyPath optional:(BOOL)optional transformBlock:(id(^)(id source))transformBlock{
    NSMutableDictionary* dictionary = [self dictionary];
    NSMutableDictionary* mapping = [NSMutableDictionary dictionary];
    [mapping setObject:sourceKeyPath forKey:CKMappingtargetKeyPathKey];
    [mapping setObject:[CKCallback callbackWithBlock:transformBlock] forKey:CKMappingTransformCallbackKey];
    [mapping setObject:[NSNumber numberWithBool:optional] forKey:CKMappingOptionalKey];
    [dictionary setObject:mapping forKey:keyPath];
}

- (void)setKeyPath:(NSString*)keyPath fromKeyPath:(NSString*)sourceKeyPath optional:(BOOL)optional transformTarget:(id)target action:(SEL)action{
    NSMutableDictionary* dictionary = [self  dictionary];
    NSMutableDictionary* mapping = [NSMutableDictionary dictionary];
    [mapping setObject:sourceKeyPath forKey:CKMappingtargetKeyPathKey];
    [mapping setObject:[CKCallback callbackWithTarget:target action:action] forKey:CKMappingTransformCallbackKey];
    [mapping setObject:[NSNumber numberWithBool:optional] forKey:CKMappingOptionalKey];
    [dictionary setObject:mapping forKey:keyPath];
}

- (void)setKeyPath:(NSString*)keyPath fromKeyPath:(NSString*)sourceKeyPath objectClass:(Class)objectClass withMappingsContextIdentifier:(id)contextIdentifier{
    NSMutableDictionary* dictionary = [self  dictionary];
    NSMutableDictionary* mapping = [NSMutableDictionary dictionary];
    [mapping setObject:sourceKeyPath forKey:CKMappingtargetKeyPathKey];
    NSMutableDictionary* objectDefinition = [NSMutableDictionary dictionary];
    [mapping setObject:objectDefinition forKey:CKMappingObjectKey];
    [objectDefinition setObject:[objectClass description] forKey:CKMappingClassKey];
    [objectDefinition setObject:contextIdentifier forKey:CKMappingMappingsKey];
    [dictionary setObject:mapping forKey:keyPath];
}

- (void)setKeyPath:(NSString*)keyPath fromKeyPath:(NSString*)sourceKeyPath optional:(BOOL)optional objectClass:(Class)objectClass withMappingsContextIdentifier:(id)contextIdentifier{
    NSMutableDictionary* dictionary = [self  dictionary];
    NSMutableDictionary* mapping = [NSMutableDictionary dictionary];
    [mapping setObject:sourceKeyPath forKey:CKMappingtargetKeyPathKey];
    [mapping setObject:[NSNumber numberWithBool:optional] forKey:CKMappingOptionalKey];
    NSMutableDictionary* objectDefinition = [NSMutableDictionary dictionary];
    [mapping setObject:objectDefinition forKey:CKMappingObjectKey];
    [objectDefinition setObject:[objectClass description] forKey:CKMappingClassKey];
    [objectDefinition setObject:contextIdentifier forKey:CKMappingMappingsKey];
    [dictionary setObject:mapping forKey:keyPath];
}

- (void)setKeyPath:(NSString*)keyPath fromKeyPath:(NSString*)sourceKeyPath  withMappingsContextIdentifier:(id)contextIdentifier{
    NSMutableDictionary* dictionary = [self  dictionary];
    NSMutableDictionary* mapping = [NSMutableDictionary dictionary];
    [mapping setObject:sourceKeyPath forKey:CKMappingtargetKeyPathKey];
    NSMutableDictionary* objectDefinition = [NSMutableDictionary dictionary];
    [mapping setObject:objectDefinition forKey:CKMappingObjectKey];
    [objectDefinition setObject:contextIdentifier forKey:CKMappingMappingsKey];
    [dictionary setObject:mapping forKey:keyPath];
}

- (void)setKeyPath:(NSString*)keyPath fromKeyPath:(NSString*)sourceKeyPath optional:(BOOL)optional  withMappingsContextIdentifier:(id)contextIdentifier{
    NSMutableDictionary* dictionary = [self  dictionary];
    NSMutableDictionary* mapping = [NSMutableDictionary dictionary];
    [mapping setObject:sourceKeyPath forKey:CKMappingtargetKeyPathKey];
    [mapping setObject:[NSNumber numberWithBool:optional] forKey:CKMappingOptionalKey];
    NSMutableDictionary* objectDefinition = [NSMutableDictionary dictionary];
    [mapping setObject:objectDefinition forKey:CKMappingObjectKey];
    [objectDefinition setObject:contextIdentifier forKey:CKMappingMappingsKey];
    [dictionary setObject:mapping forKey:keyPath];
}

@end
