//
//  VVLocalizedString.h
//  Volvo
//
//  Created by Sebastien Morel on 11-11-10.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKLocalizedString : NSString

//You can set either key or localizedStrings but not both
@property(nonatomic,retain)NSString* key;
@property(nonatomic,retain)NSDictionary* localizedStrings;

- (id)initWithLocalizedKey:(NSString*)key;
- (id)initWithLocalizedStrings:(NSDictionary*)strings;

- (NSString*)localizedString;

@end
