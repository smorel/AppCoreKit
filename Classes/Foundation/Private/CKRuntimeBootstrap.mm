//
//  CKRuntimeBootstrap.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-05-05.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSObject+Runtime.h"
#import "NSObject+Runtime_private.h"
#import "CKClassPropertyDescriptor_private.h"

/** We precompute descriptors at launch to speed up application at runtime.
 */
bool precompute_runtime_descriptors(){
    NSArray* AppCoreKitClasses = [NSObject allClassesWithPrefix:@"CK"];
    NSArray* ViewsClasses = [NSObject allClassesKindOfClass:[UIView class]];
    
    for(Class c in AppCoreKitClasses){
        [[CKClassPropertyDescriptorManager defaultManager]allPropertiesForClass:c];
    }
    
    for(Class c in ViewsClasses){
        [[CKClassPropertyDescriptorManager defaultManager]allPropertiesForClass:c];
    }
    
    return true;
}

static bool bo_precompute_runtime_descriptors = precompute_runtime_descriptors();
