//
//  CKLocalization.h
//  AppCoreKit
//
//  Created by Fred Brunel.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKLocalizationManager.h"

/**
 */
NSString *CKLocalizationCurrentLocalization(void);

/**
 */
NSString* CKGetLocalizedString(NSBundle* bundle,NSString* key,NSString* value);

/**
 */
void CKResetLanguageFileCache();

/**
 */
CKLocalizedString* CKLocalizedStringWithString(NSString* string);


/**
 */
#define _(key) CKLocalizedStringWithString(key)