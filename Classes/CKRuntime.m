//
//  CKRuntime.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-11-30.
//  Copyright (c) 2011 WhereCloud Inc. All rights reserved.
//

#import "CKRuntime.h"
#import "CKNSObject+Introspection.h"
#import <objc/runtime.h>

static char NSObjectRuntimePropertiesObjectKey;

//Private methods Declaration

id   __runtime_getValue(id self, SEL _cmd,...);
id   __runtime_setValue(id self, SEL _cmd,...);
BOOL __class_addPropertyWithAttributes(Class c,NSString* propertyName,const objc_property_attribute_t *attributes, unsigned int attributeCount);


//Implementation

id __runtime_getValue(id self, SEL _cmd,...){
    NSString* propertyName = NSStringFromSelector(_cmd);
    NSMutableDictionary* runtimeProperties =  objc_getAssociatedObject(self, &NSObjectRuntimePropertiesObjectKey);
    if(!runtimeProperties){
        return nil;
    }
    
    return [runtimeProperties objectForKey:propertyName];
}

id __runtime_setValue(id self, SEL _cmd,...){ 
    va_list ArgumentList;
	va_start(ArgumentList,_cmd);
    id value = va_arg(ArgumentList, id);
    va_end(ArgumentList);

    
    NSString* selectorName = NSStringFromSelector(_cmd);
    
    //Test if property is capitalized
    NSString* propertyName = [selectorName substringWithRange:NSMakeRange(3, [selectorName length] - 1 - 3)];
    CKClassPropertyDescriptor* descriptor = [self propertyDescriptorForKeyPath:propertyName];
    if(!descriptor){
        //Compute the property name with non capitalized string
        NSString* propertyName = [NSString stringWithFormat:@"%@%@",[[selectorName substringWithRange:NSMakeRange(3, 1)]lowercaseString], 
                                  [selectorName substringWithRange:NSMakeRange(4, [selectorName length] - 1 - 4)]];
        descriptor = [self propertyDescriptorForKeyPath:propertyName];
        if(!descriptor){
            //This should ASSERT !
            return nil;
        }
    }
    
    NSMutableDictionary* runtimeProperties =  objc_getAssociatedObject(self, &NSObjectRuntimePropertiesObjectKey);
    if(!runtimeProperties){
        runtimeProperties = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, 
                                 &NSObjectRuntimePropertiesObjectKey,
                                 runtimeProperties,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    if(!value){
        [runtimeProperties removeObjectForKey:propertyName];
    }
    else{
        switch(descriptor.assignementType){
            case CKClassPropertyDescriptorAssignementTypeCopy:{
                [runtimeProperties setObject:[value copy] forKey:propertyName];
                break;
            }
            case CKClassPropertyDescriptorAssignementTypeRetain:{
                [runtimeProperties setObject:[value retain] forKey:propertyName];
                break;
            }
            case CKClassPropertyDescriptorAssignementTypeWeak:
            case CKClassPropertyDescriptorAssignementTypeAssign:{
                [runtimeProperties setObject:value forKey:propertyName];
                break;
            }
        }
    }
    return nil;
}

BOOL __class_addPropertyWithAttributes(Class c,NSString* propertyName,const objc_property_attribute_t *attributes, unsigned int attributeCount){
    //Adds property
    BOOL bo = class_addProperty(c, [propertyName UTF8String], attributes, attributeCount);
    if(!bo)
        return NO;
    
    //Adds Property getter
    bo = class_addMethod(c, sel_registerName([propertyName UTF8String]), &__runtime_getValue, "@@:");
    if(!bo)
        return NO;
    
    //Adds Property setter
    NSString *setterName = [propertyName copy];
    NSString *first = [setterName substringToIndex:1];
    first = [first uppercaseString];
    setterName = [NSString stringWithFormat:@"set%@%@:", first, [setterName substringFromIndex:1]];
    bo = class_addMethod(c, sel_registerName([setterName UTF8String]), &__runtime_setValue, "v@:@");
    if(!bo){
        return NO;
    }
    
    return YES;
}

BOOL CKClassAddProperty(Class c,NSString* propertyName, Class propertyClass, CKClassPropertyDescriptorAssignementType assignment, BOOL nonatomic){
    NSString* typeStr = [NSString stringWithFormat:@"@\"%@\"",[propertyClass description]];
    objc_property_attribute_t type = { "T", [typeStr UTF8String] };
    
    if(assignment == CKClassPropertyDescriptorAssignementTypeAssign){
        if(nonatomic){
            objc_property_attribute_t atomic = { "N", ""};
            objc_property_attribute_t attrs[] = { type,atomic };
            return __class_addPropertyWithAttributes(c,propertyName,attrs, 2);
        }
        else{
            objc_property_attribute_t attrs[] = { type };
            return __class_addPropertyWithAttributes(c,propertyName,attrs, 1);
        }
    }
    else{
        objc_property_attribute_t ownership;
        switch(assignment){
            case CKClassPropertyDescriptorAssignementTypeCopy:{
                ownership.name = "C";
                break;
            }
            case CKClassPropertyDescriptorAssignementTypeRetain:{
                ownership.name = "&";
                break;
            }
            case CKClassPropertyDescriptorAssignementTypeWeak:{
                ownership.name = "W";
                break;
            }
        }
        ownership.value = "";
        
        if(nonatomic){
            objc_property_attribute_t atomic = { "N", ""};
            objc_property_attribute_t attrs[] = { type, ownership,atomic };
            return __class_addPropertyWithAttributes(c,propertyName,attrs, 3);
        }
        else{
            objc_property_attribute_t attrs[] = { type, ownership };
            return __class_addPropertyWithAttributes(c,propertyName,attrs, 2);
        }
    }
    return NO;
}


BOOL CKClassAddNativeProperty(Class c,NSString* propertyName, CKClassPropertyDescriptorType nativeType, BOOL nonatomic){
    objc_property_attribute_t type;
    switch(nativeType){
        case CKClassPropertyDescriptorTypeChar:              { type.value = "c"; break; }
        case CKClassPropertyDescriptorTypeInt:               { type.value = "i"; break; }
        case CKClassPropertyDescriptorTypeShort:             { type.value = "s"; break; }
        case CKClassPropertyDescriptorTypeLong:              { type.value = "l"; break; }
        case CKClassPropertyDescriptorTypeLongLong:          { type.value = "q"; break; }
        case CKClassPropertyDescriptorTypeUnsignedChar:      { type.value = "C"; break; }
        case CKClassPropertyDescriptorTypeUnsignedInt:       { type.value = "I"; break; }
        case CKClassPropertyDescriptorTypeUnsignedShort:     { type.value = "S"; break; }
        case CKClassPropertyDescriptorTypeUnsignedLong:      { type.value = "L"; break; }
        case CKClassPropertyDescriptorTypeUnsignedLongLong:  { type.value = "Q"; break; }
        case CKClassPropertyDescriptorTypeFloat:             { type.value = "f"; break; }
        case CKClassPropertyDescriptorTypeDouble:            { type.value = "d"; break; }
        case CKClassPropertyDescriptorTypeCppBool:           { type.value = "B"; break; }
        case CKClassPropertyDescriptorTypeVoid:              { type.value = "v"; break; }
        case CKClassPropertyDescriptorTypeCharString:        { type.value = "*"; break; }
        case CKClassPropertyDescriptorTypeClass:             { type.value = "#"; break; }
        case CKClassPropertyDescriptorTypeSelector:          { type.value = ":"; break; }
        default:{
            //Unsuported
            return NO;
        }
    }
    type.name = "T";
    
    if(nonatomic){
        objc_property_attribute_t atomic = { "N", ""};
        objc_property_attribute_t attrs[] = { type,atomic };
        return __class_addPropertyWithAttributes(c,propertyName,attrs,2);
    }
    else{
        objc_property_attribute_t attrs[] = { type };
        return __class_addPropertyWithAttributes(c,propertyName,attrs, 1);
    }
    
    return NO;
}


BOOL CKClassAddStructProperty(Class c,NSString* propertyName, const char* encoding, BOOL nonatomic){
    objc_property_attribute_t type = { "T", encoding };
    
    if(nonatomic){
        objc_property_attribute_t atomic = { "N", ""};
        objc_property_attribute_t attrs[] = { type,atomic };
        return __class_addPropertyWithAttributes(c,propertyName,attrs, 2);
    }
    else{
        objc_property_attribute_t attrs[] = { type };
        return __class_addPropertyWithAttributes(c,propertyName,attrs, 1);
    }
    
    return NO;
}