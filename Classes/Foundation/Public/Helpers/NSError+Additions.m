//
//  NSError+Additions.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "NSError+Additions.h"

NSString * const CKErrorsKey = @"CKErrorsKey";
NSString * const CKErrorDetailsKey = @"CKErrorDetailsKey";
NSString * const CKErrorCodeKey = @"CKErrorCodeKey";

NSError* aggregateError(NSError* error,NSString* domain,NSInteger code,NSString* str){
    if(error == nil){
        error = [NSError errorWithDomain:domain code:code userInfo:[NSDictionary dictionaryWithObject:[NSMutableArray array] forKey:CKErrorsKey]];
    }
    
    NSMutableArray* array = (NSMutableArray*)[[error userInfo]objectForKey:CKErrorsKey];
    [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:code],CKErrorCodeKey,
                      str,CKErrorDetailsKey,nil]];
    return error;
}
