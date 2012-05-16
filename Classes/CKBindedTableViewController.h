//
//  CKBindedTableViewController.h
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

typedef enum CKBindedTableViewControllerEditingType{
    CKBindedTableViewControllerEditingTypeNone,
    CKBindedTableViewControllerEditingTypeLeft,
    CKBindedTableViewControllerEditingTypeRight
}CKBindedTableViewControllerEditingType;

typedef enum CKBindedTableViewControllerScrollingPolicy{
    CKBindedTableViewControllerScrollingPolicyNone,
    CKBindedTableViewControllerScrollingPolicyResignResponder
}CKBindedTableViewControllerScrollingPolicy;

typedef enum CKBindedTableViewControllerSnappingPolicy{
    CKBindedTableViewControllerSnappingPolicyNone,
    CKBindedTableViewControllerSnappingPolicyCenter
}CKBindedTableViewControllerSnappingPolicy;

typedef void(^CKBindedTableViewControllerSearchBlock)(NSString* filter);

/** TODO
 */
@interface CKBindedTableViewController : CKTableViewController<UISearchBarDelegate> {
	CKTableViewOrientation _orientation;
	BOOL _resizeOnKeyboardNotification;
	
	int _currentPage;
	int _numberOfPages;
	
	BOOL _scrolling;
    CKBindedTableViewControllerScrollingPolicy _scrollingPolicy;
    
    CKBindedTableViewControllerEditingType _editableType;
    
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
@property (nonatomic, assign) CKBindedTableViewControllerScrollingPolicy scrollingPolicy;
/** 
 Specify the snap behavior when scrolling or selecting/scrolling to rows.
 */
@property (nonatomic, assign) CKBindedTableViewControllerSnappingPolicy snapPolicy;

- (void)scrollToRowAtIndexPath:(NSIndexPath*)indexPath animated:(BOOL)animated;

///-----------------------------------
/// @name Selection
///-----------------------------------

- (void)selectRowAtIndexPath:(NSIndexPath*)indexPath animated:(BOOL)animated;

@property (nonatomic, retain,readonly) NSIndexPath* selectedIndexPath;

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
@property (nonatomic, assign) CKBindedTableViewControllerEditingType editableType;

@property (nonatomic, retain) UIBarButtonItem *editButton;
@property (nonatomic, retain) UIBarButtonItem *doneButton;

///-----------------------------------
/// @name Search
///-----------------------------------
/** 
 Specify if search is enabled. It will add a search bar at the top of the view and call objectTableViewController:(CKBindedTableViewController*)controller didSearch:(NSString*)filter on the delegate and didSearch:(NSString*)text; on itself for inherited view controllers.
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
/** 
 This block will get called each time a the user enters text in the search bar or change the search scope.
 */
@property(nonatomic,copy)CKBindedTableViewControllerSearchBlock searchBlock;


//private
- (void)didSearch:(NSString*)text;

@end


/********************************* CKBindedTableViewControllerDelegate *********************************
 */

/** TODO
 */
@protocol CKBindedTableViewControllerDelegate
@optional
- (void)objectTableViewController:(CKBindedTableViewController*)controller didSelectRowAtIndexPath:(NSIndexPath*)indexPath withObject:(id)object;
- (void)objectTableViewController:(CKBindedTableViewController*)controller didSelectAccessoryViewRowAtIndexPath:(NSIndexPath*)indexPath withObject:(id)object;
- (void)objectTableViewController:(CKBindedTableViewController*)controller didSearch:(NSString*)filter;
@end

