//
//  CKReusableViewController+Property.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-25.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKReusableViewController+Property.h"

#import "CKPropertiesSampleViewController.h"
#import "CKPropertyStringViewController.h"
#import "CKPropertyNumberViewController.h"
#import "CKPropertyBoolViewController.h"
#import "CKPropertySelectionViewController.h"
#import "CKPropertyVectorViewController.h"
#import "CKPropertyColorViewController.h"
#import "CKPropertyImageViewController.h"
#import "CKPropertyObjectViewController.h"

@implementation CKReusableViewController (Property)

+ (instancetype)controllerWithObject:(id)object keyPath:(NSString*)keyPath{
    return [CKReusableViewController controllerWithProperty:[CKProperty propertyWithObject:object keyPath:keyPath]];
}

+ (instancetype)controllerWithObject:(id)object keyPath:(NSString*)keyPath readOnly:(BOOL)readOnly{
    return [CKReusableViewController controllerWithProperty:[CKProperty propertyWithObject:object keyPath:keyPath] readOnly:readOnly];
}

+ (instancetype)controllerWithProperty:(CKProperty*)property{
    return [CKReusableViewController controllerWithProperty:property readOnly:NO];
}

+ (instancetype)controllerWithProperty:(CKProperty*)property readOnly:(BOOL)readOnly{
    if(![property isKVCComplient])
        return nil;
    
    CKReusableViewController* controller = nil;
    
    CKPropertyExtendedAttributes* attributes = [property extendedAttributes];
    if(attributes.editable == YES){
        if(attributes.valuesAndLabels != nil
                || attributes.enumDescriptor != nil ){
            controller = [CKPropertySelectionViewController controllerWithProperty:property readOnly:readOnly];
        }
        else{
            CKClassPropertyDescriptor* descriptor = [property descriptor];
            if(descriptor == nil || descriptor.propertyType == CKClassPropertyDescriptorTypeObject){
                Class propertyType = descriptor ? descriptor.type : nil;
                id value = [property value];
                if(descriptor == nil && [value isKindOfClass:[NSValue class]]){
                    id nonRetainedValue = [value nonretainedObjectValue];
                    if(nonRetainedValue){
                        value = nonRetainedValue;
                    }
                    propertyType = [value class];
                }
                
                if([NSObject isClass:propertyType kindOfClass:[NSString class]]){
                    controller = [CKPropertyStringViewController controllerWithProperty:property readOnly:readOnly];
                }
                else if([NSObject isClass:propertyType kindOfClass:[NSURL class]]){
                    controller = [CKPropertyURLViewController controllerWithProperty:property readOnly:readOnly];
                }
                else if([NSObject isClass:propertyType kindOfClass:[NSNumber class]]){
                    controller = [CKPropertyNumberViewController controllerWithProperty:property readOnly:readOnly];
                }
                else if([NSObject isClass:propertyType kindOfClass:[UIColor class]]){
                    controller = [CKPropertyColorViewController controllerWithProperty:property readOnly:readOnly];
                }
                else if([NSObject isClass:propertyType kindOfClass:[NSDate class]]){
                    controller = [CKPropertyDateViewController controllerWithProperty:property readOnly:readOnly];
                }
                else if([NSObject isClass:propertyType kindOfClass:[UIImage class]]){
                    controller = [CKPropertyImageViewController controllerWithProperty:property readOnly:readOnly];
                }
                else if([NSObject isClass:propertyType kindOfClass:[UIFont class]]){
                    UIFont* font = [property value];
                    NSString* subtitle = font ? [NSString stringWithFormat:@"%@ [%g]",font.fontName,font.pointSize] : @"nil";
                    controller = [CKStandardContentViewController controllerWithTitle:_(property.name) subtitle:subtitle action:nil];
                }
                else{
                    controller = [CKPropertyObjectViewController controllerWithProperty:property readOnly:readOnly];
                }
            }
            else{
                CKClassPropertyDescriptor* descriptor = [property descriptor];
                switch(descriptor.propertyType){
                    case CKClassPropertyDescriptorTypeChar:{
                        controller = [CKPropertyBoolViewController controllerWithProperty:property readOnly:readOnly];
                        break;
                    }
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
                        controller = [CKPropertyNumberViewController controllerWithProperty:property readOnly:readOnly];
                        break;
                    }
                    case CKClassPropertyDescriptorTypeStruct:
                    {
                        if([CKPropertyVectorViewController compatibleWithProperty:property]){
                            controller = [CKPropertyVectorViewController controllerWithProperty:property readOnly:readOnly];
                        }
                        break;
                    }
                }
            }
        }
    }
    
    return controller;
}


@end
