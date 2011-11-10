//
//  CKLocalizationManager.h
//  Volvo
//
//  Created by Sebastien Morel on 11-11-10.
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
