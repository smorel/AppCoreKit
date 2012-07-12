//
//  VVLocalizedString.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 */
@interface CKLocalizedString : NSString

///-----------------------------------
/// @name Initializing Localized String objects
///-----------------------------------

/**
 */
- (id)initWithLocalizedKey:(NSString*)key;

/**
 */
- (id)initWithLocalizedStrings:(NSDictionary*)strings;

///-----------------------------------
/// @name Setuping Localized String
///-----------------------------------

/** You can set either key or localizedStrings but not both
 */
@property(nonatomic,retain)NSString* key;

/** You can set either key or localizedStrings but not both
 */
@property(nonatomic,retain)NSDictionary* localizedStrings;

@end



@interface NSString(CKLocalization)

///-----------------------------------
/// @name Creating Localized String Objects
///-----------------------------------

/**
 */
+ (NSString*)stringWithLocalizedStrings:(NSDictionary*)localizedStrings;

/**
 */
+ (NSString*)stringWithLocalizedKey:(NSString*)localizedKey;

@end