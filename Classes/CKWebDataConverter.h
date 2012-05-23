//
//  CKWebDataConverter.h
//  CloudKit
//
//  Created by Guillaume Campagna on 12-05-18.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKWebDataConverter : NSObject

+ (void)addConverter:(id (^)(NSData *, NSURLResponse *response))converter forMIMEPredicate:(NSPredicate*)predicate;

+(id)convertData:(NSData*)data fromResponse:(NSURLResponse*)response;

@end
