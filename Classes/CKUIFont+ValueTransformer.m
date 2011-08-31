//
//  CKUIFont+ValueTransformer.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-16.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKUIFont+ValueTransformer.h"


@implementation UIFont (CKValueTransformer)

+ (UIFont*)convertFromNSString:(NSString*)str{
    NSAssert(NO,@"Not implemented");
    return nil;
    
	/*NSArray* components = [str componentsSeparatedByString:@" "];
    if([components count] == 1){
        NSString* str = [components objectAtIndex:0];
    }*/
}

+ (UIFont*)convertFromNSNumber:(NSNumber*)n{
    NSAssert(NO,@"Not implemented");
    return nil;
}

+ (NSString*)convertToNSString:(UIFont*)color{
    NSAssert(NO,@"Not implemented");
    return nil;
}

@end
