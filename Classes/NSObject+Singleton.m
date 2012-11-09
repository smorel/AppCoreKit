//
//  Object+CKSingleton.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "NSObject+Singleton.h"

static NSMutableDictionary* CKObjectSingletons = nil;

@implementation NSObject (CKSingleton)
static dispatch_once_t onceToken;

+ (id)newSharedInstance{
    return [[[self class]alloc]init];
}

+ (void)setSharedInstance:(id)instance{  
    dispatch_once(&onceToken, ^{
        CKObjectSingletons = [[NSMutableDictionary alloc]init];
    });
    
    [CKObjectSingletons setObject:instance forKey:(id)[self class]];
}

+ (id)sharedInstance{    
    dispatch_once(&onceToken, ^{
        CKObjectSingletons = [[NSMutableDictionary alloc]init];
    });
    
    id instance = nil;
    @synchronized (self) {
        instance = [CKObjectSingletons objectForKey:(id)[self class]];
        if(!instance){
            instance = [self newSharedInstance];
            [CKObjectSingletons setObject:instance forKey:(id)[self class]];
            [instance release];
        }
    }
    
    return instance;
}

@end
