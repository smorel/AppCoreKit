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

@interface NSMutableDictionary (CKStyle)

- (NSMutableDictionary*)styleForObject:(id)object propertyName:(NSString*)propertyName;

- (void)initAfterLoading;
- (void)postInitAfterLoading;
- (void)setFormat:(CKStyleFormat*)format;
- (void)setStyle:(NSMutableDictionary*)style forKey:(NSString*)key;
- (NSMutableDictionary*)parentStyle;
- (BOOL)isEmpty;

@end
