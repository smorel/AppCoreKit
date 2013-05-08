//
//  NSValueTransformer+CGTypes.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

/**
 */
@interface NSValueTransformer (CKCGTypes)

/**
 */
+ (CGSize)parseStringToCGSize:(NSString*)str;

/**
 */
+ (CGSize)parseDictionaryToCGSize:(NSDictionary*)dictionary;

/**
 */
+ (CGSize)convertCGSizeFromObject:(id)object;

/**
 */
+ (CGRect)parseStringToCGRect:(NSString*)str;

/**
 */
+ (CGRect)parseDictionaryToCGRect:(NSDictionary*)dictionary;

/**
 */
+ (CGRect)convertCGRectFromObject:(id)object;

/**
 */
+ (CGPoint)parseStringToCGPoint:(NSString*)str;

/**
 */
+ (CGPoint)parseDictionaryToCGPoint:(NSDictionary*)dictionary;

/**
 */
+ (CGPoint)convertCGPointFromObject:(id)object;

/**
 */
+ (UIEdgeInsets)parseStringToUIEdgeInsets:(NSString*)str;

/**
 */
+ (UIEdgeInsets)parseDictionaryToUIEdgeInsets:(NSDictionary*)dictionary;

/**
 */
+ (UIEdgeInsets)convertUIEdgeInsetsFromObject:(id)object;

/**
 */
+ (CGColorRef)convertCGColorRefFromObject:(id)object;

/**
 */
+ (CLLocationCoordinate2D)parseStringToCLCoordinate2D:(NSString*)str;

/**
 */
+ (CLLocationCoordinate2D)convertCLLocationCoordinate2DFromObject:(id)object;


/**
 */
+ (CGAffineTransform)parseDictionaryToCGAffineTransform:(NSDictionary*)dictionary;

/**
 */
+ (CGAffineTransform)convertCGAffineTransformFromObject:(id)object;

@end
