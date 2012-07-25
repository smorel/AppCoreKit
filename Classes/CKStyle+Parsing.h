//
//  CKStyle+Parsing.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSValueTransformer+Additions.h"


/**
 */
@interface NSMutableDictionary (CKStyleParsing)

- (UIColor*) colorForKey:(NSString*)key;
- (NSArray*) colorArrayForKey:(NSString*)key;
- (NSArray*) cgFloatArrayForKey:(NSString*)key;
- (UIImage*) imageForKey:(NSString*)key;
- (NSInteger) enumValueForKey:(NSString*)key withEnumDescriptor:(CKEnumDescriptor*)enumDescriptor;
- (NSInteger) bitMaskValueForKey:(NSString*)key withEnumDescriptor:(CKEnumDescriptor*)enumDescriptor;
- (CGSize) cgSizeForKey:(NSString*)key;
- (CGFloat) cgFloatForKey:(NSString*)key;
- (NSString*) stringForKey:(NSString*)key;
- (NSInteger) integerForKey:(NSString*)key;
- (BOOL) boolForKey:(NSString*)key;

- (id)setObjectForKey:(NSString*)key inProperty:(CKProperty*)property;

@end
