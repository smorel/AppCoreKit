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
    if(!CKObjectSingletons){
        CKObjectSingletons = [[NSMutableDictionary alloc]init];
    }else{
        id instance = [CKObjectSingletons objectForKey:(id)[self class]];
        if(instance){
            return instance;
        }
    }
    
    id instance = [[[self class]alloc]init];
    [CKObjectSingletons setObject:instance forKey:(id)[self class]];
    return instance;
}

@end
