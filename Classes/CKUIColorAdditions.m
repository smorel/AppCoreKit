//
//  CKUIColorAdditions.m
//  CloudKit
//
//  Created by Fred Brunel on 10-02-12.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKUIColorAdditions.h"

@implementation UIColor (CKUIColorAdditions)

+ (UIColor *)colorWithRGBValue:(NSUInteger)value {
	return [UIColor colorWithRed:((value & 0xFF0000) >> 16) / 255.0
						   green:((value & 0xFF00) >> 8) / 255.0
							blue:(value & 0xFF) / 255.0
						   alpha:1.0];
}

@end
