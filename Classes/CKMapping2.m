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

NSString* CKMappingRequieredKey = @"requiered";
NSString* CKMappingtargetKeyPath = @"keyPath";
NSString* CKMappingContentType = @"contentType";
NSString* CKMappingClearContainer = @"clearContent";
NSString* CKMappingInsertAtBegin = @"insertContentAtBegin";
NSString* CKMappingTransformSelector = @"transformSelector";

@implementation NSObject (CKMapping2) 

+ (NSDictionary*)mappingsInFileNamed:(NSString*)fileName{
	NSString* path = [[NSBundle mainBundle]pathForResource:fileName ofType:@"mappings"];
    
    //Parse file with validation
	NSData* fileData = [NSData dataWithContentsOfFile:path];
	NSError* error = nil;
    id result = [fileData mutableObjectFromJSONDataWithParseOptions:JKParseOptionValidFlags error:&error];
	NSAssert([result isKindOfClass:[NSDictionary class]],@"invalid format in mappings file '%@'\nat line : '%@'\nwith error : '%@'",[path lastPathComponent],[[error userInfo]objectForKey:@"JKLineNumberKey"],[[error userInfo]objectForKey:@"NSLocalizedDescription"]);
    
    return (NSDictionary*)result;
}

- (id)initWithObject:(id)sourceObject withMappingsInFileNamed:(NSString*)fileName{
    self = [self initWithObject:sourceObject withMappings:[[self class] mappingsInFileNamed:fileName]];
    return self;
}

- (void)setupWithObject:(id)sourceObject withMappingsInFileNamed:(NSString*)fileName{
    [self setupWithObject:sourceObject withMappings:[[self class] mappingsInFileNamed:fileName]];
}

- (id)initWithObject:(id)sourceObject withMappings:(NSDictionary*)mappings{
    self = [self init];
    [self setupWithObject:sourceObject withMappings:mappings];
    return self;
}

- (void)setupWithObject:(id)sourceObject withMappings:(NSDictionary*)mappings{
   //serach for the corresponding mapping dictionary
    //THIS COULD BE REPLACED BY A CKCASCADINGTREE ...
    
    Class selfClass = [self class];
    NSDictionary* mappingsForClass = nil;
    while(selfClass != nil && mappingsForClass == nil){ 
        NSString* className = [selfClass description];
        mappingsForClass = [mappings objectForKey:className];
        selfClass = class_getSuperclass(selfClass);
    }
    
    //Apply mappings
    
    if(mappingsForClass){
        for(NSString* sourceKeyPath in [mappingsForClass allKeys]){
            //SI LES KEYPATH SONT VIDES PRENDRE LES OBJETS DIRECT !!!
            id targetObject = [mappingsForClass objectForKey:sourceKeyPath];
            
            BOOL requiered = NO;
            BOOL clearContainer = NO;
            BOOL insertAtBegin = NO;
            NSString* targetKeyPath = nil;
            SEL transformSelector = nil;
            Class contentType = nil;
            if([targetObject isKindOfClass:[NSDictionary class]]){
                id requieredObject = [targetObject objectForKey:CKMappingRequieredKey];
                if(requieredObject){
                    requiered = [NSValueTransformer convertBoolFromObject:requieredObject];
                }
                targetKeyPath = [targetObject objectForKey:CKMappingtargetKeyPath];
                
                NSString* contentTypeName = [targetObject objectForKey:CKMappingContentType];
                if(contentTypeName){
                    contentType = NSClassFromString(contentTypeName);
                }
                
                id clearContainerObject = [targetObject objectForKey:CKMappingClearContainer];
                if(clearContainerObject){
                    clearContainer = [NSValueTransformer convertBoolFromObject:clearContainerObject];
                }
                
                id insertAtBeginObject = [targetObject objectForKey:CKMappingInsertAtBegin];
                if(insertAtBeginObject){
                    insertAtBegin = [NSValueTransformer convertBoolFromObject:insertAtBeginObject];
                }
                
                NSString* transformSelectorName = [targetObject objectForKey:CKMappingTransformSelector];
                if(transformSelectorName){
                    transformSelector = NSSelectorFromString(transformSelectorName);
                }
            }
            else if([targetObject isKindOfClass:[NSString class]]){
                targetKeyPath = (NSString*)targetObject;
            }
            
            if(targetKeyPath){
                id value = sourceObject;
                if(sourceKeyPath != nil && [sourceKeyPath length] > 0){
                    value = [sourceObject valueForKeyPath:sourceKeyPath];
                }
                
                if(value == nil || [value isKindOfClass:[NSNull class]]){
                    if(requiered){
                        NSAssert(NO,@"invalid value");
                    }
                    else{
                        //log ...
                    }
                }
                else{
                    CKObjectProperty* property = [CKObjectProperty propertyWithObject:self keyPath:targetKeyPath];
                    Class targetType = [property type];
                    if([NSObject isKindOf:targetType parentType:[NSArray class]] || [NSObject isKindOf:targetType parentType:[CKDocumentCollection class]]){
                        NSAssert([value isKindOfClass:[NSArray class]],@"Invalid source object for collection target");
                        if(contentType == nil){
                            CKModelObjectPropertyMetaData* metaData = [property metaData];
                            contentType = metaData.contentType;
                        }
                        NSAssert(contentType != nil,@"no contentType has been define for collection");
                        
                        if(clearContainer){
                            [property removeAllObjects];
                        }
                        
                        NSMutableArray* results = [NSMutableArray array];
                        NSArray* ar = (NSArray*)value;
                        for(id sourceSubObject in ar){
                            id targetSubObject = [[[contentType alloc]initWithObject:sourceSubObject withMappings:mappings]autorelease];
                            [results addObject:targetSubObject];
                        }
                        
                        if(insertAtBegin){
                            [property insertObjects:results atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,[results count])]];
                        }
                        else{
                            [property insertObjects:results atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange([property count],[results count])]];
                        }
                    }
                    else{
                        if(transformSelector){
                            id transformedValue = [targetType performSelector:transformSelector withObject:value];
                            [property setValue:transformedValue];
                        }
                        else{
                            id subObjectMappings = [mappings objectForKey:[[[property descriptor]type]description]];
                            if(subObjectMappings){
                                if(contentType == nil){
                                    contentType = [property type];
                                }
                                
                                id subObject = [property value];
                                BOOL done = NO;
                                if(contentType != nil){
                                    if([subObject isKindOfClass:contentType]){
                                        [subObject setupWithObject:value withMappings:mappings];
                                        done = YES;
                                    }
                                    else{
                                        subObject = [[contentType alloc]initWithObject:value withMappings:mappings];
                                        [property setValue:subObject];
                                    }
                                }
                            }
                            else{
                                [NSValueTransformer transform:value inProperty:property];
                            }
                        }
                    }
                }
            }
        }
    }
}

@end