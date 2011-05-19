//
//  CKSerializer.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-05-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

//CKNSStringToNSURLTransformer


@interface NSValueTransformer (CKAddition)

+ (void)transform:(id)object inProperty:(CKObjectProperty*)property;
+ (void)transform:(id)source toObject:(id)target usingMappings:(NSDictionary*)mappings;

//helpers
+ (UIColor*)colorFromObject:(id)object;
+ (NSArray*)arrayFromObject:(id)object withContentClass:(Class)contentClass;
+ (NSSet*)setFromObject:(id)object withContentClass:(Class)contentClass;
+ (CKDocumentCollection*)documentCollectionFromObject:(id)object withContentClass:(Class)contentClass;
+ (UIImage*)imageFromObject:(id)object;
+ (NSInteger)enumFromObject:(id)object withEnumDefinition:(NSDictionary*)enumDefinition;
+ (NSNumber*)numberFormObject:(id)object;
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
+ (NSString*)stringFormObject:(id)object;
+ (CGSize)cgSizeFromObject:(id)object;
+ (CGRect)cgRectFromObject:(id)object;
+ (CGPoint)cgPointFromObject:(id)object;
+ (NSDate*)dateFromObject:(id)object withFormat:(NSString*)format;
+ (NSURL*)urlFromObject:(id)object;

@end
