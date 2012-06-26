//
//  CKLocalizationManager.h
//  Volvo
//
//  Created by Sebastien Morel on 11-11-10.
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


///-----------------------------------
/// @name Querying strings
///-----------------------------------

/**
 */
- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value;

@end
