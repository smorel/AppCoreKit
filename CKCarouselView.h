//
//  CKCarouselView.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-07.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CKCarouselView;
@protocol CKCarouselViewDataSource
- (NSInteger)numberOfSectionsInCarouselView:(CKCarouselView*)carouselView;
- (NSInteger)carouselView:(CKCarouselView*)carouselView numberOfRowsInSection:(NSInteger)section;
- (UIView*)carouselView:(CKCarouselView*)carouselView viewForRowAtIndexPath:(NSIndexPath*)indexPath;

/*Configuring a Table View
– sectionIndexTitlesForTableView:
– tableView:sectionForSectionIndexTitle:atIndex:
– tableView:titleForHeaderInSection:
– tableView:titleForFooterInSection:
Inserting or Deleting Table Rows
– tableView:commitEditingStyle:forRowAtIndexPath:
– tableView:canEditRowAtIndexPath:
Reordering Table Rows
– tableView:canMoveRowAtIndexPath:
– tableView:moveRowAtIndexPath:toIndexPath:
 */
@end


@protocol CKCarouselViewDelegate
- (UIView*) carouselView:(CKCarouselView*)carouselView viewForHeaderInSection:(NSInteger)section;
- (CGSize) carouselView:(CKCarouselView*)carouselView sizeForViewAtIndexPath:(NSIndexPath*)indexPath;
- (void) carouselView:(CKCarouselView*)carouselView viewDidDisappearAtIndexPath:(NSIndexPath*)indexPath;
- (void) carouselView:(CKCarouselView*)carouselView viewDidAppearAtIndexPath:(NSIndexPath*)indexPath;
- (void) carouselViewDidScroll:(CKCarouselView*)carouselView;

/*Configuring Rows for the Table View
– tableView:heightForRowAtIndexPath:
– tableView:indentationLevelForRowAtIndexPath:
– tableView:willDisplayCell:forRowAtIndexPath:
Managing Accessory Views
– tableView:accessoryButtonTappedForRowWithIndexPath:
– tableView:accessoryTypeForRowWithIndexPath: Deprecated in iOS 3.0
Managing Selections
– tableView:willSelectRowAtIndexPath:
– tableView:didSelectRowAtIndexPath:
– tableView:willDeselectRowAtIndexPath:
– tableView:didDeselectRowAtIndexPath:
Modifying the Header and Footer of Sections
– tableView:viewForHeaderInSection:
– tableView:viewForFooterInSection:
– tableView:heightForHeaderInSection:
– tableView:heightForFooterInSection:
Editing Table Rows
– tableView:willBeginEditingRowAtIndexPath:
– tableView:didEndEditingRowAtIndexPath:
– tableView:editingStyleForRowAtIndexPath:
– tableView:titleForDeleteConfirmationButtonForRowAtIndexPath:
– tableView:shouldIndentWhileEditingRowAtIndexPath:
Reordering Table Rows
– tableView:targetIndexPathForMoveFromRowAtIndexPath:toProposedIndexPath:
*/
@end


typedef enum{
	CKCarouselViewDisplayTypeHorizontal
}CKCarouselViewDisplayType;

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

@property (nonatomic,assign) NSInteger numberOfPages;
@property (nonatomic,assign) NSInteger currentPage;
@property (nonatomic,assign) NSInteger currentSection;
@property (nonatomic,assign) CGFloat spacing;
@property (nonatomic,assign) IBOutlet id dataSource;
//@property (nonatomic,assign) IBOutlet id delegate;
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
