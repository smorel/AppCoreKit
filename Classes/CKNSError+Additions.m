//
//  CKNSError+Additions.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-09-23.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKNSError+Additions.h"

NSString * const CKErrorsKey = @"CKErrorsKey";
NSString * const CKErrorDetailsKey = @"CKErrorDetailsKey";
NSString * const CKErrorCodeKey = @"CKErrorCodeKey";

NSError* aggregateError(NSError* error,NSString* domain,NSInteger code,NSString* str){
    if(error == nil){
        error = [NSError errorWithDomain:domain code:code userInfo:[NSDictionary dictionaryWithObject:[NSMutableArray array] forKey:CKErrorsKey]];
    }
    
    NSMutableArray* array = (NSMutableArray*)[[error userInfo]objectForKey:CKErrorsKey];
    [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:code],CKErrorCodeKey,
                      str,CKErrorDetailsKey,nil]];
    return error;
}
