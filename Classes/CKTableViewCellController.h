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
	NSString *_key;
	id _value;
	id _target;
	SEL _action;
	BOOL _selectable;
	BOOL _editable;
	BOOL _removable;
	BOOL _movable;
	UITableViewCellAccessoryType _accessoryType;
	NSIndexPath *_indexPath;
	CKTableViewController *_parentController;
	CGFloat _rowHeight;
	
	//Set when reusing controllers via CKObjectTableViewController
	UITableViewCell* _tableViewCell;
}

@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) id value;
@property (nonatomic, retain, readonly) NSString *identifier;
@property (nonatomic, retain, readonly) NSIndexPath *indexPath;
@property (nonatomic, assign, readonly) CKTableViewController *parentController;
@property (nonatomic, assign, readonly) UITableViewCell *tableViewCell;

@property (nonatomic, retain) id target;
@property (nonatomic, assign) SEL action;
@property (nonatomic, getter=isSelectable) BOOL selectable;
@property (nonatomic, getter=isEditable) BOOL editable;
@property (nonatomic, getter=isRemovable) BOOL removable;
@property (nonatomic, getter=isMovable) BOOL movable;
@property (assign, readwrite) UITableViewCellAccessoryType accessoryType;
@property (nonatomic, assign) CGFloat rowHeight;

- (UITableViewCell *)cellWithStyle:(UITableViewStyle)style;
- (UITableViewCell *)cellWithNibNamed:(NSString *)nibName;

//

- (void)cellDidAppear:(UITableViewCell *)cell;
- (void)cellDidDisappear;

- (UITableViewCell *)loadCell;
- (void)setupCell:(UITableViewCell *)cell;
- (void)rotateCell:(UITableViewCell*)cell withParams:(NSDictionary*)params animated:(BOOL)animated;

- (CGFloat)heightForRow;
- (NSIndexPath *)willSelectRow;
- (void)didSelectRow;

// Calls -setupCell with the cell associated with this controller.
// Does not call -setupCell if the cell is not visible.
- (void)setNeedsSetup;

@end
