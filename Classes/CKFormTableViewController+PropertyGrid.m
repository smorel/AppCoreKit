//
//  CKFormTableViewController+PropertyGrid.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-07-29.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKFormTableViewController+PropertyGrid.h"
#import "CKObjectProperty.h"
#import "CKLocalization.h"

#import "CKNSNumberPropertyCellController.h"
#import "CKNSStringPropertyCellController.h"
#import "CKNSObject+Bindings.h"
#import "CKOptionCellController.h"
#import "CKObjectPropertyArrayCollection.h"
#import "CKNSValueTransformer+Additions.h"
#import "CKNSObjectPropertyCellController.h"
#import "CKUIColorPropertyCellController.h"
#import "CKNSDatePropertyCellController.h"
#import "CKCGPropertyCellControllers.h"
#import "CKUIImagePropertyCellController.h"

#import "CKNSObject+Introspection.h"
#import "CKNSNotificationCenter+Edition.h"

@interface CKFormTableViewController(CKPropertyGridPrivate)
- (NSArray*)propertyNamesForObject:(id)object withFilter:(NSString*)filter;
- (void)setup:(NSArray*)properties inSection:(CKFormSection*)section readOnly:(BOOL)readOnly;
+ (CKFormCellDescriptor*)cellDescriptorWithProperty:(CKObjectProperty*)property readOnly:(BOOL)readOnly;
@end

@implementation CKFormTableViewController(CKPropertyGridPrivate)

- (NSArray*)propertyNamesForObject:(id)object withFilter:(NSString*)filter{
	NSString* lowerCaseFilter = [filter lowercaseString];
    
    NSArray* propertyDescriptors = [object allPropertyDescriptors];
	NSMutableArray* theProperties = [NSMutableArray array];
	for(CKClassPropertyDescriptor* descriptor in propertyDescriptors){
		NSString* lowerCaseProperty = [descriptor.name lowercaseString];
		BOOL useProperty = YES;
		if(filter != nil){
			NSRange range = [lowerCaseProperty rangeOfString:lowerCaseFilter];
			useProperty = (range.location != NSNotFound);
		}
		if(useProperty){
			CKModelObjectPropertyMetaData* metaData = [CKModelObjectPropertyMetaData propertyMetaDataForObject:object property:descriptor];
			if(metaData.editable){
				[theProperties insertObject:descriptor.name atIndex:0];
			}
		}
	}
    return theProperties;
}


