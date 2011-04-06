//
//  CKGridView+NSIndexPath.m
//  CloudKit
//
//  Created by Olivier Collet on 11-01-19.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKGridView.h"


@implementation NSIndexPath (CKGridView)

- (NSUInteger)column {
	return self.section;
}

+ (NSIndexPath *)indexPathForRow:(NSUInteger)row column:(NSUInteger)column {
	return [NSIndexPath indexPathForRow:row inSection:column];
}

@end
