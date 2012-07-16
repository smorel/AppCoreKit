//
//  CKNSMutableDictionary+CKObjectPropertyMetaData.h
//  CloudKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSMutableDictionary (CKObjectPropertyMetaData)

//NSNumber
- (void)setMinimumValue:(NSNumber*)value;
- (void)setMaximumValue:(NSNumber*)value;
- (NSNumber*)minimumValue;
- (NSNumber*)maximumValue;

//textField/textView
- (void)setMinimumLength:(NSInteger)length;
- (void)setMaximumLength:(NSInteger)length;
- (NSInteger)minimumLength;
- (NSInteger)maximumLength;

@end
