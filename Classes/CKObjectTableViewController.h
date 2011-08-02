//
//  RootViewController.h
//  FeedView
//
//  Created by Sebastien Morel on 11-03-16.
//  Copyright Wherecloud 2011. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKTableViewController.h"
#import "CKTableViewCellController.h"


/** TODO
 */
@interface CKObjectTableViewController : CKTableViewController<UISearchBarDelegate> {
	CKTableViewOrientation _orientation;
	BOOL _resizeOnKeyboardNotification;
	
	int _currentPage;
	int _numberOfPages;
	
	BOOL _scrolling;
	BOOL _editable;
	
	UITableViewRowAnimation _rowInsertAnimation;
	UITableViewRowAnimation _rowRemoveAnimation;
	
	//for editable tables
	UIBarButtonItem *editButton;
	UIBarButtonItem *doneButton;
	UIBarButtonItem *rightButton;
	UIBarButtonItem *leftButton;
	
	//internal
	NSIndexPath* _indexPathToReachAfterRotation;
	
	//search
	BOOL _searchEnabled;
	UISearchBar* _searchBar;
	CGFloat _liveSearchDelay;
	UISegmentedControl* _segmentedControl;
	NSDictionary* _searchScopeDefinition;//dico of with [object:CKCallback key:localized label or uiimage]
	id _defaultSearchScope;
	
    int _modalViewCount;
    UIView* _placeHolderViewDuringKeyboardOrSheet;
    
	BOOL _viewIsOnScreen;
	
	CGFloat _tableMaximumWidth;
}

@property (nonatomic, assign) CKTableViewOrientation orientation;
@property (nonatomic, assign) UITableViewRowAnimation rowInsertAnimation;
@property (nonatomic, assign) UITableViewRowAnimation rowRemoveAnimation;
@property (nonatomic, assign) BOOL resizeOnKeyboardNotification;
@property (nonatomic, assign) int currentPage;
@property (nonatomic, assign) int numberOfPages;
@property (nonatomic, assign, readonly) BOOL scrolling;
@property (nonatomic, assign) BOOL editable;
@property (nonatomic, assign) BOOL searchEnabled;
@property (nonatomic, assign,readonly) BOOL viewIsOnScreen;
@property (nonatomic, assign) CGFloat liveSearchDelay;
@property (nonatomic, assign) CGFloat tableMaximumWidth;

@property (nonatomic, retain) UISearchBar* searchBar;
@property (nonatomic, retain) UISegmentedControl* segmentedControl;
@property (nonatomic, retain) NSDictionary* searchScopeDefinition;
@property (nonatomic, retain) id defaultSearchScope;

@property (nonatomic, retain) UIBarButtonItem *editButton;
@property (nonatomic, retain) UIBarButtonItem *doneButton;
@property (nonatomic, retain) UIBarButtonItem *rightButton;
@property (nonatomic, retain) UIBarButtonItem *leftButton;

//private
- (void)didSearch:(NSString*)text;

@end


/** TODO
 */
@protocol CKObjectTableViewControllerDelegate
@optional
- (void)objectTableViewController:(CKObjectTableViewController*)controller didSelectRowAtIndexPath:(NSIndexPath*)indexPath withObject:(id)object;
- (void)objectTableViewController:(CKObjectTableViewController*)controller didSelectAccessoryViewRowAtIndexPath:(NSIndexPath*)indexPath withObject:(id)object;
- (void)objectTableViewController:(CKObjectTableViewController*)controller didSearch:(NSString*)filter;
@end