+ (CKFormCellDescriptor*)cellDescriptorWithProperty:(CKObjectProperty*)property readOnly:(BOOL)readOnly{
    CKFormCellDescriptor* cellDescriptor = nil;
    
    CKModelObjectPropertyMetaData* metaData = [property metaData];
    if(metaData.editable == YES){
        if(metaData.propertyCellControllerClass != nil){
            NSAssert([NSObject isKindOf:metaData.propertyCellControllerClass parentType:[CKTableViewCellController class]],@"invalid propertyCellControllerClass defined for property : %@",property);
            cellDescriptor = [CKFormCellDescriptor cellDescriptorWithValue:property controllerClass:metaData.propertyCellControllerClass];
        }
        else if(metaData.valuesAndLabels != nil){
            cellDescriptor = [CKFormCellDescriptor cellDescriptorWithProperty:property valuesAndLabels:[metaData.valuesAndLabels copy]];
        }
        else if(metaData.enumDefinition != nil){
            cellDescriptor = [CKFormCellDescriptor cellDescriptorWithProperty:property enumDefinition:[metaData.enumDefinition copy] multiSelectionEnabled:metaData.multiselectionEnabled];
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
                    cellDescriptor = [CKFormCellDescriptor cellDescriptorWithValue:property controllerClass:[CKNSNumberPropertyCellController class]];
                    break;
                }
                case CKClassPropertyDescriptorTypeObject:{
                    if([NSObject isKindOf:descriptor.type parentType:[NSString class]]){
                        cellDescriptor = [CKFormCellDescriptor cellDescriptorWithValue:property controllerClass:[CKNSStringPropertyCellController class]];
                    }
                    else if([NSObject isKindOf:descriptor.type parentType:[NSNumber class]]){
                        cellDescriptor = [CKFormCellDescriptor cellDescriptorWithValue:property controllerClass:[CKNSNumberPropertyCellController class]];
                    }
                    else if([NSObject isKindOf:descriptor.type parentType:[UIColor class]]){
                        cellDescriptor = [CKFormCellDescriptor cellDescriptorWithValue:property controllerClass:[CKUIColorPropertyCellController class]];
                    }
                    else if([NSObject isKindOf:descriptor.type parentType:[NSDate class]]){
                        cellDescriptor = [CKFormCellDescriptor cellDescriptorWithValue:property controllerClass:[CKNSDatePropertyCellController class]];
                    }
                    else if([NSObject isKindOf:descriptor.type parentType:[UIImage class]]){
                        cellDescriptor = [CKFormCellDescriptor cellDescriptorWithValue:property controllerClass:[CKUIImagePropertyCellController class]];
                    }
                    else{
                        cellDescriptor = [CKFormCellDescriptor cellDescriptorWithValue:property controllerClass:[CKNSObjectPropertyCellController class]];
                    }
                    break;
                }
                case CKClassPropertyDescriptorTypeStruct:
                {
                    NSString* controllerClassName = [NSString stringWithFormat:@"CK%@PropertyCellController",descriptor.className];
                    Class controllerClass = NSClassFromString(controllerClassName);
                    if(controllerClass){
                        cellDescriptor = [CKFormCellDescriptor cellDescriptorWithValue:property controllerClass:controllerClass];
                    }
                    break;
                }
            }
        }
    }
    
    if(cellDescriptor){
        [cellDescriptor setCreateBlock:^(id controller){
            CKTableViewCellController* cellController = (CKTableViewCellController*)controller;
            cellController.cellStyle = CKTableViewCellStylePropertyGrid;
            if([cellController respondsToSelector:@selector(setOptionCellStyle:)]){
                [cellController setOptionCellStyle:CKTableViewCellStylePropertyGrid];
            }
            
            if([cellController respondsToSelector:@selector(setReadOnly:)]){
                NSMethodSignature *signature = [controller methodSignatureForSelector:@selector(setReadOnly:)];
				NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
				[invocation setSelector:@selector(setReadOnly:)];
				[invocation setTarget:controller];
				[invocation setArgument:(void*)&readOnly
								atIndex:2];
				[invocation invoke];
            }
            return (id)nil;
        }];
    }
    return cellDescriptor;
}

- (void)setup:(NSArray*)properties inSection:(CKFormSection*)section readOnly:(BOOL)readOnly{
    for(CKObjectProperty* property in properties){
        CKFormCellDescriptor* descriptor = [CKFormTableViewController cellDescriptorWithProperty:property readOnly:readOnly];
        if(descriptor){
            [section addCellDescriptor:descriptor];
        }
    }
}

@end

@implementation CKFormTableViewController(CKPropertyGrid)

- (CKFormSectionBase*)addSectionWithObject:(id)object headerTitle:(NSString*)title{
    return [self addSectionWithObject:object propertyFilter:nil headerTitle:title hidden:NO];
}

- (CKFormSectionBase*)addSectionWithObject:(id)object headerTitle:(NSString*)title hidden:(BOOL)hidden{
    return [self addSectionWithObject:object propertyFilter:nil headerTitle:title hidden:hidden];
}

- (CKFormSectionBase*)addSectionWithObject:(id)object propertyFilter:(NSString*)filter headerTitle:(NSString*)title{
    return [self addSectionWithObject:object propertyFilter:filter headerTitle:title hidden:NO];
}

- (CKFormSectionBase*)addSectionWithObject:(id)object propertyFilter:(NSString*)filter headerTitle:(NSString*)title hidden:(BOOL)hidden{
    return [self addSectionWithObject:object properties:[self propertyNamesForObject:object withFilter:filter] headerTitle:title hidden:hidden];
}

