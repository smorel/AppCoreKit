//
//  CKObject+CKSingleton.m
//  CloudKit
//
//  Created by Sebastien Morel on 12-04-13.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKNSObject+CKSingleton.h"

static NSMutableDictionary* CKObjectSingletons = nil;

@implementation NSObject (CKSingleton)

+ (id)sharedInstance{    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CKObjectSingletons = [[NSMutableDictionary alloc]init];
    });
    
    id instance = [CKObjectSingletons objectForKey:(id)[self class]];
    if(!instance){
        instance = [[[self class]alloc]init];
        [CKObjectSingletons setObject:instance forKey:(id)[self class]];
        [instance release];
    }
    
    return instance;
}

@end
