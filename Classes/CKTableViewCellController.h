//
//  CKBasicCellController.h
//  CloudKit
//
//  Created by Olivier Collet on 09-12-15.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import "CKItemViewController.h"
#import "CKManagedTableViewController.h"
#import "CKModelObject.h"
#import "CKNSDictionary+TableViewAttributes.h"
#import "CKCallback.h"

enum{
	CKTableViewCellFlagNone = CKItemViewFlagNone,
	CKTableViewCellFlagSelectable = CKItemViewFlagSelectable,
	CKTableViewCellFlagEditable = CKItemViewFlagEditable,
	CKTableViewCellFlagRemovable = CKItemViewFlagRemovable,
	CKTableViewCellFlagMovable = CKItemViewFlagMovable,
	CKTableViewCellFlagAll = CKItemViewFlagAll
};
typedef NSUInteger CKTableViewCellFlags;

@interface CKTableViewCellController : CKItemViewController {
	UITableViewCellAccessoryType _accessoryType;
	UITableViewCellStyle _cellStyle;
	
	NSString* _key;
}

@property (nonatomic, readonly) UITableViewCell *tableViewCell;
@property (nonatomic, assign) UITableViewCellStyle cellStyle;
@property (assign, readwrite) UITableViewCellAccessoryType accessoryType;
@property (nonatomic, retain) NSString* key;

- (UITableViewCell *)cellWithStyle:(UITableViewCellStyle)style;

- (void)cellDidAppear:(UITableViewCell *)cell;
- (void)cellDidDisappear;

- (UITableViewCell *)loadCell;
- (void)setupCell:(UITableViewCell *)cell;
- (void)rotateCell:(UITableViewCell*)cell withParams:(NSDictionary*)params animated:(BOOL)animated;

- (NSIndexPath *)willSelectRow;
- (void)didSelectRow;

// Calls -setupCell with the cell associated with this controller.
// Does not call -setupCell if the cell is not visible.
- (void)setNeedsSetup;

//private
- (void)initTableViewCell:(UITableViewCell*)cell;

+ (BOOL)hasAccessoryResponderWithValue:(id)object;
- (void)layoutCell:(UITableViewCell *)cell;

- (CKTableViewController*)parentTableViewController;
- (UITableView*)parentTableView;

@end
