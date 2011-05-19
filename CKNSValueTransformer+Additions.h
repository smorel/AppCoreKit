//
//  CKSerializer.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-05-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKObjectProperty.h"


@interface NSValueTransformer (CKAddition)

//tranform
+ (void)transform:(id)object inProperty:(CKObjectProperty*)property;
+ (void)transform:(NSDictionary*)source toObject:(id)target;
+ (id)transform:(id)source toClass:(Class)type;

//mappings
+ (void)transform:(id)source toObject:(id)target usingMappings:(NSDictionary*)mappings;

//helpers
+ (UIColor*)UIColorFromObject:(id)object;
+ (NSArray*)NSArrayFromObject:(id)object withContentClass:(Class)contentClass;
+ (NSSet*)NSSetFromObject:(id)object withContentClass:(Class)contentClass;
+ (UIImage*)UImageFromObject:(id)object;
+ (NSInteger)enumFromObject:(id)object withEnumDefinition:(NSDictionary*)enumDefinition;
+ (NSNumber*)NSNumberFormObject:(id)object;
+ (NSDate*)NSDateFromObject:(id)object withFormat:(NSString*)format;
+ (NSURL*)NSURLFromObject:(id)object;
+ (NSString*)NSStringFormObject:(id)object;
+ (CGSize)CGSizeFromObject:(id)object;
+ (CGRect)CGRectFromObject:(id)object;
+ (CGPoint)CGPointFromObject:(id)object;
+ (char)charFromObject:(id)object;
+ (NSInteger)integerFromObject:(id)object;
+ (short)shortFromObject:(id)object;
+ (long)longFromObject:(id)object;
+ (long long)longLongFromObject:(id)object;
+ (unsigned char)unsignedCharFromObject:(id)object;
+ (NSUInteger)unsignedIntFromObject:(id)object;
+ (unsigned short)unsignedShortFromObject:(id)object;
+ (unsigned long)unsignedLongFromObject:(id)object;
+ (unsigned long long)unsignedLongLongFromObject:(id)object;
+ (CGFloat)floatFromObject:(id)object;
+ (double)doubleFromObject:(id)object;
+ (BOOL)boolFromObject:(id)object;
+ (Class)classFromObject:(id)object;
+ (SEL)selectorFromObject:(id)object;

@end
