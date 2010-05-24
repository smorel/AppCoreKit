//
//  CKBasicCellController.h
//  CloudKit
//
//  Created by Olivier Collet on 09-12-15.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKManagedTableViewController.h"

@interface CKTableViewCellController : NSObject {
	id _target;
	SEL _action;
	BOOL _selectable;
	UITableViewCellAccessoryType _accessoryType;
	NSIndexPath *_indexPath;
	CKManagedTableViewController *_parentController;
}

@property (nonatomic, retain, readonly) NSString *identifier;
@property (nonatomic, retain, readonly) NSIndexPath *indexPath;
@property (nonatomic, assign, readonly) CKManagedTableViewController *parentController;
@property (nonatomic, assign, readonly) UITableViewCell *tableViewCell;

@property (nonatomic, retain) id target;
@property (nonatomic, assign) SEL action;
@property (nonatomic, getter=isSelectable) BOOL selectable;
@property (assign, readwrite) UITableViewCellAccessoryType accessoryType;

- (UITableViewCell *)cellWithStyle:(UITableViewStyle)style;

//

- (void)cellDidAppear:(UITableViewCell *)cell;
- (void)cellDidDisappear;

- (UITableViewCell *)loadCell;
- (void)setupCell:(UITableViewCell *)cell;

- (CGFloat)heightForRow;
- (NSIndexPath *)willSelectRow;
- (void)didSelectRow;

// Calls -setupCell with the cell associated with this controller.
// Does not call -setupCell if the cell is not visible.
- (void)setNeedsSetup;

@end
