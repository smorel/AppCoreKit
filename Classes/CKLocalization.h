//
//  CKLocalization.h
//  CloudKit
//
//  Created by Fred Brunel on 10-02-22.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


/** TODO
 */
NSString *CKLocalizationCurrentLocalization(void);
NSString* CKLocalizedString(NSString* key,NSString* value);


/** TODO
 */
#define _(key) CKLocalizedString(key,key)