//
//  CKLocalizationManager_Private.h
//  CloudKit
//
//  Created by Sebastien Morel on 12-06-26.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKLocalizationManager.h"

/**
 */
@interface CKLocalizationManager(CKPrivate)

//resets this system.
- (void)resetToSystemDefaultLanguage;
- (void)refreshUI;
- (void)reloadBundleAtPath:(NSString*)path;

@end
