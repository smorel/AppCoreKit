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

/** This precomputes runtime property descriptors for the classes we use the most.
 This speed-up operattion that requiers access to runtime descriptors at runtime like conversions or stylesheet application.
 */
bool precompute_runtime_descriptors(){
    dispatch_queue_t _queue = dispatch_queue_create("CKRuntimeBootstrap", DISPATCH_QUEUE_CONCURRENT);
    
    NSMutableSet* set = [NSMutableSet set];
    [set addObjectsFromArray: [NSObject allClassesKindOfClass:[UIView class]] ];
    [set addObjectsFromArray: [NSObject allClassesKindOfClass:[UIViewController class]] ];
    [set addObjectsFromArray: [NSObject allClassesKindOfClass: NSClassFromString(@"CKLayoutBox")] ];
    
    NSArray* allObjects = [set allObjects];
    allObjects = [allObjects filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        Class c = evaluatedObject;
        NSString* className = [c description];
        if([className hasPrefix:@"_"] || ![className hasPrefix:@"UI"] || ![className hasPrefix:@"CK"])
            return NO;
        return YES;
    }]];
    
    
    dispatch_apply(allObjects.count, _queue, ^(size_t index) {
        Class c = [allObjects objectAtIndex:index];
        [[CKClassPropertyDescriptorManager defaultManager]allPropertiesForClass:c];
    });
    
    dispatch_release(_queue);
    
    return true;
}

static bool bo_precompute_runtime_descriptors = precompute_runtime_descriptors();
