//
//  CKLocalizationManager_Private.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
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
