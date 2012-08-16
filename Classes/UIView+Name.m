//
//  UIView+Name.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "UIView+Name.h"
#import <objc/runtime.h>
#import "CKStyleManager.h"
#import "CKStyle+Parsing.h"
#import "CKDebug.h"

static char kUIViewNameKey;

@implementation UIView (CKName)
@dynamic name;

- (void)setName:(NSString *)name{
    objc_setAssociatedObject(self, 
                             &kUIViewNameKey,
                             name,
                             OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString*)name{
    return objc_getAssociatedObject(self, &kUIViewNameKey);
}


- (id)viewWithKeyPath:(NSString*)keyPath{
    NSArray* ar = [keyPath componentsSeparatedByString:@"."];
    
    id currentView = self;
    for(NSString* key in ar){
        id oldCurrentView = currentView;
        
        NSArray* propertyNames = [currentView allPropertyNames];
        if([propertyNames indexOfObject:key] != NSNotFound){
            currentView = [currentView valueForKey:key];
        }else if([currentView isKindOfClass:[UIView class]]){
            for(UIView* view in [currentView subviews]){
                if([[view name]isEqualToString:key]){
                    currentView = view;
                    break;
                }
            }
        }
        
        if(currentView == oldCurrentView){
            CKDebugLog( @"Could not find view for keypath : %@ in %@",keyPath,self);
        }
    }
    
    return (currentView == self || ![currentView isKindOfClass:[UIView class]]) ? nil : currentView;
}


@end


@implementation UIBarButtonItem (CKName)
@dynamic name;

- (void)setName:(NSString *)name{
    objc_setAssociatedObject(self, 
                             &kUIViewNameKey,
                             name,
                             OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString*)name{
    return objc_getAssociatedObject(self, &kUIViewNameKey);
}

@end
