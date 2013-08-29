//
//  CKResourceDependencyContext.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-07-18.
//  Copyright (c) 2013 Wherecloud. All rights reserved.
//

#import "CKResourceDependencyContext.h"
#import "NSObject+Singleton.h"

@interface CKResourceDependencyContext()
@property(nonatomic,retain) NSMutableArray* contextStack;
@end

@implementation CKResourceDependencyContext

+ (void)beginContext{
    CKResourceDependencyContext* manager = [CKResourceDependencyContext sharedInstance];
    if(manager.contextStack == nil){
        manager.contextStack = [NSMutableArray array];
    }
    
    NSMutableSet* set = [NSMutableSet set];
    [manager.contextStack addObject:set];
}

+ (NSSet*)endContext{
    CKResourceDependencyContext* manager = [CKResourceDependencyContext sharedInstance];
    
    NSSet* set = [[manager.contextStack lastObject]retain];
    [manager.contextStack removeLastObject];
    
    return [set autorelease];
}

+ (NSMutableSet*)currentContext{
    CKResourceDependencyContext* manager = [CKResourceDependencyContext sharedInstance];
    NSMutableSet* set = [[manager.contextStack lastObject]retain];
    return [set autorelease];
}

+ (void)addDependency:(NSString*)path{
    [[self currentContext]addObject:path];
}

@end
