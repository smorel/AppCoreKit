//
//  CKSection+Property.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-25.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKSection+Property.h"
#import "CKReusableViewController+Property.h"
#import "NSValueTransformer+Additions.h"


@interface CKSection(PropertyPrivate)
+ (NSArray*)propertyNamesForObject:(id)object withFilter:(NSString*)filter;
+ (void)setup:(NSArray*)properties inSection:(CKSection*)section readOnly:(BOOL)readOnly;
@end

@implementation CKSection(PropertyPrivate)

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

+ (void)setup:(NSArray*)properties inSection:(CKSection*)section readOnly:(BOOL)readOnly{
    for(CKProperty* property in properties){
        CKReusableViewController* controller = [CKReusableViewController controllerWithProperty:property readOnly:readOnly];
        if(controller){
            [section addController:controller animated:NO];
        }
    }
}

@end


@implementation CKSection (Property)

+ (CKSection*)sectionWithObject:(id)object headerTitle:(NSString*)title{
    return [CKSection sectionWithObject:object propertyFilter:nil headerTitle:title hidden:NO];
}

+ (CKSection*)sectionWithObject:(id)object headerTitle:(NSString*)title hidden:(BOOL)hidden{
    return [CKSection sectionWithObject:object propertyFilter:nil headerTitle:title hidden:hidden];
}

+ (CKSection*)sectionWithObject:(id)object propertyFilter:(NSString*)filter headerTitle:(NSString*)title{
    return [CKSection sectionWithObject:object propertyFilter:filter headerTitle:title hidden:NO];
}

+ (CKSection*)sectionWithObject:(id)object propertyFilter:(NSString*)filter headerTitle:(NSString*)title hidden:(BOOL)hidden{
    return [CKSection sectionWithObject:object properties:[CKSection propertyNamesForObject:object withFilter:filter] headerTitle:title hidden:hidden];
}

+ (CKSection*)sectionWithObject:(id)object properties:(NSArray*)properties headerTitle:(NSString*)title{
    return [CKSection sectionWithObject:object properties:properties headerTitle:title hidden:NO];
}

+ (CKSection*)sectionWithObject:(id)object properties:(NSArray*)properties headerTitle:(NSString*)title hidden:(BOOL)hidden{
    return [CKSection sectionWithObject:object properties:properties headerTitle:title hidden:hidden readOnly:NO];
}

+ (CKSection*)sectionWithObject:(id)object headerTitle:(NSString*)title readOnly:(BOOL)readOnly{
    return [CKSection sectionWithObject:object propertyFilter:nil headerTitle:title hidden:NO readOnly:readOnly];
}

+ (CKSection*)sectionWithObject:(id)object headerTitle:(NSString*)title hidden:(BOOL)hidden readOnly:(BOOL)readOnly{
    return [CKSection sectionWithObject:object propertyFilter:nil headerTitle:title hidden:hidden readOnly:readOnly];
}

+ (CKSection*)sectionWithObject:(id)object propertyFilter:(NSString*)filter headerTitle:(NSString*)title readOnly:(BOOL)readOnly{
    return [CKSection sectionWithObject:object propertyFilter:filter headerTitle:title hidden:NO readOnly:readOnly];
}

+ (CKSection*)sectionWithObject:(id)object propertyFilter:(NSString*)filter headerTitle:(NSString*)title hidden:(BOOL)hidden readOnly:(BOOL)readOnly{
    return [CKSection sectionWithObject:object properties:[CKSection propertyNamesForObject:object withFilter:filter] headerTitle:title hidden:hidden readOnly:readOnly];
}

+ (CKSection*)sectionWithObject:(id)object properties:(NSArray*)properties headerTitle:(NSString*)title readOnly:(BOOL)readOnly{
    return [CKSection sectionWithObject:object properties:properties headerTitle:title hidden:NO readOnly:readOnly];
}

+ (CKSection*)sectionWithObject:(id)object properties:(NSArray*)properties headerTitle:(NSString*)title hidden:(BOOL)hidden readOnly:(BOOL)readOnly{
    
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
    
    CKSection* section = [[[CKSection alloc]init]autorelease];
    if(title){
        [section setHeaderTitle:title];
    }
    
    section.hidden = hidden;
    [CKSection setup:theProperties inSection:section readOnly:readOnly];
    
    return section;
}

@end
