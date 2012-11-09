//
//  CKFormSection+PropertyGrid.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKFormSection+PropertyGrid.h"
#import "CKProperty.h"
#import "CKTableViewCellController+PropertyGrid.h"
#import "NSValueTransformer+Additions.h"
#import "CKFormSectionBase_private.h"



@interface CKFormSection(CKPropertyGridPrivate)
+ (NSArray*)propertyNamesForObject:(id)object withFilter:(NSString*)filter;
+ (void)setup:(NSArray*)properties inSection:(CKFormSection*)section readOnly:(BOOL)readOnly;
@end

@implementation CKFormSection(CKPropertyGridPrivate)

+ (NSArray*)propertyNamesForObject:(id)object withFilter:(NSString*)filter{
	NSString* lowerCaseFilter = [filter lowercaseString];
    
    if([object isKindOfClass:[NSValue class]]){
        id nonRetainedValue = [object nonretainedObjectValue];
        if(nonRetainedValue){
            object = nonRetainedValue;
        }
    }
    
    NSArray* propertyDescriptors = [object allPropertyDescriptors];
	NSMutableArray* theProperties = [NSMutableArray array];
    if([object isKindOfClass:[NSDictionary class]]){
        for(id key in [object allKeys]){
            NSString* strKey = [NSValueTransformer transform:key toClass:[NSString class]];
            NSString* lowerCaseProperty = [strKey lowercaseString];
            BOOL useProperty = YES;
            if(filter != nil){
                NSRange range = [lowerCaseProperty rangeOfString:lowerCaseFilter];
                useProperty = (range.location != NSNotFound);
            }
            if(useProperty){
                [theProperties addObject:key];
            }
        }
    }
    else{
        for(CKClassPropertyDescriptor* descriptor in propertyDescriptors){
            NSString* lowerCaseProperty = [descriptor.name lowercaseString];
            BOOL useProperty = YES;
            if(filter != nil && [filter length] > 0){
                NSRange range = [lowerCaseProperty rangeOfString:lowerCaseFilter];
                useProperty = (range.location != NSNotFound);
            }
            if(useProperty){
                CKPropertyExtendedAttributes* attributes = [descriptor extendedAttributesForInstance:object];
                if(attributes.editable){
                    [theProperties insertObject:descriptor.name atIndex:0];
                }
            }
        }
    }
    return theProperties;
}

+ (void)setup:(NSArray*)properties inSection:(CKFormSection*)section readOnly:(BOOL)readOnly{
    for(CKProperty* property in properties){
        CKTableViewCellController* controller = [CKTableViewCellController cellControllerWithProperty:property readOnly:readOnly];
        if(controller){
            [section addCellController:controller];
        }
    }
}

@end

//CKFormSection(CKPropertyGrid)

@implementation CKFormSection(CKPropertyGrid)

+ (CKFormSection*)sectionWithObject:(id)object headerTitle:(NSString*)title{
    return [CKFormSection sectionWithObject:object propertyFilter:nil headerTitle:title hidden:NO];
}

+ (CKFormSection*)sectionWithObject:(id)object headerTitle:(NSString*)title hidden:(BOOL)hidden{
    return [CKFormSection sectionWithObject:object propertyFilter:nil headerTitle:title hidden:hidden];
}

+ (CKFormSection*)sectionWithObject:(id)object propertyFilter:(NSString*)filter headerTitle:(NSString*)title{
    return [CKFormSection sectionWithObject:object propertyFilter:filter headerTitle:title hidden:NO];
}

+ (CKFormSection*)sectionWithObject:(id)object propertyFilter:(NSString*)filter headerTitle:(NSString*)title hidden:(BOOL)hidden{
    return [CKFormSection sectionWithObject:object properties:[CKFormSection propertyNamesForObject:object withFilter:filter] headerTitle:title hidden:hidden];
}

+ (CKFormSection*)sectionWithObject:(id)object properties:(NSArray*)properties headerTitle:(NSString*)title{
    return [CKFormSection sectionWithObject:object properties:properties headerTitle:title hidden:NO];
}

+ (CKFormSection*)sectionWithObject:(id)object properties:(NSArray*)properties headerTitle:(NSString*)title hidden:(BOOL)hidden{
    return [CKFormSection sectionWithObject:object properties:properties headerTitle:title hidden:hidden readOnly:NO];
}

+ (CKFormSection*)sectionWithObject:(id)object headerTitle:(NSString*)title readOnly:(BOOL)readOnly{
    return [CKFormSection sectionWithObject:object propertyFilter:nil headerTitle:title hidden:NO readOnly:readOnly];
}

+ (CKFormSection*)sectionWithObject:(id)object headerTitle:(NSString*)title hidden:(BOOL)hidden readOnly:(BOOL)readOnly{
    return [CKFormSection sectionWithObject:object propertyFilter:nil headerTitle:title hidden:hidden readOnly:readOnly];
}

+ (CKFormSection*)sectionWithObject:(id)object propertyFilter:(NSString*)filter headerTitle:(NSString*)title readOnly:(BOOL)readOnly{
    return [CKFormSection sectionWithObject:object propertyFilter:filter headerTitle:title hidden:NO readOnly:readOnly];
}

+ (CKFormSection*)sectionWithObject:(id)object propertyFilter:(NSString*)filter headerTitle:(NSString*)title hidden:(BOOL)hidden readOnly:(BOOL)readOnly{
    return [CKFormSection sectionWithObject:object properties:[CKFormSection propertyNamesForObject:object withFilter:filter] headerTitle:title hidden:hidden readOnly:readOnly];
}

+ (CKFormSection*)sectionWithObject:(id)object properties:(NSArray*)properties headerTitle:(NSString*)title readOnly:(BOOL)readOnly{
    return [CKFormSection sectionWithObject:object properties:properties headerTitle:title hidden:NO readOnly:readOnly];
}

+ (CKFormSection*)sectionWithObject:(id)object properties:(NSArray*)properties headerTitle:(NSString*)title hidden:(BOOL)hidden readOnly:(BOOL)readOnly{
    
    if([object isKindOfClass:[NSValue class]]){
        id nonRetainedValue = [object nonretainedObjectValue];
        if(nonRetainedValue){
            object = nonRetainedValue;
        }
    }
    
    NSMutableArray* theProperties = [NSMutableArray array];
    for(NSString* propertyName in properties){
        CKProperty* property = nil;
        if([object isKindOfClass:[NSDictionary class]]){
            property = [[[CKProperty alloc]initWithDictionary:object key:propertyName]autorelease];
        }
        else{
            property = [CKProperty propertyWithObject:object keyPath:propertyName];
        }
        [theProperties addObject:property];
    }
    
    CKFormSection* section = (title != nil && [title length] > 0) ? [CKFormSection sectionWithHeaderTitle:_(title)] : [CKFormSection section];
    section.hidden = hidden;
    [CKFormSection setup:theProperties inSection:section readOnly:readOnly];
    
    return section;
}

@end