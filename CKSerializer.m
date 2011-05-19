//
//  CKSerializer.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-05-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKSerializer.h"

@interface      CKNSURLValueTransformer : NSValueTransformer {} @end
@implementation CKNSURLValueTransformer
+ (Class)transformedValueClass { return [NSURL class]; }
- (id)transformedValue:(id)value { 
	return nil;
}
@end

@interface      CKNSDateValueTransformer : NSValueTransformer {} @end
@implementation CKNSDateValueTransformer
+ (Class)transformedValueClass { return [NSDate class]; }
- (id)transformedValue:(id)value { 
	return nil;
}
@end

@interface      CKCGPointValueTransformer : NSValueTransformer {} @end
@implementation CKCGPointValueTransformer
+ (Class)transformedValueClass { return [NSValue class]; }
- (id)transformedValue:(id)value { 
	return nil;
}
@end

@interface      CKCGRectValueTransformer : NSValueTransformer {} @end
@implementation CKCGRectValueTransformer
+ (Class)transformedValueClass { return [NSValue class]; }
- (id)transformedValue:(id)value { 
	return nil;
}
@end

@interface      CKCGSizeValueTransformer : NSValueTransformer {} @end
@implementation CKCGSizeValueTransformer
+ (Class)transformedValueClass { return [NSValue class]; }
- (id)transformedValue:(id)value { 
	return nil;
}
@end

@interface      CKNSStringValueTransformer : NSValueTransformer {} @end
@implementation CKNSStringValueTransformer
+ (Class)transformedValueClass { return [NSString class]; }
- (id)transformedValue:(id)value { 
	return nil;
}
@end

@interface      CKNSNumberValueTransformer : NSValueTransformer {} @end
@implementation CKNSNumberValueTransformer
+ (Class)transformedValueClass { return [NSNumber class]; }
- (id)transformedValue:(id)value { 
	return nil;
}
@end

@interface      CKEnumValueTransformer : NSValueTransformer {} @end
@implementation CKEnumValueTransformer
+ (Class)transformedValueClass { return [NSNumber class]; }
- (id)transformedValue:(id)value { 
	return nil;
}
@end

@interface      CKImageValueTransformer : NSValueTransformer {} @end
@implementation CKImageValueTransformer
+ (Class)transformedValueClass { return [UIImage class]; }
- (id)transformedValue:(id)value { 
	return nil;
}
@end

@interface      CKNSArrayValueTransformer : NSValueTransformer {} @end
@implementation CKNSArrayValueTransformer
+ (Class)transformedValueClass { return [NSArray class]; }
- (id)transformedValue:(id)value { 
	return nil;
}
@end

@interface      CKNSSetValueTransformer : NSValueTransformer {} @end
@implementation CKNSSetValueTransformer
+ (Class)transformedValueClass { return [NSSet class]; }
- (id)transformedValue:(id)value { 
	return nil;
}
@end

@interface      CKDocumentCollectionValueTransformer : NSValueTransformer {} @end
@implementation CKDocumentCollectionValueTransformer
+ (Class)transformedValueClass { return [CKDocumentCollection class]; }
- (id)transformedValue:(id)value { 
	return nil;
}
@end

@interface      CKUIColorValueTransformer : NSValueTransformer {} @end
@implementation CKUIColorValueTransformer
+ (Class)transformedValueClass { return [UIColor class]; }
- (id)transformedValue:(id)value { 
	return nil;
}
@end

@implementation CKSerializer

+ (void)transform:(id)object inProperty:(CKObjectProperty*)property{
	property
	@property (nonatomic, assign, readwrite) Class type;
	@property (nonatomic, assign, readwrite) SEL metaDataSelector;
	@property (nonatomic, assign, readwrite) CKClassPropertyDescriptorType propertyType;
}

+ (void)transform:(id)source toObject:(id)target usingMappings:(NSDictionary*)mappings{
	for(NSString* sourceKeyPath in [mappings allKeys]){
		NSString* targetKeyPath = [mappings objectForKey:sourceKeyPath];
		id sourceObject = [source valueForKeyPath:sourceKeyPath];
		CKObjectProperty* targetProperty = [CKObjectProperty propertyWithObject:target keyPath:targetKeyPath];
		[self transform:sourceObject inProperty:targetProperty];
	}
}

+ (UIColor*)colorFromObject:(id)object{
}

+ (NSArray*)arrayFromObject:(id)object withContentClass:(Class)contentClass{
}

+ (NSSet*)setFromObject:(id)object withContentClass:(Class)contentClass{
}

+ (CKDocumentCollection*)documentCollectionFromObject:(id)object withContentClass:(Class)contentClass{
}

+ (UIImage*)imageFromObject:(id)object{
}

+ (NSInteger)enumFromObject:(id)object withEnumDefinition:(NSDictionary*)enumDefinition{
}

+ (NSNumber*)numberFormObject:(id)object{
}

+ (char)charFromObject:(id)object{
}

+ (NSInteger)integerFromObject:(id)object{
}

+ (short)shortFromObject:(id)object{
}

+ (long)longFromObject:(id)object{
}

+ (long long)longLongFromObject:(id)object{
}

+ (unsigned char)unsignedCharFromObject:(id)object{
}

+ (NSUInteger)unsignedIntFromObject:(id)object{
}

+ (unsigned short)unsignedShortFromObject:(id)object{
}

+ (unsigned long)unsignedLongFromObject:(id)object{
}

+ (unsigned long long)unsignedLongLongFromObject:(id)object{
}

+ (CGFloat)floatFromObject:(id)object{
}

+ (double)doubleFromObject:(id)object{
}

+ (NSString*)stringFormObject:(id)object{
}

+ (CGSize)cgSizeFromObject:(id)object{
}

+ (CGRect)cgRectFromObject:(id)object{
}

+ (CGPoint)cgPointFromObject:(id)object{
}

+ (NSDate*)dateFromObject:(id)object withFormat:(NSString*)format{
}

+ (NSURL*)urlFromObject:(id)object{
}

@end
