//
//  CKOptionTableViewController.h
//  CloudKit
//
//  Created by Olivier Collet on 10-06-11.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "CKFormTableViewController.h"


@class CKOptionTableViewController;


/** TODO
 */
@protocol CKOptionTableViewControllerDelegate
- (void)optionTableViewController:(CKOptionTableViewController *)tableViewController didSelectValueAtIndex:(NSInteger)index;
@end


/** TODO
 */
@interface CKOptionTableViewController : CKFormTableViewController {
	id _optionTableDelegate;
	NSArray *_values;
	NSArray *_labels;
	NSMutableArray* _selectedIndexes;
	BOOL _multiSelectionEnabled;
}

@property (nonatomic, assign) id optionTableDelegate;
@property (nonatomic, readonly) NSInteger selectedIndex;
@property (nonatomic, retain,readonly) NSMutableArray* selectedIndexes;
@property (nonatomic, assign) BOOL multiSelectionEnabled;

- (id)initWithValues:(NSArray *)values labels:(NSArray *)labels selected:(NSInteger)index;
- (id)initWithValues:(NSArray *)values labels:(NSArray *)labels selected:(NSArray*)selected multiSelectionEnabled:(BOOL)multiSelectionEnabled;

@end
