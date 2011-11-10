//
//  VVLocalizedString.m
//  Volvo
//
//  Created by Sebastien Morel on 11-11-10.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import "CKLocalizedString.h"
#import "CKLocalizationManager.h"
#import "CKNSObject+Bindings.h"

@implementation CKLocalizedString
@synthesize key = _key;
@synthesize localizedStrings = _localizedStrings;

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
    [self clearBindingsContext];
    [_key release];
    _key = nil;
    [_localizedStrings release];
    _localizedStrings = nil;
    [super dealloc];
}

- (NSUInteger)length{
    return [self.localizedString length];
}

- (unichar)characterAtIndex:(NSUInteger)index{
    return [self.localizedString characterAtIndex:index];
}

- (id)copyWithZone:(NSZone *)zone{
	CKLocalizedString *newString = [[[self class] alloc] init];
    newString.key = self.key;
    newString.localizedStrings = self.localizedStrings;
    return newString;
}

- (NSString*)localizedString{
    if(_localizedStrings){
        NSString* currentLanguage = [[CKLocalizationManager sharedManager]language];
        return [_localizedStrings objectForKey:currentLanguage];
    }
    else if(_key){
        return [[CKLocalizationManager sharedManager]localizedStringForKey:self.key value:self.key]; 
    }
    return nil;
}

- (NSString*)description{
    return [self localizedString];
}
 
@end
