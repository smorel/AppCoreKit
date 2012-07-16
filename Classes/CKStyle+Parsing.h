//
//  CKStyle+Parsing.h
//  CloudKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKNSValueTransformer+Additions.h"


/** TODO
 */
@interface NSMutableDictionary (CKStyleParsing)

- (UIColor*) colorForKey:(NSString*)key;
- (NSArray*) colorArrayForKey:(NSString*)key;
- (NSArray*) cgFloatArrayForKey:(NSString*)key;
- (UIImage*) imageForKey:(NSString*)key;
- (NSInteger) enumValueForKey:(NSString*)key withEnumDescriptor:(CKEnumDescriptor*)enumDescriptor;
- (CGSize) cgSizeForKey:(NSString*)key;
- (CGFloat) cgFloatForKey:(NSString*)key;
- (NSString*) stringForKey:(NSString*)key;
- (NSInteger) integerForKey:(NSString*)key;

- (id)setObjectForKey:(NSString*)key inProperty:(CKObjectProperty*)property;

@end
