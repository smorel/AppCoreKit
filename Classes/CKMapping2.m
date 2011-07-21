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

NSString* CKMappingRequieredKey = @"@requiered";
NSString* CKMappingtargetKeyPath = @"@keyPath";
NSString* CKMappingContentType = @"@contentType";
NSString* CKMappingClearContainer = @"@clearContent";
NSString* CKMappingInsertAtBegin = @"@insertContentAtBegin";
NSString* CKMappingTransformSelector = @"@transformSelector";

@implementation NSObject (CKMapping2) 

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

- (void)setupWithObject:(id)sourceObject withMappings:(NSMutableDictionary*)mappings{
    //if no mappings specified, try to find a matching one in the root tree.
    if(mappings == nil){
        mappings = [[CKMappingManager defaultManager] mappingsForObject:self propertyName:nil];
    }
    
    if(mappings){
        //mappings can look like and should be applyed on self with targetKeyPath = nil as is and not iterate on keys ...
        //Shoudl think about how to rewrite the recursion ...
        /*
         "$PatientGet" : {
             "KeyPath" : "patients"
             "contentType" : "MyModel",
             "MyModel" : {
                 "@inherits" : ["$MyModel_Light"]
             }
	     },
       */
        
        for(NSString* targetKeyPath in [mappings allKeys]){
            if([mappings isReservedKeyWord:targetKeyPath]){
                continue;
            }
            
            //Read config
            id targetObject = [mappings objectForKey:targetKeyPath];
            
            BOOL requiered = NO;
            BOOL clearContainer = NO;
            BOOL insertAtBegin = NO;
            NSString* sourceKeyPath = nil;
            SEL transformSelector = nil;
            Class contentType = nil;
            NSMutableDictionary* targetDictionary = targetObject;
            if([targetObject isKindOfClass:[NSDictionary class]]){
                id requieredObject = [targetObject objectForKey:CKMappingRequieredKey];
                if(requieredObject){
                    requiered = [NSValueTransformer convertBoolFromObject:requieredObject];
                }
                sourceKeyPath = [targetObject objectForKey:CKMappingtargetKeyPath];
                
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
                sourceKeyPath = (NSString*)targetObject;
                targetDictionary = mappings;
            }
            
            //Apply mappings
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
                        id targetSubObject = [[[contentType alloc]init]autorelease];
                        id subObjectMappings = [targetDictionary dictionaryForObject:targetSubObject propertyName:nil];
                        [targetSubObject setupWithObject:sourceSubObject withMappings:subObjectMappings];
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
                        if(contentType == nil){
                            contentType = [property type];
                        }
                        
                        id subObjectMappings = nil;
                        /*id targetObjectValue = [property value];
                        if(targetObjectValue){
                            subObjectMappings = [targetDictionary dictionaryForObject:targetObjectValue propertyName:property.name];
                        }
                        else */if(contentType){
                            subObjectMappings = [targetDictionary dictionaryForClass:contentType];
                        }
                        
                        if(subObjectMappings && ![subObjectMappings isEmpty]){
                            id subObject = [property value];
                            BOOL done = NO;
                            if(contentType != nil){
                                if([subObject isKindOfClass:contentType]){
                                    [subObject setupWithObject:value withMappings:subObjectMappings];
                                    done = YES;
                                }
                                else{
                                    subObject = [[contentType alloc]initWithObject:value withMappings:subObjectMappings];
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

@end


@implementation NSMutableDictionary (CKStyleManager)

- (NSMutableDictionary*)mappingsForObject:(id)object propertyName:(NSString*)propertyName{
    return [self dictionaryForObject:object propertyName:propertyName];
}

@end