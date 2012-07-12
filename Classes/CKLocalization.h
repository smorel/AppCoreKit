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
#if __has_feature(objc_arc)
#define _(key) [[CKLocalizedString alloc]initWithLocalizedKey:key]
#else
#define _(key) [[[CKLocalizedString alloc]initWithLocalizedKey:key]autorelease]
#endif