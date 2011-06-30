//
//  CKSerializer.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-05-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKObjectProperty.h"
#import "CKDocumentArray.h"


/** TODO
 */
NSDictionary* CKEnumDictionaryFunc(NSString* strValues, ...);


/** TODO
 */
#define CKEnumDictionary(...) CKEnumDictionaryFunc([NSString stringWithUTF8String:#__VA_ARGS__],__VA_ARGS__)


/** TODO
 */
@interface NSValueTransformer (CKAddition)

//tranform
+ (id)transform:(id)object inProperty:(CKObjectProperty*)property;
+ (id)transform:(id)source toClass:(Class)type;
+ (id)transformProperty:(CKObjectProperty*)property toClass:(Class)type;

+ (void)transform:(NSDictionary*)source toObject:(id)target;

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


/** TODO
 */
@interface NSObject (CKTransformAdditionsCreate)
+ (id)objectFromDictionary:(NSDictionary*)dictionary;
@end


/** TODO
 */
@interface NSArray (CKTransformAdditionsCreate)
+ (id)objectArrayFromDictionaryArray:(NSArray*)array;
@end


/** TODO
 */
@interface NSObject (CKTransformAdditions)
+ (SEL)convertFromObjectSelector:(id)object;
+ (SEL)convertFromObjectWithContentClassNameSelector:(id)object;
+ (SEL)convertToObjectSelector:(id)object;
+ (SEL)valueTransformerObjectSelector:(id)object;
+ (id)convertFromObject:(id)object;
@end


/** TODO
 */
@interface UIColor (CKTransformAdditions)
+ (UIColor*)convertFromNSString:(NSString*)str;
+ (UIColor*)convertFromNSNumber:(NSNumber*)n;
+ (NSString*)convertToNSString:(UIColor*)color;
@end


/** TODO
 */
@interface UIImage (CKTransformAdditions)
+ (UIImage*)convertFromNSString:(NSString*)str;
+ (UIImage*)convertFromNSURL:(NSURL*)url;
+ (UIImage*)convertFromNSArray:(NSArray*)array;
+ (NSString*)convertToNSString:(UIImage*)image;
@end


/** TODO
 */
@interface NSNumber (CKTransformAdditions)
+ (NSNumber*)convertFromNSString:(NSString*)str;
+ (NSString*)convertToNSString:(NSNumber*)n;
@end


/** TODO
 */
@interface NSURL (CKTransformAdditions)
+ (NSURL*)convertFromNSString:(NSString*)str;
+ (NSString*)convertToNSString:(NSURL*)n;
@end


/** TODO
 */
@interface NSDate (CKTransformAdditions)
+ (NSDate*)convertFromNSString:(NSString*)str withFormat:(NSString*)format;
+ (NSString*)convertToNSString:(NSDate*)n withFormat:(NSString*)format;
@end


/** TODO
 */
@interface NSArray (CKTransformAdditions)
+ (NSArray*)convertFromNSArray:(NSArray*)array withContentClassName:(NSString*)className;
@end


/** TODO
 */
@interface CKDocumentArray (CKTransformAdditions)
+ (CKDocumentArray*)convertFromNSArray:(NSArray*)array withContentClassName:(NSString*)className;
@end


/** TODO
 */
@interface NSIndexPath (CKTransformAdditions)
+ (NSIndexPath*)convertFromNSString:(NSString*)str;
+ (NSString*)convertToNSString:(NSIndexPath*)indexPath;
@end