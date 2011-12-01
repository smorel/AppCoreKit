//
//  CKCarouselView.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-07.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class CKCarouselView;

/** TODO
 */
@protocol CKCarouselViewDataSource
- (NSInteger)numberOfSectionsInCarouselView:(CKCarouselView*)carouselView;
- (NSInteger)carouselView:(CKCarouselView*)carouselView numberOfRowsInSection:(NSInteger)section;
- (UIView*)carouselView:(CKCarouselView*)carouselView viewForRowAtIndexPath:(NSIndexPath*)indexPath;
@end


/** TODO
 */
@protocol CKCarouselViewDelegate
- (UIView*) carouselView:(CKCarouselView*)carouselView viewForHeaderInSection:(NSInteger)section;
- (CGSize) carouselView:(CKCarouselView*)carouselView sizeForViewAtIndexPath:(NSIndexPath*)indexPath;
- (void) carouselView:(CKCarouselView*)carouselView viewDidDisappearAtIndexPath:(NSIndexPath*)indexPath;
- (void) carouselView:(CKCarouselView*)carouselView viewDidAppearAtIndexPath:(NSIndexPath*)indexPath;
- (void) carouselViewDidScroll:(CKCarouselView*)carouselView;
@end


/** TODO
 */
typedef enum{
	CKCarouselViewDisplayTypeHorizontal
}CKCarouselViewDisplayType;


/** TODO
 */
@interface CKCarouselView : UIScrollView<UIGestureRecognizerDelegate> {
	NSMutableArray* _rowSizes;
	CGFloat _internalContentOffset;
	NSInteger _numberOfPages;
	NSInteger _currentPage;
	NSInteger _currentSection;
	
	CGFloat _spacing;
	
	UIView* _headerViewToRemove;
	UIView* _visibleHeaderView;
	NSMutableDictionary* _visibleViewsForIndexPaths;
	
	id _dataSource;
	//id _delegate;
	
	NSMutableDictionary* _reusableViews;
	CKCarouselViewDisplayType _displayType;
	
	CGFloat _contentOffsetWhenStartPanning;
}

@property (nonatomic,assign,readonly) NSInteger numberOfPages;
@property (nonatomic,assign,readonly) NSInteger currentPage;
@property (nonatomic,assign,readonly) NSInteger currentSection;
@property (nonatomic,assign,readonly) CGFloat internalContentOffset;

@property (nonatomic,assign) CGFloat spacing;
@property (nonatomic,assign) IBOutlet id dataSource;
@property (nonatomic,assign) CKCarouselViewDisplayType displayType;

- (void)reloadData;
- (UIView*)dequeueReusableViewWithIdentifier:(id)identifier;

//Offset is normalized between 0 & numberOfPages
//contentOffset represents the center of the carousel
- (void)setContentOffset:(CGFloat)offset animated:(BOOL)animated;

- (NSIndexPath*)indexPathForPage:(NSInteger)page;
- (NSInteger)pageForIndexPath:(NSIndexPath*)indexPath;

- (NSArray*)visibleIndexPaths;
- (NSArray*)visibleViews;
- (UIView*)viewAtIndexPath:(NSIndexPath*)indexPath;

- (CGRect)rectForRowAtIndexPath:(NSIndexPath*)indexPath;
- (void)updateViewsAnimated:(BOOL)animated;

@end
