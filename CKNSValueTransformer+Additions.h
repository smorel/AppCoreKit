//
//  CKSerializer.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-05-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKObjectProperty.h"
#import "CKDocumentArray.h"

NSDictionary* CKEnumDictionaryFunc(NSString* strValues, ...);
#define CKEnumDictionary(...) CKEnumDictionaryFunc([NSString stringWithUTF8String:#__VA_ARGS__],__VA_ARGS__)


@interface NSValueTransformer (CKAddition)

//tranform
+ (id)transform:(id)object inProperty:(CKObjectProperty*)property;
+ (id)transform:(id)source toClass:(Class)type;
+ (id)transformProperty:(CKObjectProperty*)property toClass:(Class)type;


+ (void)transform:(NSDictionary*)source toObject:(id)target;
+ (void)transform:(id)source toObject:(id)target usingMappings:(NSDictionary*)mappings;

//helpers for non NSObject class
+ (NSInteger)convertEnumFromObject:(id)object withEnumDefinition:(NSDictionary*)enumDefinition;
+ (NSString*)convertEnumToString:(NSInteger)value withEnumDefinition:(NSDictionary*)enumDefinition;

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

+ (NSString*)convertNSStringFromObject:(id)object;

@end


@interface NSObject (CKTransformAdditions)
+ (SEL)convertFromObjectSelector:(id)object;
+ (SEL)convertFromObjectWithContentClassNameSelector:(id)object;
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

@interface NSNumber (CKTransformAdditions)
+ (NSNumber*)convertFromNSString:(NSString*)str;
+ (NSString*)convertToNSString:(NSNumber*)n;
@end

@interface NSURL (CKTransformAdditions)
+ (NSURL*)convertFromNSString:(NSString*)str;
+ (NSString*)convertToNSString:(NSURL*)n;
@end

@interface NSDate (CKTransformAdditions)
+ (NSDate*)convertFromNSString:(NSString*)str withFormat:(NSString*)format;
+ (NSString*)convertToNSString:(NSDate*)n withFormat:(NSString*)format;
@end

@interface NSArray (CKTransformAdditions)
+ (NSArray*)convertFromNSArray:(NSArray*)array withContentClassName:(NSString*)className;
@end

@interface CKDocumentArray (CKTransformAdditions)
+ (CKDocumentArray*)convertFromNSArray:(NSArray*)array withContentClassName:(NSString*)className;
@end

@interface NSIndexPath (CKTransformAdditions)
+ (NSIndexPath*)convertFromNSString:(NSString*)str;
+ (NSString*)convertToNSString:(NSIndexPath*)indexPath;
@end