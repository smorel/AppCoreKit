//
//  UIView+Name.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "UIView+Name.h"
#import <objc/runtime.h>
#import "CKDebug.h"
#import "NSObject+Runtime.h"

@implementation UIView (Factory)

+ (id)view{
    return [[[[self class]alloc]init]autorelease];
}

+ (id)viewWithFrame:(CGRect)frame{
    return [[[[self class]alloc]initWithFrame:frame]autorelease];
}

@end


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
        
        //Search for sub view with name first
        BOOL found = NO;
        if([currentView isKindOfClass:[UIView class]]){
            for(UIView* view in [currentView subviews]){
                if([[view name]isEqualToString:key]){
                    currentView = view;
                    found = YES;
                    break;
                }
            }
        }
        
        //Search for sub view with property name second
        if(!found){
            NSArray* propertyNames = [currentView allPropertyNames];
            if([propertyNames indexOfObject:key] != NSNotFound){
                currentView = [currentView valueForKey:key];
            }
        }
        
        if(currentView == oldCurrentView){
            CKDebugLog( @"Could not find view for keypath : %@ in %@",keyPath,self);
            return nil;
        }
    }
    
    return (currentView == self || ![currentView isKindOfClass:[UIView class]]) ? nil : currentView;
}


- (id)viewWithName:(NSString*)name{
    if([self.name isEqualToString:name])
        return self;
    
    for(UIView* v in self.subviews){
        UIView* result = [v viewWithName:name];
        if(result)
            return result;
    }
    
    return nil;
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
