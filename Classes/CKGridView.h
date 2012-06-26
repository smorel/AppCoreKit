//
//  CKGridView.h
//  CloudKit
//
//  Created by Olivier Collet on 11-01-19.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol CKGridViewDataSource;
@protocol CKGridViewDelegate;

// CKGridView

/**
 */
@interface CKGridView : UIView 

@property (nonatomic, assign) IBOutlet id<CKGridViewDataSource> dataSource;
@property (nonatomic, assign) IBOutlet id<CKGridViewDelegate> delegate;
@property (nonatomic, readonly) NSUInteger viewCount;
@property (nonatomic, assign, getter=isEditing) BOOL editing;
@property (nonatomic, assign) CFTimeInterval minimumPressDuration;
@property (nonatomic, assign) CGFloat draggedViewScale;
@property (nonatomic, assign, readonly) NSUInteger rows;
@property (nonatomic, assign, readonly) NSUInteger columns;

- (id)initWithFrame:(CGRect)frame gridSize:(CGSize)size;

- (void)reloadData;

- (void)insertViewAtIndexPath:(NSIndexPath*)indexPath animated:(BOOL)animated;

- (UIView *)viewAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForPoint:(CGPoint)point;
- (NSIndexPath *)indexPathForIndex:(NSInteger)index;

@end

// CKGridViewDataSource Protocol

/**
 */
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


/**
 */
@protocol CKGridViewDelegate

@optional

- (BOOL)gridView:(CKGridView *)gridView canMoveViewAtIndexPath:(NSIndexPath *)indexPath toPoint:(CGPoint)point;
- (void)gridView:(CKGridView *)gridView didMoveViewAtIndexPath:(NSIndexPath *)indexPath toPoint:(CGPoint)point;
- (BOOL)gridView:(CKGridView *)gridView shouldMoveDraggedViewToOriginFromPoint:(CGPoint)point;

@end

// NSIndexPath Addition


/**
 */
@interface NSIndexPath (CKGridView)

+ (NSIndexPath *)indexPathForRow:(NSUInteger)row column:(NSUInteger)column;

@property (nonatomic, readonly) NSUInteger column;

@end
