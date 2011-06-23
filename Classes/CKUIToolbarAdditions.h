//
//  CKUIToolbarAdditions.h
//  CloudKit
//
//  Created by Fred Brunel on 10-05-17.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIToolbar (CKUIToolbarAdditions)

- (void)replaceItemWithTag:(NSInteger)tag withItem:(UIBarButtonItem *)item;

@end
