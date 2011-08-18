//
//  CKObjectTableViewController.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-03-16.
//  Copyright Wherecloud 2011. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKTableViewController.h"
#import "CKTableViewCellController.h"


//FIXME :
   //on rotation, resizer la search bar si besoin !

typedef enum CKObjectTableViewControllerEditableType{
    CKObjectTableViewControllerEditableTypeNone,
    CKObjectTableViewControllerEditableTypeLeft,
    CKObjectTableViewControllerEditableTypeRight
}CKObjectTableViewControllerEditableType;

typedef enum CKObjectTableViewControllerScrollingPolicy{
    CKObjectTableViewControllerScrollingPolicyNone,
    CKObjectTableViewControllerScrollingPolicyResignResponder
}CKObjectTableViewControllerScrollingPolicy;

/** TODO
 */
@interface CKObjectTableViewController : CKTableViewController<UISearchBarDelegate> {
	CKTableViewOrientation _orientation;
	BOOL _resizeOnKeyboardNotification;
	
	int _currentPage;
	int _numberOfPages;
	
	BOOL _scrolling;
    CKObjectTableViewControllerScrollingPolicy _scrollingPolicy;
    
    CKObjectTableViewControllerEditableType _editableType;
	
	UIBarButtonItem *rightButton;
	UIBarButtonItem *leftButton;
    
	UITableViewRowAnimation _rowInsertAnimation;
	UITableViewRowAnimation _rowRemoveAnimation;
	
	//for editable tables
	UIBarButtonItem *editButton;
	UIBarButtonItem *doneButton;
	
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
    
    id _storedTableDelegate;
    id _storedTableDataSource;
}

///-----------------------------------
/// @name Current State
///-----------------------------------

/** 
 Returns the current page computed using tableView height or width depending on the orientation
 */
@property (nonatomic, assign, readonly) int currentPage;
/** 
 Returns the number of pages computed using tableView height or width depending on the orientation
 */
@property (nonatomic, assign, readonly) int numberOfPages;
/** 
 Returns whether the view is on screen or not
 */
@property (nonatomic, assign,readonly)  BOOL viewIsOnScreen;

///-----------------------------------
/// @name Scrolling
///-----------------------------------
/** 
 Returns the scrolling state of the table. Somebody can bind himself on this property to act depending on the scrolling state for example.
 */
@property (nonatomic, assign, readonly) BOOL scrolling;
/** 
 Specify the behavior that will get triggered when scrolling.
 */
@property (nonatomic, assign) CKObjectTableViewControllerScrollingPolicy scrollingPolicy;

///-----------------------------------
/// @name Layout
///-----------------------------------
/** 
 Specify if the scrolling interactions should be horizontal or vertical
*/
@property (nonatomic, assign) CKTableViewOrientation orientation;
/** 
 Specify if the table should resize itself on keyboard or sheet notifications
 */
@property (nonatomic, assign) BOOL resizeOnKeyboardNotification;
/** 
 Specify a maximum width for the table to center it easilly if the parent view is bigger.
 */
@property (nonatomic, assign) CGFloat tableMaximumWidth;

///-----------------------------------
/// @name Animation
///-----------------------------------
/** 
Specify the animations that should be launch on row and sections insertion
*/
@property (nonatomic, assign) UITableViewRowAnimation rowInsertAnimation;
/** 
 Specify the animations that should be launch on row and sections removal
 */
@property (nonatomic, assign) UITableViewRowAnimation rowRemoveAnimation;

///-----------------------------------
/// @name Edition
///-----------------------------------
/** 
Specify if the table is editable. If yes, an edit/done button is automatically added to the left/right of the navigation bar.
*/
@property (nonatomic, assign) CKObjectTableViewControllerEditableType editableType;

///-----------------------------------
/// @name Search
///-----------------------------------
/** 
 Specify if search is enabled. It will add a search bar at the top of the view and call objectTableViewController:(CKObjectTableViewController*)controller didSearch:(NSString*)filter on the delegate and didSearch:(NSString*)text; on itself for inherited view controllers.
 */
@property (nonatomic, assign) BOOL searchEnabled;
/** 
 Specify a delay when entering text for live search.
 */
@property (nonatomic, assign) CGFloat liveSearchDelay;
/** 
 Returns the displayed search bar or nil if searchEnabled is NO.
 */
@property (nonatomic, retain, readonly) UISearchBar* searchBar;
/** 
 Specify the search scope as a dictionary of localized label and CKCallback.
 */
@property (nonatomic, retain) NSDictionary* searchScopeDefinition;
/** 
 Specify the identifier of the scope that should be selected by default
 */
@property (nonatomic, retain) id defaultSearchScope;
/** 
 Returns the displayed segemnted control if the searchScopeDefinition is defined.
 */
@property (nonatomic, retain, readonly) UISegmentedControl* segmentedControl;

//private
- (void)didSearch:(NSString*)text;

///-----------------------------------
/// @name Navigation Buttons
///-----------------------------------
/** 
 Specify the bar button item that should be displayed at the right of the navigation bar.
 */
@property (nonatomic, retain) UIBarButtonItem *rightButton;
/** 
 Specify the bar button item that should be displayed at the left of the navigation bar.
 */
@property (nonatomic, retain) UIBarButtonItem *leftButton;

@end

@interface CKObjectTableViewController (DEPRECATED_IN_CLOUDKIT_VERSION_1_7_AND_LATER)
@property (nonatomic) BOOL editable DEPRECATED_ATTRIBUTE;
@end


/** TODO
 */
@protocol CKObjectTableViewControllerDelegate
@optional
- (void)objectTableViewController:(CKObjectTableViewController*)controller didSelectRowAtIndexPath:(NSIndexPath*)indexPath withObject:(id)object;
- (void)objectTableViewController:(CKObjectTableViewController*)controller didSelectAccessoryViewRowAtIndexPath:(NSIndexPath*)indexPath withObject:(id)object;
- (void)objectTableViewController:(CKObjectTableViewController*)controller didSearch:(NSString*)filter;
@end
