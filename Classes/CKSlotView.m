//
//  CKSlotView.m
//  CloudKit
//
//  Created by Fred Brunel on 16/04/09.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import "CKSlotView.h"
#import <QuartzCore/QuartzCore.h>
#import "CKConstants.h"
#import <math.h>

//

@implementation CKSlotViewCell
- (void)prepareForReuse { /* Do nothing */ }
@end

// SlotTableView Private methods

@interface CKSlotView (Private)
- (NSInteger)findNearestSlot;
- (void)doSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)isValidDelegateForSelector:(SEL)selector;
- (NSInteger)delegateNumberOfSlotsInSlotTableView;
- (CKSlotViewCell *)delegateCellForSlot:(NSInteger)slot reusedCell:(CKSlotViewCell *)reusedCell;
- (void)delegateDidSelectSlot:(NSInteger)slot;
- (void)delegateWillSelectSlot:(NSInteger)slot;
@end

// Helpers

CGRect CGRectCenter(CGRect rect, CGRect target) {
	return CGRectMake((target.size.width / 2) - (rect.size.width / 2), 
					  (target.size.height / 2) - (rect.size.height / 2), 
					  rect.size.width, rect.size.height);
}

//

@implementation CKSlotView

@synthesize tableView			= _tableView;
@synthesize delegate			= _delegate;
@synthesize highlightSelection	= _highlightSelection;
@synthesize snapEnabled			= _snapEnabled;
@synthesize autoCenterEnabled	= _autoCenterEnabled;

//

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {

		// Setup the table
		
		_tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
		_tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;		
		_tableView.showsVerticalScrollIndicator = NO;
		_tableView.delegate = self;
		_tableView.dataSource = self;
		_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		
		[self addSubview:_tableView];
		
		// Default values

		self.highlightSelection = NO;
		self.snapEnabled = YES;
		self.autoCenterEnabled = YES;
		
		_selectedRow = 0;
		self.slotWidth = 60;
    }
    return self;
}

- (void)dealloc {
	self.tableView = nil;
    [super dealloc];
}

#pragma mark Public Properties

- (void)setSlotWidth:(CGFloat)width {
	_slotWidth = width;
	
	// FIXME: This code should be moved elsewhere, otherwise, the computation is only done when setting
	// the width and flags set after this call will be ignored.
	
	// FIXME: Also, does not work when the view is autoresizing.
	
	if (self.autoCenterEnabled == YES) _bufferCellWidth = (self.frame.size.width / 2) - (_slotWidth / 2);
	else _bufferCellWidth = 0;
}

- (CGFloat)slotWidth {
	return _slotWidth;
}

- (void)setBackgroundColor:(UIColor *)color {
	_tableView.backgroundColor = color;
}

- (UIColor *)backgroundColor {
	return _tableView.backgroundColor;
}

- (void)setAllowsSelection:(BOOL)selection {
	_tableView.allowsSelection = selection;
}

- (BOOL)allowsSelection {
	return _tableView.allowsSelection;
}

- (void)setContentInset:(UIEdgeInsets)insets {
	_tableView.contentInset = UIEdgeInsetsMake(insets.left, insets.bottom, insets.right, insets.top);
}

- (UIEdgeInsets)contentInset {
	return UIEdgeInsetsMake(_tableView.contentInset.right, _tableView.contentInset.top, _tableView.contentInset.left, _tableView.contentInset.bottom);
}

#pragma mark Public API

- (void)selectSlotAtIndex:(NSUInteger)slotIndex animated:(BOOL)animated triggerEvent:(BOOL)event {
	if (_numberOfSlots == 0) {
		[_tableView reloadData];
	}
	
	_selectedRow = slotIndex + 1;
	
	[_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:_selectedRow inSection:0]
							animated:animated
					  scrollPosition:UITableViewScrollPositionMiddle];
	
	if (event) {
		[self doSelectRowAtIndexPath:[NSIndexPath indexPathForRow:_selectedRow inSection:0]];
	}
}

- (void)insertSlotAtIndex:(NSUInteger)slotIndex animated:(BOOL)animated triggerEvent:(BOOL)event {
	[_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:animated];	
	[_tableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:(slotIndex + 1) inSection:0], nil]
					  withRowAnimation:UITableViewRowAnimationLeft];
	[self selectSlotAtIndex:slotIndex animated:animated triggerEvent:event];
}

- (void)reloadData {
	[_tableView reloadData];
}

#pragma mark Layout

- (void)layoutSubviews {
	[super layoutSubviews];
	self.tableView.transform = CGAffineTransformMakeRotation(-M_PI/2);
	self.tableView.frame = self.bounds;
}

