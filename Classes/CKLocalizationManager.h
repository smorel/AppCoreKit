//
//  CKLocalizationManager.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import "CKLocalizedString.h"

/**
 */
@interface CKLocalizationManager : NSObject 

///-----------------------------------
/// @name Singleton
///-----------------------------------

/**
 */
+ (CKLocalizationManager *)sharedManager;

///-----------------------------------
/// @name Getting the current language
///-----------------------------------

/**
 */
@property(nonatomic,retain)NSString* language;

/**
 */
@property(nonatomic,retain,readonly)NSBundle* localizedBundle;


///-----------------------------------
/// @name Querying strings
///-----------------------------------

/**
 */
- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value;

@end
