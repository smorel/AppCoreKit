//
//  CKCarouselView.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class CKCarouselView;

/**
 */
@protocol CKCarouselViewDataSource
- (NSInteger)numberOfSectionsInCarouselView:(CKCarouselView*)carouselView;
- (NSInteger)carouselView:(CKCarouselView*)carouselView numberOfRowsInSection:(NSInteger)section;
- (UIView*)carouselView:(CKCarouselView*)carouselView viewForRowAtIndexPath:(NSIndexPath*)indexPath;
@end


/**
 */
@protocol CKCarouselViewDelegate
- (UIView*) carouselView:(CKCarouselView*)carouselView viewForHeaderInSection:(NSInteger)section;
- (CGSize) carouselView:(CKCarouselView*)carouselView sizeForViewAtIndexPath:(NSIndexPath*)indexPath;
- (void) carouselView:(CKCarouselView*)carouselView viewDidDisappearAtIndexPath:(NSIndexPath*)indexPath;
- (void) carouselView:(CKCarouselView*)carouselView viewDidAppearAtIndexPath:(NSIndexPath*)indexPath;
- (void) carouselViewDidScroll:(CKCarouselView*)carouselView;
@end


/**
 */
typedef NS_ENUM(NSInteger, CKCarouselViewDisplayType){
	CKCarouselViewDisplayTypeHorizontal
};


/**
 */
@interface CKCarouselView : UIScrollView<UIGestureRecognizerDelegate> 

///-----------------------------------
/// @name Getting the carousel view status
///-----------------------------------

/**
 */
@property (nonatomic,assign,readonly) NSInteger numberOfPages;

/**
 */
@property (nonatomic,assign,readonly) NSInteger currentPage;

/**
 */
@property (nonatomic,assign,readonly) NSInteger currentSection;

/**
 */
@property (nonatomic,assign,readonly) CGFloat internalContentOffset;

///-----------------------------------
/// @name Customizing the appearance
///-----------------------------------

/**
 */
@property (nonatomic,assign) CGFloat spacing;

/**
 */
@property (nonatomic,assign) CKCarouselViewDisplayType displayType;

///-----------------------------------
/// @name Managing the Data Source
///-----------------------------------

/**
 */
@property (nonatomic,assign) IBOutlet id dataSource;

///-----------------------------------
/// @name Updating the Carousel View
///-----------------------------------

/**
 */
- (void)reloadData;

/**
 */
- (void)updateViewsAnimated:(BOOL)animated;

///-----------------------------------
/// @name Configuring a Table View
///-----------------------------------

/**
 */
- (UIView*)dequeueReusableViewWithIdentifier:(id)identifier;

/** Offset is normalized between 0 & numberOfPages
    contentOffset represents the center of the carousel
 */
- (void)setContentOffset:(CGFloat)offset animated:(BOOL)animated;

- (NSIndexPath*)indexPathForPage:(NSInteger)page;
- (NSInteger)pageForIndexPath:(NSIndexPath*)indexPath;

///-----------------------------------
/// @name Accessing Cells and Sections
///-----------------------------------

/**
 */
- (NSArray*)visibleIndexPaths;

/**
 */
- (NSArray*)visibleViews;

/**
 */
- (UIView*)viewAtIndexPath:(NSIndexPath*)indexPath;

/**
 */
- (CGRect)rectForRowAtIndexPath:(NSIndexPath*)indexPath;


@end
