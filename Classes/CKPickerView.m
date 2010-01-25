//
//  CKPickerView.m
//  CloudKit
//
//  Created by Fred Brunel on 10-01-22.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKPickerView.h"

// Private API

@interface CKPickerView (Private)
- (NSInteger)selectNearestRow;
- (BOOL)isValidDelegateForSelector:(SEL)selector;
- (void)delegateDidSelectRow:(NSInteger)row;
@end

// Helpers

CGRect _CGRectCenter(CGRect rect, CGRect target) {
	return CGRectMake((target.size.width / 2) - (rect.size.width / 2), 
					  (target.size.height / 2) - (rect.size.height / 2), 
					  rect.size.width, rect.size.height);
}

//

@implementation CKPickerView

@synthesize backgroundView = _backgroundView;
@synthesize selectionView = _selectionView;
@synthesize overlayView = _overlayView;
@synthesize showsSelection = _showsSelection;
@synthesize delegate = _delegate;

//

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		// Setup the table
		
		_tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
		_tableView.showsVerticalScrollIndicator = NO;
		_tableView.delegate = self;
		_tableView.dataSource = self;
		
		[self addSubview:_tableView];
		
		// Default values
		
		self.rowHeight = 44.0f;
		self.showsSelection = NO;
    }
    return self;
}

- (void)dealloc {
	[_tableView release];
    [super dealloc];
}

// Public Properties

- (void)setRowHeight:(CGFloat)height {
	_rowHeight = height;
	_bufferCellHeight = (self.frame.size.height / 2) - (_rowHeight / 2);
}

- (CGFloat)rowHeight {
	return _rowHeight;
}

- (void)setBackgroundView:(UIView *)view {
	[_backgroundView removeFromSuperview];
	[_backgroundView release];
	_backgroundView = [view retain];
	_backgroundView.userInteractionEnabled = NO;
	_backgroundView.opaque = YES;
	_backgroundView.frame = _CGRectCenter(view.frame, self.bounds);
	self.backgroundColor = [UIColor clearColor];
	[self insertSubview:_backgroundView belowSubview:_tableView];
}

- (UIView *)backgroundView {
	return _backgroundView;
}

- (void)setSelectionView:(UIView *)view {
	[_selectionView removeFromSuperview];
	[_selectionView release];
	_selectionView = [view retain];
	_selectionView.userInteractionEnabled = NO;
	_selectionView.opaque = YES;
	_selectionView.frame = _CGRectCenter(view.frame, self.bounds);
	[self insertSubview:_selectionView aboveSubview:_tableView];
}

- (UIView *)selectionView {
	return _selectionView;
}

- (void)setOverlayView:(UIView *)view {
	[_overlayView removeFromSuperview];
	[_overlayView release];
	_overlayView = [view retain];
	_overlayView.userInteractionEnabled = NO;
	_overlayView.opaque = YES;
	_overlayView.frame = _CGRectCenter(view.frame, self.bounds);
	[self insertSubview:_overlayView aboveSubview:_selectionView];
}

- (UIView *)overlayView {
	return _overlayView;
}

- (void)setBackgroundColor:(UIColor *)color {
	_tableView.backgroundColor = color;
}

- (UIColor *)backgroundColor {
	return _tableView.backgroundColor;
}

- (void)setSeparatorColor:(UIColor *)color {
	if (color == [UIColor clearColor]) {
		_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	} else {
		_tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;		
		_tableView.separatorColor = color;
	}
}

- (UIColor *)separatorColor {
	return _tableView.separatorColor;
}

// Public API

- (void)selectRow:(NSUInteger)row animated:(BOOL)animated {
	
	if (_numberOfRows == 0) {
		[_tableView reloadData];
	}
	
	[_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:(row + 1) inSection:0]
							animated:animated
					  scrollPosition:UITableViewScrollPositionMiddle];
}

