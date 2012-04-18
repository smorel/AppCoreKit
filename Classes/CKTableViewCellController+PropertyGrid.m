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