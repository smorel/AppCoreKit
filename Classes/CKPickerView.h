//
//  CKPickerView.h
//  CloudKit
//
//  Created by Fred Brunel on 10-01-22.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKPickerView;

//

@protocol CKPickerViewDelegate

@required
- (NSInteger)numberOfRowsInPickerView:(CKPickerView *)pickerView;

@optional
- (UIView *)pickerView:(CKPickerView *)pickerView viewForRow:(NSInteger)row reusingView:(UIView *)view;
- (NSString *)pickerView:(CKPickerView *)pickerView titleForRow:(NSInteger)row;

@optional
- (void)pickerView:(CKPickerView *)pickerView didSelectRow:(NSInteger)row;

@end

//

@interface CKPickerView : UIView <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate> {
	UITableView *_tableView;
	UIView *_backgroundView;
	UIView *_selectionView;
	UIView *_overlayView;
	
	NSInteger _numberOfRows;
	CGFloat _rowHeight;
	UITableViewCellSelectionStyle _selectionStyle;
	NSInteger _bufferCellHeight;
	BOOL _showsSelection;
	NSObject<CKPickerViewDelegate> *_delegate;
}

@property (nonatomic, retain) UIView *backgroundView;
@property (nonatomic, retain) UIView *selectionView;
@property (nonatomic, retain) UIView *overlayView;
@property (nonatomic, retain) UIColor *backgroundColor;
@property (nonatomic, retain) UIColor *separatorColor;
@property (nonatomic, assign) CGFloat rowHeight;
@property (nonatomic, assign) UITableViewCellSelectionStyle selectionStyle;
@property (nonatomic, assign) IBOutlet NSObject<CKPickerViewDelegate> *delegate;

- (void)selectRow:(NSUInteger)row animated:(BOOL)animated;
- (void)insertRow:(NSUInteger)row animated:(BOOL)animated;
- (void)reloadData;

@end