- (CKFormSectionBase*)addSectionWithObject:(id)object properties:(NSArray*)properties headerTitle:(NSString*)title{
    return [self addSectionWithObject:object properties:properties headerTitle:title hidden:NO];
}

- (CKFormSectionBase*)addSectionWithObject:(id)object properties:(NSArray*)properties headerTitle:(NSString*)title hidden:(BOOL)hidden{
    return [self addSectionWithObject:object properties:properties headerTitle:title hidden:hidden readOnly:NO];
}

- (CKFormSectionBase*)addSectionWithObject:(id)object headerTitle:(NSString*)title readOnly:(BOOL)readOnly{
    return [self addSectionWithObject:object propertyFilter:nil headerTitle:title hidden:NO readOnly:readOnly];
}

- (CKFormSectionBase*)addSectionWithObject:(id)object headerTitle:(NSString*)title hidden:(BOOL)hidden readOnly:(BOOL)readOnly{
    return [self addSectionWithObject:object propertyFilter:nil headerTitle:title hidden:hidden readOnly:readOnly];
}

- (CKFormSectionBase*)addSectionWithObject:(id)object propertyFilter:(NSString*)filter headerTitle:(NSString*)title readOnly:(BOOL)readOnly{
    return [self addSectionWithObject:object propertyFilter:filter headerTitle:title hidden:NO readOnly:readOnly];
}

- (CKFormSectionBase*)addSectionWithObject:(id)object propertyFilter:(NSString*)filter headerTitle:(NSString*)title hidden:(BOOL)hidden readOnly:(BOOL)readOnly{
    return [self addSectionWithObject:object properties:[self propertyNamesForObject:object withFilter:filter] headerTitle:title hidden:hidden readOnly:readOnly];
}

- (CKFormSectionBase*)addSectionWithObject:(id)object properties:(NSArray*)properties headerTitle:(NSString*)title readOnly:(BOOL)readOnly{
    return [self addSectionWithObject:object properties:properties headerTitle:title hidden:NO readOnly:readOnly];
}

- (CKFormSectionBase*)addSectionWithObject:(id)object properties:(NSArray*)properties headerTitle:(NSString*)title hidden:(BOOL)hidden readOnly:(BOOL)readOnly{
    NSMutableArray* theProperties = [NSMutableArray array];
    for(NSString* propertyName in properties){
        CKObjectProperty* property = [CKObjectProperty propertyWithObject:object keyPath:propertyName];
        [theProperties addObject:property];
    }
    
    //TODO footerName
    CKFormSection* section = (title != nil && [title length] > 0) ? [CKFormSection sectionWithHeaderTitle:_(title)] : [CKFormSection section];
    section.hidden = hidden;
    [self setup:theProperties inSection:section readOnly:readOnly];
    [self addSection:section];
    
    return section;
}

@end


@implementation CKFormCellDescriptor(CKPropertyGrid)

+ (CKFormCellDescriptor*)cellDescriptorWithObject:(id)object keyPath:(NSString*)keyPath{
    return [CKFormCellDescriptor cellDescriptorWithProperty:[CKObjectProperty propertyWithObject:object keyPath:keyPath]];
}

+ (CKFormCellDescriptor*)cellDescriptorWithProperty:(CKObjectProperty*)property{
    return [CKFormCellDescriptor cellDescriptorWithProperty:property readOnly:NO];
}

+ (CKFormCellDescriptor*)cellDescriptorWithObject:(id)object keyPath:(NSString*)keyPath readOnly:(BOOL)readOnly{
    return [CKFormCellDescriptor cellDescriptorWithProperty:[CKObjectProperty propertyWithObject:object keyPath:keyPath] readOnly:readOnly];
}

+ (CKFormCellDescriptor*)cellDescriptorWithProperty:(CKObjectProperty*)property readOnly:(BOOL)readOnly{
    CKFormCellDescriptor* descriptor = [CKFormTableViewController cellDescriptorWithProperty:property readOnly:readOnly];
    return descriptor;
}

@end
