//
//  NSValue+ValueTransformer.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 3/13/2014.
//  Copyright (c) 2014 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSValue (ValueTransformer)

/**
 */
+ (NSString*)convertToNSString:(NSValue*)value;

+ (NSString*)convertCGSizeToNSString:(NSValue*)value;
+ (NSString*)convertCGPointToNSString:(NSValue*)value;
+ (NSString*)convertCGRectToNSString:(NSValue*)value;
+ (NSString*)convertCGAffineTransformToNSString:(NSValue*)value;
+ (NSString*)convertCLLocationCoordinate2DToNSString:(NSValue*)value;

@end
