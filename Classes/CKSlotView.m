//
//  CKSlotView.m
//  CloudKit
//
//  Created by Fred Brunel on 16/04/09.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import "CKSlotView.h"
#import "QuartzCore/QuartzCore.h"
#import <CloudKit/CKConstants.h>

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

CGFloat MathDegreesToRadians(CGFloat degrees) {
	return degrees / 57.2958;
}

CGRect CGRectCenter(CGRect rect, CGRect target) {
	return CGRectMake((target.size.width / 2) - (rect.size.width / 2), 
					  (target.size.height / 2) - (rect.size.height / 2), 
					  rect.size.width, rect.size.height);
}

//

@implementation CKSlotView

@synthesize tableView			= _tableView;
@synthesize delegate			= _delegate;
@synthesize identifier			= _identifier;
@synthesize highlightSelection	= _highlightSelection;
@synthesize snapEnabled			= _snapEnabled;
@synthesize autoCenterEnabled	= _autoCenterEnabled;

//

- (id)initWithFrame:(CGRect)frame {
	_originFrame = frame;
	CGRect rotFrame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.height, frame.size.width);
    if (self = [super initWithFrame:rotFrame]) {

		NSLog(@"orig f: %@", NSStringFromCGRect(_originFrame));
		NSLog(@"orig r: %@", NSStringFromCGRect(rotFrame));
		NSLog(@"orig a: %@", NSStringFromCGPoint(self.layer.anchorPoint));
		NSLog(@"orig c: %@", NSStringFromCGPoint(self.layer.position));
		
		// Rotate the view so that the table will be horizontal
		
		self.layer.anchorPoint = CGPointMake(0.0, 0.0);		
		self.layer.position = CGPointMake(_originFrame.origin.x, _originFrame.origin.y + _originFrame.size.height);
		self.transform = CGAffineTransformMakeRotation(MathDegreesToRadians(-90));
		//self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		
		// Setup the table
		
		_tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
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
	[_tableView release];
    [super dealloc];
}

#pragma mark Public Properties

- (void)setSlotWidth:(CGFloat)width {
	_slotWidth = width;
	
	// FIXME: This code should be moved elsewhere, otherwise, the computation is only done when setting
	// the width and flags set after this call will be ignored.
	
	if (self.autoCenterEnabled == YES) _bufferCellWidth = (self.frame.size.width / 2) - (_slotWidth / 2);
	else _bufferCellWidth = 0;
}

- (CGFloat)slotWidth {
	return _slotWidth;
}

- (void)setBackgroundView:(UIView *)view {
	[_backgroundView removeFromSuperview];
	[_backgroundView release];
	_backgroundView = [view retain];
	_backgroundView.userInteractionEnabled = NO;
	_backgroundView.opaque = YES;
	
	_backgroundView.frame = CGRectCenter(view.frame, self.bounds);
	_backgroundView.transform = CGAffineTransformMakeRotation(MathDegreesToRadians(90));
	
	self.backgroundColor = [UIColor clearColor];
	[self insertSubview:_backgroundView belowSubview:_tableView];
}

- (UIView *)backgroundView {
	return _backgroundView;
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

	// Rotate the view so that the table will be horizontal
		
	self.layer.anchorPoint = CGPointMake(0.0, 0.0);		
	self.layer.position = CGPointMake(_originFrame.origin.x, _originFrame.origin.y + _originFrame.size.height);
	self.transform = CGAffineTransformMakeRotation(MathDegreesToRadians(-90));	
	
	NSLog(@"f: %@", NSStringFromCGRect(self.frame));
	NSLog(@"b: %@", NSStringFromCGRect(self.bounds));	
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
		
		// FIXME: This calculus should be simpler, the tableCell should have the right size.
		// On the principle, the frame of the cell should be inversed before the rotation happens.
		CGRect cellFrame = CGRectMake(0, 0, _slotWidth, self.frame.size.height);
		slotCell.frame = CGRectMake((self.frame.size.height / 2) - (cellFrame.size.width / 2), 
									(_slotWidth / 2) - (cellFrame.size.height / 2), 
									cellFrame.size.width, cellFrame.size.height);
		
		slotCell.transform = CGAffineTransformMakeRotation(MathDegreesToRadians(90));
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
	
	if (_selectedRow == indexPath.row) {
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
