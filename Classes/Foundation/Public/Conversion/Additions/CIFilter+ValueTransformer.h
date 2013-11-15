//
//  CIFilter+ValueTransformer.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-11-14.
//  Copyright (c) 2013 Wherecloud. All rights reserved.
//

#import <CoreImage/CoreImage.h>

@interface CIFilter (ValueTransformer)

/**
 */
+ (CIFilter*)convertFromNSString:(NSString*)str;

/**
 */
+ (CIFilter*)convertFromNSDictionary:(NSDictionary*)dictionary;

@end
