//
//  CKNSIndexPath+ValueTransformer.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-11.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 */
@interface NSIndexPath (CKValueTransformer)
+ (NSIndexPath*)convertFromNSString:(NSString*)str;
+ (NSString*)convertToNSString:(NSIndexPath*)indexPath;
@end