//
//  CKLocalizationManager.h
//  CloudKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import "CKLocalizedString.h"


@interface CKLocalizationManager : NSObject 

@property(nonatomic,retain)NSString* language;

+ (CKLocalizationManager *)sharedManager;

//gets the string localized
- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value;

//resets this system.
- (void) resetToSystemDefaultLanguage;

@end
