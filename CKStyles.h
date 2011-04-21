//
//  CKNSDictionary+Styles.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-20.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKModelObject.h"

@interface CKStyleFormat : CKModelObject{
}
@property(nonatomic,retain) NSString* format;
@property(nonatomic,assign) Class objectClass;
@property(nonatomic,retain) NSString* propertyName;
@property(nonatomic,retain) NSMutableArray* properties;

- (id)initFormatWithFormat:(NSString*)format;
- (NSString*)formatForObject:(id)object propertyName:(NSString*)propertyName;

@end

@interface NSDictionary (CKKey)
- (BOOL)containsObjectForKey:(NSString*)key;
@end

extern NSString* CKStyleStyles;

@interface NSDictionary (CKStyle)

- (NSArray*)styleFormatsForObject:(id)object propertyName:(NSString*)propertyName;
- (NSDictionary*)styleForObject:(id)object propertyName:(NSString*)propertyName;

@end

@interface NSMutableDictionary (CKStyle)

- (void)initAfterLoading;
- (void)setFormat:(CKStyleFormat*)format forClass:(Class)type;
- (void)setStyle:(NSDictionary*)style forKey:(NSString*)key;

@end