- (void)insertRow:(NSUInteger)row animated:(BOOL)animated {
	[_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:animated];	
	[_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:(row + 1) inSection:0]]
					  withRowAnimation:UITableViewRowAnimationFade];
	[self selectRow:row animated:animated];
}

- (void)reloadData {
	[_tableView reloadData];
}

// UIScrollView protocol

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	[self selectNearestRow];
	[self delegateDidSelectRow:[_tableView indexPathForSelectedRow].row - 1];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if (decelerate == YES) { return; }
	[self selectNearestRow];
	[self delegateDidSelectRow:[_tableView indexPathForSelectedRow].row - 1];
}

- (NSInteger)selectNearestRow {
	CGFloat stepHeight = _rowHeight;
	CGFloat offset = _tableView.contentOffset.y;
	CGFloat row = roundf(offset / stepHeight);
	
	[_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:(row + 1) inSection:0]
							animated:YES
					  scrollPosition:UITableViewScrollPositionMiddle];
	return row;
}

// 

// UITableView protocols

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	_numberOfRows = [_delegate numberOfRowsInPickerView:self]; 
	return _numberOfRows + 2; // +2 buffer rows
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ((indexPath.row == 0) || (indexPath.row == (_numberOfRows + 1))) { 
		return _bufferCellHeight; 
	} else {
		return _rowHeight;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *bufferCellIdentifier = @"CKPickerViewBufferCellIdentifier";
	static NSString *cellIdentifier = @"CKPickerViewCell";
	
	// Buffer cell
	
	if ((indexPath.row == 0) || (indexPath.row == (_numberOfRows + 1))) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:bufferCellIdentifier];
		if (!cell) { 
			cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, _bufferCellHeight)
										  reuseIdentifier:bufferCellIdentifier];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		return cell;
	}
	
	// Standard cell
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	UIView *view;
	
	if (!cell) { 
		cell = [[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellIdentifier];
		view = [_delegate pickerView:self viewForRow:(indexPath.row - 1) reusingView:nil];
		
		// FIXME: This calculus should be simpler, the tableCell should have the right size.
		// On the principle, the frame of the cell should be inversed before the rotation happens.
//		CGRect cellFrame = CGRectMake(0, 0, _slotWidth, self.frame.size.height);
//		slotCell.frame = CGRectMake((self.frame.size.height / 2) - (cellFrame.size.width / 2), 
//									(_slotWidth / 2) - (cellFrame.size.height / 2), 
//									cellFrame.size.width, cellFrame.size.height);
//		
//		slotCell.transform = CGAffineTransformMakeRotation(MathDegreesToRadians(90));
		
		view.frame = CGRectMake(0, 0, self.frame.size.width, _rowHeight);
		[cell.contentView addSubview:view];
	} else {
		UIView *reusedView = [cell.contentView.subviews objectAtIndex:0];
		// TODO: implement a protocol for the views - [reusedCell prepareForReuse];
		view = [_delegate pickerView:self viewForRow:(indexPath.row - 1) reusingView:reusedView];
		NSAssert((view == reusedView), @"The reused view must be returned");
	}
	
	cell.selectionStyle = self.showsSelection ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
	
	return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 0) {
		return [NSIndexPath indexPathForRow:1 inSection:0];
	} else if (indexPath.row == _numberOfRows + 1) {
		return [NSIndexPath indexPathForRow:(indexPath.row - 1) inSection:0];
	} else {
		return indexPath;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
	[tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
	[self delegateDidSelectRow:indexPath.row - 1];
}

// Delegates

- (BOOL) isValidDelegateForSelector:(SEL)selector {
	return ((_delegate != nil) && [_delegate respondsToSelector:selector]);
}

- (void)delegateDidSelectRow:(NSInteger)row {
	if ([self isValidDelegateForSelector:@selector(pickerView:didSelectRow:)]) {
		[_delegate pickerView:self didSelectRow:row];
	}
}

@end