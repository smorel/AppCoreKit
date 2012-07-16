//
//  CKNSIndexPath+ValueTransformer.h
//  CloudKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>

/** TODO
 */
@interface NSIndexPath (CKValueTransformer)
+ (NSIndexPath*)convertFromNSString:(NSString*)str;
+ (NSString*)convertToNSString:(NSIndexPath*)indexPath;
@end