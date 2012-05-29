//
//  CKLocalization.h
//  CloudKit
//
//  Created by Fred Brunel on 10-02-22.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKLocalizationManager.h"


extern NSMutableArray* CKLocalizationStringTableNames;

/** TODO
 */
NSString *CKLocalizationCurrentLocalization(void);
NSString* CKGetLocalizedString(NSBundle* bundle,NSString* key,NSString* value);


/** TODO
 */
#if __has_feature(objc_arc)
#define _(key) [[CKLocalizedString alloc]initWithLocalizedKey:key]
#else
#define _(key) [[[CKLocalizedString alloc]initWithLocalizedKey:key]autorelease]
#endif