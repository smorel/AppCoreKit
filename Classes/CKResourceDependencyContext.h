//
//  CKResourceDependencyContext.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-07-18.
//  Copyright (c) 2013 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKResourceDependencyContext : NSObject

+ (void)beginContext;

+ (NSSet*)endContext;

+ (void)addDependency:(NSString*)path;

@end
