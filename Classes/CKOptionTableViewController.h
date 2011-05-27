//
//  CKOptionTableViewController.h
//  CloudKit
//
//  Created by Olivier Collet on 10-06-11.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CKFormTableViewController.h"

@class CKOptionTableViewController;

@protocol CKOptionTableViewControllerDelegate
- (void)optionTableViewController:(CKOptionTableViewController *)tableViewController didSelectValueAtIndex:(NSInteger)index;
@end


@interface CKOptionTableViewController : CKFormTableViewController {
	id _optionTableDelegate;
	NSArray *_values;
	NSArray *_labels;
	NSInteger _selectedIndex;
}

@property (nonatomic, assign) id optionTableDelegate;
@property (nonatomic, readonly) NSInteger selectedIndex;

- (id)initWithValues:(NSArray *)values labels:(NSArray *)labels selected:(NSInteger)index;

@end
