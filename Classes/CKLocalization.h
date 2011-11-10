//
//  CKLocalization.h
//  CloudKit
//
//  Created by Fred Brunel on 10-02-22.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSMutableArray* CKLocalizationStringTableNames;

/** TODO
 */
NSString *CKLocalizationCurrentLocalization(void);
NSString* CKGetLocalizedString(NSBundle* bundle,NSString* key,NSString* value);


/** TODO
 */
#define _(key) CKGetLocalizedString([NSBundle mainBundle], key, key)
