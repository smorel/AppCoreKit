//
//  CKUIFont+ValueTransformer.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-16.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface UIFont (CKValueTransformer)
+ (UIFont*)convertFromNSString:(NSString*)str;
+ (UIFont*)convertFromNSNumber:(NSNumber*)n;
+ (NSString*)convertToNSString:(UIFont*)color;
@end