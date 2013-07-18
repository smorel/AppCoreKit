//
//  CKRuntime.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 WhereCloud Inc. All rights reserved.
//

#import "CKClassPropertyDescriptor.h"

#ifdef __cplusplus
extern "C" {
#endif
    
    /**
     */
    BOOL CKClassAddProperty(Class c,NSString* propertyName, Class propertyClass, CKClassPropertyDescriptorAssignementType assignment, BOOL nonatomic);
    
    /**
     */
    BOOL CKClassAddNativeProperty(Class c,NSString* propertyName, CKClassPropertyDescriptorType nativeType, BOOL nonatomic);
    
    /**
     */
    BOOL CKClassAddStructProperty(Class c,NSString* propertyName, NSString* structName,const char* encoding, NSInteger size, BOOL nonatomic);
    
    /**
     */
    void CKSwizzleSelector(Class c,SEL selector, SEL newSelector);
    
    /**
     */
    void CKSwizzleClassSelector(Class c,SEL selector, SEL newSelector);

    
#ifdef __cplusplus
}
#endif