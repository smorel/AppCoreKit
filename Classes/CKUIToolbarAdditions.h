//
//  CKUIToolbarAdditions.h
//  CloudKit
//
//  Created by Fred Brunel.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


/** TODO
 */
@interface UIToolbar (CKUIToolbarAdditions)

- (void)replaceItemWithTag:(NSInteger)tag withItem:(UIBarButtonItem *)item;

@end
