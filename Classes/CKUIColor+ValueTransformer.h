//
//  CKUIColor+ValueTransformer.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-11.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


/**
 */
@interface UIColor (CKValueTransformer)
+ (UIColor*)convertFromNSString:(NSString*)str;
+ (UIColor*)convertFromNSNumber:(NSNumber*)n;
+ (NSString*)convertToNSString:(UIColor*)color;
@end