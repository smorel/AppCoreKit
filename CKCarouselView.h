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
– tableView:cellForRowAtIndexPath:  required method
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

@interface CKCarouselView : UIView<UIGestureRecognizerDelegate> {
	CGFloat _contentOffset;
	NSInteger _numberOfPages;
	NSInteger _currentPage;
	
	UIView* _visibleHeaderView;
	NSMutableDictionary* _visibleViewsForIndexPaths;
	
	id _dataSource;
	id _delegate;
	
	NSMutableDictionary* _reusableViews;
	CKCarouselViewDisplayType _displayType;
	
	CGFloat _contentOffsetWhenStartPanning;
}

@property (nonatomic,assign) NSInteger numberOfPages;
@property (nonatomic,assign) NSInteger currentPage;
@property (nonatomic,assign) IBOutlet id dataSource;
@property (nonatomic,assign) IBOutlet id delegate;
@property (nonatomic,assign) CKCarouselViewDisplayType displayType;

- (void)reloadData;
- (UIView*)dequeuReusableViewWithIdentifier:(id)identifier;
- (void)setContentOffset:(CGFloat)offset animated:(BOOL)animated;

- (NSIndexPath*)indexPathForPage:(NSInteger)page;
- (NSInteger)pageForIndexPath:(NSIndexPath*)indexPath;
- (CGRect)rectForRowAtIndexPath:(NSIndexPath*)indexPath;

@end