#pragma mark UIScrollViewDelegate Protocol

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	if ([self isValidDelegateForSelector:@selector(scrollViewDidEndDecelerating:)]) {
		[_delegate scrollViewDidEndDecelerating:scrollView];
	}

	if (self.snapEnabled == NO) return;
	
	NSInteger slot = [self findNearestSlot];
	[self delegateWillSelectSlot:slot];
	[self selectSlotAtIndex:slot animated:YES triggerEvent:YES]; 
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if ([self isValidDelegateForSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
		[_delegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
	}

	if (self.snapEnabled == NO) return;
	
	if (decelerate == YES) { return; }
	NSInteger slot = [self findNearestSlot];
	[self delegateWillSelectSlot:slot];
	[self selectSlotAtIndex:slot animated:YES triggerEvent:YES]; 
}

- (NSInteger)findNearestSlot {
	CGFloat stepWidth = _slotWidth;
	CGFloat offset = _tableView.contentOffset.y;
	CGFloat slot = roundf(offset / stepWidth);
	return slot;
}

#pragma mark UITableViewDelegate Protocol

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	_numberOfSlots = [self delegateNumberOfSlotsInSlotTableView]; 
	return _numberOfSlots + 2; // +2 buffer cells
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ((indexPath.row == 0) || (indexPath.row == (_numberOfSlots + 1))) { 
		return _bufferCellWidth; 
	} else {
		return _slotWidth;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *bufferCellIdentifier = @"SlotTableViewBufferCellIdentifier";
	static NSString *cellIdentifier = @"SlotTableViewCell";
	
	// Buffer cell
	
	if ((indexPath.row == 0) || (indexPath.row == (_numberOfSlots + 1))) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:bufferCellIdentifier];
		if (!cell) { 
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, _bufferCellWidth, self.frame.size.height)
										   reuseIdentifier:bufferCellIdentifier] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		return cell;
	}
	
	// Standard cell
	
	UITableViewCell *tableCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	CKSlotViewCell *slotCell;
	
	if (!tableCell) { 
		tableCell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellIdentifier] autorelease];
		slotCell = [self delegateCellForSlot:(indexPath.row - 1) reusedCell:nil];
		slotCell.transform = CGAffineTransformMakeRotation(M_PI/2);
		slotCell.frame = CGRectMake(0, 0, _slotWidth, self.frame.size.height);
		[tableCell.contentView addSubview:slotCell];
	} else {
		CKSlotViewCell *reusedCell = [tableCell.contentView.subviews objectAtIndex:0];
		[reusedCell prepareForReuse];
		slotCell = [self delegateCellForSlot:(indexPath.row - 1) reusedCell:reusedCell];
		NSAssert((slotCell == reusedCell), @"The reused slot cell must be returned");
	}
	
	tableCell.selectionStyle = self.highlightSelection ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
	
	return tableCell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// We don't want to select the same cell again. It also handle the case where buffer cells are
	// selected.
	
	// FIXME: The first test was for a special case (in Reportage) to disable the multiple-selection
	// of the "snapped" cell. This is a quick fix (test for snapEnabled), but it needs to be handled
	// more gracefully.
	
	if ((_selectedRow == indexPath.row) && (_snapEnabled == YES)) {
		return nil;
	} else if ((_selectedRow == 1) && (indexPath.row == 0)) {
		return nil;
	} else if ((_selectedRow == _numberOfSlots && (indexPath.row == _numberOfSlots + 1))) {
		return nil;
	}
	
	// Select the cell even if we select the buffer cell.
	
	[self delegateWillSelectSlot:indexPath.row - 1];	
	
	if (indexPath.row == 0) {
		return [NSIndexPath indexPathForRow:1 inSection:0];
	} else if (indexPath.row == _numberOfSlots + 1) {
		return [NSIndexPath indexPathForRow:(indexPath.row - 1) inSection:0];
	} else {
		return indexPath;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// FIXME: [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
	UITableViewScrollPosition scrollPosition = self.snapEnabled ? UITableViewScrollPositionMiddle : UITableViewScrollPositionNone;
	
	[tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:scrollPosition];
	[self doSelectRowAtIndexPath:indexPath];
}

- (void)doSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	_selectedRow = indexPath.row;
	[self delegateDidSelectSlot:indexPath.row - 1];
}

#pragma mark Delegate Management

- (BOOL)isValidDelegateForSelector:(SEL)selector {
	return ((_delegate != nil) && [_delegate respondsToSelector:selector]);
}

- (NSInteger)delegateNumberOfSlotsInSlotTableView {
	if ([self isValidDelegateForSelector:@selector(numberOfSlotsInSlotTableView:)]) {
		return [_delegate numberOfSlotsInSlotTableView:self];
	}
	return 0;
}

- (CKSlotViewCell *)delegateCellForSlot:(NSInteger)slot reusedCell:(CKSlotViewCell *)reusedCell {
	if ([self isValidDelegateForSelector:@selector(slotTableView:cellForSlot:reusedCell:)]) {
		return [_delegate slotTableView:self cellForSlot:slot reusedCell:reusedCell];
	}
	return nil; // FIXME: Should throw an exception, or an NSAssert
}

- (void)delegateDidSelectSlot:(NSInteger)slot {
	if ([self isValidDelegateForSelector:@selector(slotTableView:didSelectSlot:)]) {
		[_delegate slotTableView:self didSelectSlot:slot];
	}
}

- (void)delegateWillSelectSlot:(NSInteger)slot {
	if ([self isValidDelegateForSelector:@selector(slotTableView:willSelectSlot:)]) {
		[_delegate slotTableView:self willSelectSlot:slot];
	}
}

#pragma mark UIScrollViewDelegate Protocol Forwarding

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	if ([self isValidDelegateForSelector:@selector(scrollViewWillBeginDragging:)]) {
		[_delegate scrollViewWillBeginDragging:scrollView];
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if ([self isValidDelegateForSelector:@selector(scrollViewDidScroll:)]) {
		[_delegate scrollViewDidScroll:scrollView];
	}
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
	if ([self isValidDelegateForSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
		[_delegate scrollViewDidEndScrollingAnimation:scrollView];
	}
}

@end
