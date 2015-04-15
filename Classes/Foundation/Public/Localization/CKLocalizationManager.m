//
//  CKLocalizationManager.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import "CKLocalizationManager.h"
#import "CKLocalization.h"
#import <UIKit/UIKit.h>
#import "NSObject+Runtime.h"
#import "CKLocalizationManager_Private.h"
#import "CKDebug.h"
#import "CKConfiguration.h"
#import "CKResourceManager.h"

@interface CKLocalizationManager() 
@property(nonatomic,retain,readwrite)NSBundle* localizedBundle;
@property (nonatomic, assign) BOOL needsLiveUpdateRefresh;
@end

@implementation CKLocalizationManager
@synthesize language = _language;
@synthesize localizedBundle = _localizedBundle;
@synthesize needsLiveUpdateRefresh = _needsLiveUpdateRefresh;

//Current application bungle to get the languages.
static CKLocalizationManager *sharedInstance = nil;

+ (CKLocalizationManager *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CKLocalizationManager alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    if ((self = [super init])) 
    {
        self.needsLiveUpdateRefresh = NO;
        self.localizedBundle = [NSBundle mainBundle];
        
        //Do not trigger KVO in init when setting the language value
        NSString *deviceLang = [[self.localizedBundle preferredLocalizations] objectAtIndex:0];
        [_language release];
        _language = [deviceLang retain];
	}
    return self;
}

// Gets the current localized string as in NSLocalizedString.
//
// example calls:
// AMLocalizedString(@"Text to localize",@"Alternative text, in case hte other is not find");
- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value {
    return CKGetLocalizedString(self.language,key,value);
}


// Sets the desired language of the ones you have.
// example calls:
// LocalizationSetLanguage(@"Italian");
// LocalizationSetLanguage(@"German");
// LocalizationSetLanguage(@"Spanish");
// 
// If this function is not called it will use the default OS language.
// If the language does not exists y returns the default OS language.
- (void) setLanguage:(NSString*) l{
    if(![l isEqualToString:_language]){
        CKDebugLog(@"preferredLang: %@", l);
        
        CKResetLanguageFileCache();
        
        NSString *path = [[ NSBundle mainBundle ] pathForResource:l ofType:@"lproj" ];
        
        if (path == nil)
            //in case the language does not exists
            [self resetToSystemDefaultLanguage];
        else
            self.localizedBundle = [[NSBundle bundleWithPath:path] retain];
        
        [_language release];
        _language = [l retain];
        
        self.needsLiveUpdateRefresh = YES;
        [CKResourceManager reloadUI];
        [self performSelector:@selector(setNeedsLiveUpdateRefresh:) withObject:@(NO) afterDelay:2];
    }
}

@end



@implementation CKLocalizationManager(CKPrivate)
@dynamic needsLiveUpdateRefresh;

// Resets the localization system, so it uses the OS default language.
//
// example call:
// LocalizationReset;
- (void) resetToSystemDefaultLanguage
{
    self.language = [[self.localizedBundle preferredLocalizations] objectAtIndex:0];
}


- (void)reloadBundleAtPath:(NSString *)path {
  //  if([[CKConfiguration sharedInstance]resourcesLiveUpdateEnabled]){
        self.localizedBundle = [NSBundle bundleWithPath:path];
  //  }
}

@end