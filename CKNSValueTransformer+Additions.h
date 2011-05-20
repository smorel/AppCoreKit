//
//  CKSerializer.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-05-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKObjectProperty.h"

NSDictionary* CKEnumDictionaryFunc(NSString* strValues, ...);
#define CKEnumDictionary(...) CKEnumDictionaryFunc([NSString stringWithUTF8String:#__VA_ARGS__],__VA_ARGS__)


@interface NSValueTransformer (CKAddition)

//tranform
+ (void)transform:(id)object inProperty:(CKObjectProperty*)property;
+ (void)transform:(NSDictionary*)source toObject:(id)target;
+ (id)transform:(id)source toClass:(Class)type;

//mappings
+ (void)transform:(id)source toObject:(id)target usingMappings:(NSDictionary*)mappings;

//helpers for non NSObject class
+ (NSInteger)convertEnumFromObject:(id)object withEnumDefinition:(NSDictionary*)enumDefinition;

+ (CGSize)convertCGSizeFromObject:(id)object;
+ (CGRect)convertCGRectFromObject:(id)object;
+ (CGPoint)convertCGPointFromObject:(id)object;

+ (char)convertCharFromObject:(id)object;
+ (NSInteger)convertIntegerFromObject:(id)object;
+ (short)convertShortFromObject:(id)object;
+ (long)convertLongFromObject:(id)object;
+ (long long)convertLongLongFromObject:(id)object;
+ (unsigned char)convertUnsignedCharFromObject:(id)object;
+ (NSUInteger)convertUnsignedIntFromObject:(id)object;
+ (unsigned short)convertUnsignedShortFromObject:(id)object;
+ (unsigned long)convertUnsignedLongFromObject:(id)object;
+ (unsigned long long)convertUnsignedLongLongFromObject:(id)object;
+ (CGFloat)convertFloatFromObject:(id)object;
+ (double)convertDoubleFromObject:(id)object;
+ (BOOL)convertBoolFromObject:(id)object;
+ (Class)convertClassFromObject:(id)object;
+ (SEL)convertSelectorFromObject:(id)object;

@end


@interface NSObject (CKTransformAdditions)
+ (SEL)convertFromObjectSelector:(id)object;
+ (SEL)convertToObjectSelector:(id)object;
+ (SEL)valueTransformerObjectSelector:(id)object;
+ (id)convertFromObject:(id)object;
@end

@interface UIColor (CKTransformAdditions)
+ (UIColor*)convertFromNSString:(NSString*)str;
+ (UIColor*)convertFromNSNumber:(NSNumber*)n;
+ (NSString*)convertToNSString:(UIColor*)color;
@end

@interface UIImage (CKTransformAdditions)
+ (UIImage*)convertFromNSString:(NSString*)str;
+ (UIImage*)convertFromNSURL:(NSURL*)url;
+ (UIImage*)convertFromNSArray:(NSArray*)array;
+ (NSString*)convertToNSString:(UIImage*)image;
@end