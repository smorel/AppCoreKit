//
//  CKTableViewCellController+PropertyGrid.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-07-29.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKTableViewCellController+PropertyGrid.h"
#import "CKProperty.h"
#import "CKLocalization.h"

#import "CKNSNumberPropertyCellController.h"
#import "CKNSStringPropertyCellController.h"
#import "CKNSObject+Bindings.h"
#import "CKOptionCellController.h"
#import "CKArrayProxyCollection.h"
#import "CKNSValueTransformer+Additions.h"
#import "CKNSObjectPropertyCellController.h"
#import "CKUIColorPropertyCellController.h"
#import "CKNSDatePropertyCellController.h"
#import "CKCGPropertyCellControllers.h"
#import "CKUIImagePropertyCellController.h"
#import "CKOptionPropertyCellController.h"

#import "CKNSObject+CKRuntime.h"
#import "CKNSNotificationCenter+Edition.h"
#import "CKFormSectionBase_private.h"


@interface CKTableViewCellController(CKPropertyGridPrivate)
+ (NSArray*)propertyNamesForObject:(id)object withFilter:(NSString*)filter;
+ (void)setup:(NSArray*)properties inSection:(CKFormSection*)section readOnly:(BOOL)readOnly;
@end

@implementation CKTableViewCellController(CKPropertyGridPrivate)

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


@implementation CKTableViewCellController(CKPropertyGrid)

+ (CKTableViewCellController*)cellControllerWithObject:(id)object keyPath:(NSString*)keyPath{
    return [CKTableViewCellController cellControllerWithProperty:[CKProperty propertyWithObject:object keyPath:keyPath]];
}

+ (CKTableViewCellController*)cellControllerWithObject:(id)object keyPath:(NSString*)keyPath readOnly:(BOOL)readOnly{
    return [CKTableViewCellController cellControllerWithProperty:[CKProperty propertyWithObject:object keyPath:keyPath] readOnly:readOnly];
}

+ (CKTableViewCellController*)cellControllerWithProperty:(CKProperty*)property{
    return [CKTableViewCellController cellControllerWithProperty:property readOnly:NO];
}

+ (CKTableViewCellController*)cellControllerWithProperty:(CKProperty*)property readOnly:(BOOL)readOnly{
    CKTableViewCellController* cellController = nil;
    
    CKPropertyExtendedAttributes* attributes = [property extendedAttributes];
    if(attributes.editable == YES){
        if(attributes.cellControllerCreationBlock != nil){
           cellController = attributes.cellControllerCreationBlock(property);
        }
        else if(attributes.valuesAndLabels != nil
                || attributes.enumDescriptor != nil ){
            cellController = [CKOptionPropertyCellController cellController];
        }
        else{
            CKClassPropertyDescriptor* descriptor = [property descriptor];
            if(descriptor == nil || descriptor.propertyType == CKClassPropertyDescriptorTypeObject){
                id value = [property value];
                if(descriptor == nil && [value isKindOfClass:[NSValue class]]){
                    id nonRetainedValue = [value nonretainedObjectValue];
                    if(nonRetainedValue){
                        value = nonRetainedValue;
                    }
                }
                
                Class propertyType = value ? [value class] : (descriptor ? descriptor.type : nil);
                
                if([NSObject isClass:propertyType kindOfClass:[NSString class]]){
                    cellController = [CKNSStringPropertyCellController cellController];
                }
                else if([NSObject isClass:propertyType kindOfClass:[NSNumber class]]){
                    cellController = [CKNSNumberPropertyCellController cellController];
                }
                else if([NSObject isClass:propertyType kindOfClass:[UIColor class]]){
                    cellController = [CKUIColorPropertyCellController cellController];
                }
                else if([NSObject isClass:propertyType kindOfClass:[NSDate class]]){
                    cellController = [CKNSDatePropertyCellController cellController];
                }
                else if([NSObject isClass:propertyType kindOfClass:[UIImage class]]){
                    cellController = [CKUIImagePropertyCellController cellController];
                }
                else{
                    cellController = [CKNSObjectPropertyCellController cellController];
                }
            }
            else{
                CKClassPropertyDescriptor* descriptor = [property descriptor];
                switch(descriptor.propertyType){
                    case CKClassPropertyDescriptorTypeChar:
                    case CKClassPropertyDescriptorTypeInt:
                    case CKClassPropertyDescriptorTypeShort:
                    case CKClassPropertyDescriptorTypeLong:
                    case CKClassPropertyDescriptorTypeLongLong:
                    case CKClassPropertyDescriptorTypeUnsignedChar:
                    case CKClassPropertyDescriptorTypeUnsignedInt:
                    case CKClassPropertyDescriptorTypeUnsignedShort:
                    case CKClassPropertyDescriptorTypeUnsignedLong:
                    case CKClassPropertyDescriptorTypeUnsignedLongLong:
                    case CKClassPropertyDescriptorTypeFloat:
                    case CKClassPropertyDescriptorTypeDouble:
                    case CKClassPropertyDescriptorTypeCppBool:
                    case CKClassPropertyDescriptorTypeVoid:
                    case CKClassPropertyDescriptorTypeCharString:{
                        cellController = [CKNSNumberPropertyCellController cellController];
                        break;
                    }
                    case CKClassPropertyDescriptorTypeStruct:
                    {
                        NSString* controllerClassName = [NSString stringWithFormat:@"CK%@PropertyCellController",descriptor.className];
                        Class controllerClass = NSClassFromString(controllerClassName);
                        if(controllerClass){
                            cellController = [controllerClass cellController];
                        }
                        break;
                    }
                }
            }
        }
    }
    
    if(cellController){
        cellController.value = property;
        cellController.cellStyle = CKTableViewCellStylePropertyGrid;
        
        if([cellController respondsToSelector:@selector(setOptionCellStyle:)]){
            CKTableViewCellStyle subStyle = CKTableViewCellStylePropertyGrid;
            
            NSMethodSignature *signature = [cellController methodSignatureForSelector:@selector(setOptionCellStyle:)];
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
            [invocation setSelector:@selector(setOptionCellStyle:)];
            [invocation setTarget:cellController];
            [invocation setArgument:(void*)&subStyle
                            atIndex:2];
            [invocation invoke];
        }
        
        if([cellController respondsToSelector:@selector(setReadOnly:)]){
            NSMethodSignature *signature = [cellController methodSignatureForSelector:@selector(setReadOnly:)];
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
            [invocation setSelector:@selector(setReadOnly:)];
            [invocation setTarget:cellController];
            [invocation setArgument:(void*)&readOnly
                            atIndex:2];
            [invocation invoke];
        }
    }
    
    return cellController;
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
    return [CKFormSection sectionWithObject:object properties:[CKTableViewCellController propertyNamesForObject:object withFilter:filter] headerTitle:title hidden:hidden];
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
    return [CKFormSection sectionWithObject:object properties:[CKTableViewCellController propertyNamesForObject:object withFilter:filter] headerTitle:title hidden:hidden readOnly:readOnly];
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
    [CKTableViewCellController setup:theProperties inSection:section readOnly:readOnly];
    
    return section;
}

@end