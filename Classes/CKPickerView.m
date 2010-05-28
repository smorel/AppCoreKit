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
- (void)setupView;
- (NSInteger)selectNearestRow;
- (BOOL)isValidDelegateForSelector:(SEL)selector;
- (void)delegateDidSelectRow:(NSInteger)row;
- (void)delegateWillBeginDragging;
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
@synthesize selectionStyle = _selectionStyle;
@synthesize delegate = _delegate;

//

- (void)awakeFromNib {
	[self setupView];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) { [self setupView]; }
    return self;
}

- (void)setupView {
	// Setup the table
	
	_tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	_tableView.showsVerticalScrollIndicator = NO;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	
	[self addSubview:_tableView];
	
	// Default values
	
	self.rowHeight = 44.0f;
	self.selectionStyle = UITableViewCellSelectionStyleBlue;
}

- (void)dealloc {
	[_tableView release];
    [super dealloc];
}

// Layout subviews

- (void)layoutSubviews {
	_bufferCellHeight = (self.frame.size.height / 2) - (_rowHeight / 2);
}

// Public Properties

- (void)setRowHeight:(CGFloat)height {
	_rowHeight = height;
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

- (void)reloadRowAtIndex:(NSUInteger)row {
	
	// FIXME: This code is duplicated from line 257
	
	UITableViewCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(row + 1) inSection:0]];
	if ((cell != nil) && ([_delegate respondsToSelector:@selector(pickerView:viewForRow:reusingView:)])) {
		UIView *reusedView = [cell.contentView.subviews objectAtIndex:0];
		UIView *view = [_delegate pickerView:self viewForRow:row reusingView:reusedView];
		NSAssert((view == reusedView), @"The reused view must be returned");
	}
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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	[self delegateWillBeginDragging];
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
	static NSString *bufferCellIdentifier = @"CKPickerViewBufferCell";
	static NSString *cellIdentifier = @"CKPickerViewCell";
	
	// Buffer cell
	
	if ((indexPath.row == 0) || (indexPath.row == (_numberOfRows + 1))) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:bufferCellIdentifier];
		if (!cell) { 
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, _bufferCellHeight)
										   reuseIdentifier:bufferCellIdentifier] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		return cell;
	}
	
	// Standard cell
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	NSUInteger row = (indexPath.row - 1);
	
	if (cell == nil) { 
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellIdentifier] autorelease];

		if ([_delegate respondsToSelector:@selector(pickerView:viewForRow:reusingView:)]) {
			UIView *view = [_delegate pickerView:self viewForRow:row reusingView:nil];
			view.frame = CGRectMake(0, 0, self.frame.size.width, _rowHeight);
			[cell.contentView addSubview:view];
		}
	} else if ([_delegate respondsToSelector:@selector(pickerView:viewForRow:reusingView:)]) {
		UIView *reusedView = [cell.contentView.subviews objectAtIndex:0];
		// TODO: implement a protocol for the views - [reusedCell prepareForReuse];
		UIView *view = [_delegate pickerView:self viewForRow:row reusingView:reusedView];
		NSAssert((view == reusedView), @"The reused view must be returned");
	}
	
	if ([_delegate respondsToSelector:@selector(pickerView:titleForRow:)]) {
		cell.textLabel.text = [_delegate pickerView:self titleForRow:row];
	}
	
	cell.selectionStyle = self.selectionStyle;
	
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

- (BOOL)isValidDelegateForSelector:(SEL)selector {
	return ((_delegate != nil) && [_delegate respondsToSelector:selector]);
}

- (void)delegateDidSelectRow:(NSInteger)row {
	if ([self isValidDelegateForSelector:@selector(pickerView:didSelectRow:)]) {
		[_delegate pickerView:self didSelectRow:row];
	}
}

- (void)delegateWillBeginDragging {
	if ([self isValidDelegateForSelector:@selector(pickerViewWillBeginDragging:)]) {
		[_delegate pickerViewWillBeginDragging:self];
	}
}

@end