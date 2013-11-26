//
//  CKLocalization.h
//  AppCoreKit
//
//  Created by Fred Brunel.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKLocalizationManager.h"



#ifdef __cplusplus
extern "C" {
#endif
    
/**
 */
NSString *CKLocalizationCurrentLocalization(void);

/**
 */
NSString* CKGetLocalizedString(NSString* localization,NSString* key,NSString* value);

/**
 */
void CKResetLanguageFileCache();

/**
 */
CKLocalizedString* CKLocalizedStringWithString(NSString* string);


/**
 */
UIImage* CKLocalizedImageNamed(NSString* imageNamed);
    
#ifdef __cplusplus
}
#endif

/**
 */
#define _(key) CKLocalizedStringWithString(key)

#define _C(key) CKLocalizedStringWithString([NSString stringWithFormat:@"%@.%@",[[self class]description],key])

/**
 */
#define _img(imageName) CKLocalizedImageNamed(imageName)