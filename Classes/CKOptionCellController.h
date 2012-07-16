//
//  CKOptionCellController.h
//  CloudKit
//
//  Created by Olivier Collet.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKStandardCellController.h"
#import "CKOptionTableViewController.h"


/** TODO
 */
@interface CKOptionCellController : CKStandardCellController <CKOptionTableViewControllerDelegate> {
	NSArray *_values;
	NSArray *_labels;
	BOOL _multiSelectionEnabled;
    id _currentValue;
}

@property (nonatomic, retain) NSArray *values;
@property (nonatomic, retain) NSArray *labels;
@property (nonatomic, assign) BOOL multiSelectionEnabled;
@property (nonatomic, retain, readonly) id currentValue;
@property (nonatomic,assign) BOOL readOnly;
@property (nonatomic,assign) CKTableViewCellStyle optionCellStyle;

// If labels is nil, the table values are displayed, otherwise ensure values and labels have the same count.
- (id)initWithTitle:(NSString *)title values:(NSArray *)values labels:(NSArray *)labels;
- (id)initWithTitle:(NSString *)title values:(NSArray *)values labels:(NSArray *)labels multiSelectionEnabled:(BOOL)multiSelectionEnabled;

@end
