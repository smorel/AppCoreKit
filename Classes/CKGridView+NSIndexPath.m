//
//  CKGridView+NSIndexPath.m
//  CloudKit
//
//  Created by Olivier Collet.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKGridView.h"


@implementation NSIndexPath (CKGridView)

- (NSUInteger)column {
	return self.section;
}

+ (NSIndexPath *)indexPathForRow:(NSUInteger)row column:(NSUInteger)column {
	return [NSIndexPath indexPathForRow:row inSection:column];
}

@end
