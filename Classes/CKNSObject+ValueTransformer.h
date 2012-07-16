//
//  CKNSObject+ValueTransformer.h
//  CloudKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>


/** TODO
 */
@interface NSObject (CKValueTransformer)
+ (id)objectFromDictionary:(NSDictionary*)dictionary;
+ (id)convertFromObject:(id)object;
+ (id)convertFromNSArray:(NSArray*)array;
+ (NSString*)convertToNSString:(id)object;
@end