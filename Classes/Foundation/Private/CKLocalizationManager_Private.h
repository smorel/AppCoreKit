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

@property (nonatomic, assign) BOOL needsLiveUpdateRefresh;
//resets this system.
- (void)resetToSystemDefaultLanguage;
- (void)reloadBundleAtPath:(NSString*)path;

@end
