//
//  VVLocalizedString.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import "CKLocalizedString.h"
#import "CKLocalizationManager.h"
#import "NSObject+Bindings.h"
#import "CKLocalization.h"

@interface CKLocalizationManager()

#if TARGET_IPHONE_SIMULATOR
@property (nonatomic, assign) BOOL needsRefresh;
#endif

- (NSString*)localizedString;
@end

@interface CKLocalizedString()
@property(nonatomic,retain)NSString* currentLanguage;
@property(nonatomic,retain)NSString* currentValue;
@end

@implementation CKLocalizedString
@synthesize key = _key;
@synthesize localizedStrings = _localizedStrings;
@synthesize currentLanguage = _currentLanguage;
@synthesize currentValue = _currentValue;

- (id)initWithLocalizedKey:(NSString*)theKey{
    self = [super init];
    self.key = theKey;
    return self;
}

- (id)initWithLocalizedStrings:(NSDictionary*)strings{
    self = [super init];
    self.localizedStrings = strings;
    return self;
}

- (void)dealloc{
    [_key release];
    _key = nil;
    [_localizedStrings release];
    _localizedStrings = nil;
    [_currentValue release];
    _currentValue = nil;
    [_currentLanguage release];
    _currentLanguage = nil;
    [super dealloc];
}

- (NSUInteger)length{
    return [self.localizedString length];
}

- (unichar)characterAtIndex:(NSUInteger)index{
    return [self.localizedString characterAtIndex:index];
}

- (id)copyWithZone:(NSZone *)zone{
	CKLocalizedString *newString = [[CKLocalizedString allocWithZone:zone]init];
    newString.key = self.key;
    newString.localizedStrings = self.localizedStrings;
    return newString;
}

- (NSString*)localizedString{
    NSString* lng = [[CKLocalizationManager sharedManager]language];
    BOOL needRefresh = ![_currentLanguage isEqualToString:lng];
    
#if TARGET_IPHONE_SIMULATOR
    needRefresh = [[CKLocalizationManager sharedManager] needsRefresh] || needRefresh;
#endif
    
    if(needRefresh){
        self.currentLanguage = lng;
        if(_localizedStrings){
            self.currentValue = [_localizedStrings objectForKey:lng];
        }
        else if(_key){
            self.currentValue = [[CKLocalizationManager sharedManager]localizedStringForKey:self.key value:self.key]; 
        }
    }
    
    return _currentValue;
}

- (NSString*)description{
    return [self localizedString];
}
 
@end




@implementation NSString (CKLocalization)


+ (NSString*)stringWithLocalizedStrings:(NSDictionary*)localizedStrings{
    return [[[CKLocalizedString alloc]initWithLocalizedStrings:localizedStrings]autorelease];
}

+ (NSString*)stringWithLocalizedKey:(NSString*)localizedKey{
    return _(localizedKey);
}

@end
