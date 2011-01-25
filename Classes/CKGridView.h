//
//  CKGridView.h
//  CloudKit
//
//  Created by Olivier Collet on 11-01-19.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CKGridViewDataSource;
@protocol CKGridViewDelegate;

// CKGridView

@interface CKGridView : UIView {
	id<CKGridViewDataSource> _dataSource;
	id<CKGridViewDelegate> _delegate;

	NSUInteger _rows;
	NSUInteger _columns;
	NSMutableArray *_views;

	UIView *_draggedView;
	NSIndexPath *_fromIndexPath;
	NSIndexPath *_toIndexPath;

	BOOL _editing;
	BOOL _animating;
	CFTimeInterval _minimumPressDuration;

	// Gesture Compatibilty with iOS 3.x
	BOOL _longPressRecognized;
}

@property (nonatomic, retain) IBOutlet id<CKGridViewDataSource> dataSource;
@property (nonatomic, assign) IBOutlet id<CKGridViewDelegate> delegate;
@property (nonatomic, assign, getter=isEditing) BOOL editing;
@property (nonatomic, assign) CFTimeInterval minimumPressDuration;

- (void)reloadData;

- (NSIndexPath *)indexPathForPoint:(CGPoint)point;

@end

// CKGridViewDataSource Protocol

@protocol CKGridViewDataSource

@required

- (NSUInteger)numberOfRowsForGridView:(CKGridView *)gridView;
- (NSUInteger)numberOfColumnsForGridView:(CKGridView *)gridView;

- (UIView *)gridView:(CKGridView *)gridView viewAtIndexPath:(NSIndexPath *)indexPath;

@optional

- (BOOL)gridView:(CKGridView *)gridView canEditViewAtIndexPath:(NSIndexPath *)indexPath;

- (BOOL)gridView:(CKGridView *)gridView canMoveViewFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;
- (void)gridView:(CKGridView *)gridView didMoveViewFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;

@end

// CKGridViewDelegate Protocol

@protocol CKGridViewDelegate

@optional

- (BOOL)gridView:(CKGridView *)gridView canMoveViewAtIndexPath:(NSIndexPath *)indexPath toPoint:(CGPoint)point;
- (void)gridView:(CKGridView *)gridView didMoveViewAtIndexPath:(NSIndexPath *)indexPath toPoint:(CGPoint)point;
- (BOOL)gridView:(CKGridView *)gridView shouldMoveDraggedViewToOriginFromPoint:(CGPoint)point;

@end

// NSIndexPath Addition

@interface NSIndexPath (CKGridView)

+ (NSIndexPath *)indexPathForRow:(NSUInteger)row column:(NSUInteger)column;

@property (nonatomic, readonly) NSUInteger column;

@end
