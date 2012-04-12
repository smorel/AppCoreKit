//
//  CKNSMutableDictionary+CKPropertyExtendedAttributes.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-23.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSMutableDictionary (CKPropertyExtendedAttributes)

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
