//
//  CKNSURL+ValueTransformer.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-11.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>


/** TODO
 */
@interface NSURL (CKValueTransformer)
+ (NSURL*)convertFromNSString:(NSString*)str;
+ (NSString*)convertToNSString:(NSURL*)n;
@end