//
//  CKSlotView.h
//  CloudKit
//
//  Created by Fred Brunel on 16/04/09.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

//

@interface CKSlotViewCell : UIView

- (void)prepareForReuse;

@end

//

@class CKSlotView;

@protocol CKSlotViewDelegate

@required

- (NSInteger)numberOfSlotsInSlotTableView:(CKSlotView *)slotTableView;
- (CKSlotViewCell *)slotTableView:(CKSlotView *)slotTableView cellForSlot:(NSInteger)slot reusedCell:(CKSlotViewCell *)reusedCell;

@optional

- (void)slotTableView:(CKSlotView *)slotTableView willSelectSlot:(NSInteger)slot;
- (void)slotTableView:(CKSlotView *)slotTableView didSelectSlot:(NSInteger)slot;

@optional

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView;

@end

//

@interface CKSlotView : UIView <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate> {
	CGRect _originFrame;
	UITableView	*_tableView;
	UIView *_backgroundView;
	
	NSUInteger _identifier;
	NSUInteger _selectedRow;
	NSInteger _numberOfSlots;
	CGFloat _slotWidth;
	NSInteger _bufferCellWidth;	

	BOOL _highlightSelection;
	BOOL _snapEnabled;
	BOOL _autoCenterEnabled;
	
	NSObject <CKSlotViewDelegate> *_delegate;
}

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UIView *backgroundView;
@property (nonatomic, retain) UIColor *backgroundColor;
@property (nonatomic, assign) NSUInteger identifier;
@property (nonatomic, assign) CGFloat slotWidth;
@property (nonatomic, assign) BOOL highlightSelection;
@property (nonatomic, assign) BOOL snapEnabled;
@property (nonatomic, assign) BOOL autoCenterEnabled;
@property (nonatomic, assign) BOOL allowsSelection;
@property (nonatomic, assign) UIEdgeInsets contentInset;
@property (nonatomic, assign) NSObject<CKSlotViewDelegate> *delegate;

- (void)selectSlotAtIndex:(NSUInteger)slotIndex animated:(BOOL)animated triggerEvent:(BOOL)event;
- (void)insertSlotAtIndex:(NSUInteger)slotIndex animated:(BOOL)animated triggerEvent:(BOOL)event;
- (void)reloadData;

@end