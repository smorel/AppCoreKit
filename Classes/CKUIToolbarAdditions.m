//
//  CKUIToolbarAdditions.m
//  CloudKit
//
//  Created by Fred Brunel.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKUIToolbarAdditions.h"

@implementation UIToolbar (CKUIToolbarAdditions)

- (void)replaceItemWithTag:(NSInteger)tag withItem:(UIBarButtonItem *)item {
	NSInteger i = 0;
	for (UIBarButtonItem *button in self.items) {
		if (button.tag == tag) {
			NSMutableArray *theItems = [NSMutableArray arrayWithArray:self.items];
			[theItems replaceObjectAtIndex:i withObject:item];
			self.items = theItems;
			break;
		}
		i++;
	}
}
	
@end
