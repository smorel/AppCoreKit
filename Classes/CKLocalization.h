//
//  CKLocalization.h
//  CloudKit
//
//  Created by Fred Brunel on 10-02-22.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define _(key) NSLocalizedString(key, key)

NSString *CKLocalizationCurrentLocalization(void);