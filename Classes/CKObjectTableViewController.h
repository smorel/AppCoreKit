//
//  RootViewController.h
//  FeedView
//
//  Created by Sebastien Morel on 11-03-16.
//  Copyright Wherecloud 2011. All rights reserved.
//

#import "CKTableViewController.h"
#import "CKTableViewCellController.h"

@interface CKObjectTableViewController : CKTableViewController<UISearchBarDelegate> {
	CKTableViewOrientation _orientation;
	BOOL _resizeOnKeyboardNotification;
	BOOL _moveOnKeyboardNotification;
	
	int _currentPage;
	int _numberOfPages;
	int _numberOfObjectsToprefetch;
	
	BOOL _scrolling;
	BOOL _editable;
	BOOL _searchEnabled;
	
	UITableViewRowAnimation _rowInsertAnimation;
	UITableViewRowAnimation _rowRemoveAnimation;
	
	//for editable tables
	UIBarButtonItem *editButton;
	UIBarButtonItem *doneButton;
	
	//internal
	NSIndexPath* _indexPathToReachAfterRotation;
	NSMutableDictionary* _headerViewsForSections;
	
	UISearchBar* _searchBar;
	CGFloat _liveSearchDelay;
	
	CGRect _frameBeforeKeyboardNotification;
	BOOL _viewIsOnScreen;
}

@property (nonatomic, assign) CKTableViewOrientation orientation;
@property (nonatomic, assign) UITableViewRowAnimation rowInsertAnimation;
@property (nonatomic, assign) UITableViewRowAnimation rowRemoveAnimation;
@property (nonatomic, assign) BOOL resizeOnKeyboardNotification;
@property (nonatomic, assign) BOOL moveOnKeyboardNotification;
@property (nonatomic, assign) int currentPage;
@property (nonatomic, assign) int numberOfPages;
@property (nonatomic, assign) int numberOfObjectsToprefetch;
@property (nonatomic, assign, readonly) BOOL scrolling;
@property (nonatomic, assign) BOOL editable;
@property (nonatomic, assign) BOOL searchEnabled;
@property (nonatomic, assign,readonly) BOOL viewIsOnScreen;
@property (nonatomic, assign) CGFloat liveSearchDelay;

@property (nonatomic, retain) UIBarButtonItem *editButton;
@property (nonatomic, retain) UIBarButtonItem *doneButton;

- (void)fetchMoreIfNeededAtIndexPath:(NSIndexPath*)indexPath;

@end


@protocol CKObjectTableViewControllerDelegate
@optional
- (void)objectTableViewController:(CKObjectTableViewController*)controller didSelectRowAtIndexPath:(NSIndexPath*)indexPath withObject:(id)object;
- (void)objectTableViewController:(CKObjectTableViewController*)controller didSelectAccessoryViewRowAtIndexPath:(NSIndexPath*)indexPath withObject:(id)object;
- (void)objectTableViewController:(CKObjectTableViewController*)controller didSearch:(NSString*)filter;
@end
