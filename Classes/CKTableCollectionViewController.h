//
//  CKTableCollectionViewController.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright Wherecloud 2011. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKTableViewController.h"
#import "CKTableViewCellController.h"


//FIXME :
   //on rotation, resizer la search bar si besoin !

/**
 */
typedef enum CKTableCollectionViewControllerEditingType{
    CKTableCollectionViewControllerEditingTypeNone    = 0,
    CKTableCollectionViewControllerEditingTypeLeft    = 1 << 1,
    CKTableCollectionViewControllerEditingTypeRight   = 1 << 2,
    CKTableCollectionViewControllerEditingTypeAnimateTransition = 1 << 3
}CKTableCollectionViewControllerEditingType;

/**
 */
typedef enum CKTableCollectionViewControllerScrollingPolicy{
    CKTableCollectionViewControllerScrollingPolicyNone,
    CKTableCollectionViewControllerScrollingPolicyResignResponder
}CKTableCollectionViewControllerScrollingPolicy;

/**
 */
typedef enum CKTableCollectionViewControllerSnappingPolicy{
    CKTableCollectionViewControllerSnappingPolicyNone,
    CKTableCollectionViewControllerSnappingPolicyCenter
}CKTableCollectionViewControllerSnappingPolicy;

typedef void(^CKTableCollectionViewControllerSearchBlock)(NSString* filter);

typedef UITableViewRowAnimation(^CKTableCollectionViewControllerRowAnimationBlock)(CKTableCollectionViewController* controller, NSArray* objects, NSArray* indexPaths);
typedef UITableViewRowAnimation(^CKTableCollectionViewControllerSectionAnimationBlock)(CKTableCollectionViewController* controller, NSInteger index);

/**
 */
@interface CKTableCollectionViewController : CKTableViewController<UISearchBarDelegate> 

///-----------------------------------
/// @name Getting the Controller status
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
@property (nonatomic, assign) CKTableCollectionViewControllerScrollingPolicy scrollingPolicy;
/** 
 Specify the snap behavior when scrolling or selecting/scrolling to rows.
 */
@property (nonatomic, assign) CKTableCollectionViewControllerSnappingPolicy snapPolicy;

/**
 */
- (void)scrollToRowAtIndexPath:(NSIndexPath*)indexPath animated:(BOOL)animated;

///-----------------------------------
/// @name Managing the Selection
///-----------------------------------

/**
 */
- (void)selectRowAtIndexPath:(NSIndexPath*)indexPath animated:(BOOL)animated;

/**
 */
- (void)deselectRowAtIndexPath:(NSIndexPath*)indexPath animated:(BOOL)animated;

/**
 */
@property (nonatomic, retain,readonly) NSIndexPath* selectedIndexPath;

///-----------------------------------
/// @name Customizing the Appearance
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
/// @name Animating
///-----------------------------------
/** 
Specify the animations that should be launch on row and sections insertion
*/
@property (nonatomic, assign) UITableViewRowAnimation rowInsertAnimation;
/** 
 Specify the animations that should be launch on row and sections removal
 */
@property (nonatomic, assign) UITableViewRowAnimation rowRemoveAnimation;

/**
 This block is called when objects have to be inserted to the table.
 By default, this block returns the rowInsertAnimation property value.
 You can overload this block to customize row insertion animation contextually.
 returning UITableViewRowAnimationNone will reload the tableView to get no animations. 
 */
@property (nonatomic, copy) CKTableCollectionViewControllerRowAnimationBlock rowInsertAnimationBlock;


/**
 This block is called when sections have to be inserted to the table.
 By default, this block returns the rowInsertAnimation property value.
 You can overload this block to customize section insertion animation contextually.
 returning UITableViewRowAnimationNone will reload the tableView to get no animations.
 */
@property (nonatomic, copy) CKTableCollectionViewControllerSectionAnimationBlock sectionInsertAnimationBlock;

/**
 This block is called when objects have to be removed from the table.
 By default, this block returns the rowRemoveAnimation property value.
 You can overload this block to customize row removal animation contextually.
 returning UITableViewRowAnimationNone will reload the tableView to get no animations.
 */
@property (nonatomic, copy) CKTableCollectionViewControllerRowAnimationBlock rowRemoveAnimationBlock;

/**
 This block is called when sections have to be removed from the table.
 By default, this block returns the rowRemoveAnimation property value.
 You can overload this block to customize section removal animation contextually.
 returning UITableViewRowAnimationNone will reload the tableView to get no animations.
 */
@property (nonatomic, copy) CKTableCollectionViewControllerSectionAnimationBlock sectionRemoveAnimationBlock;

///-----------------------------------
/// @name Editing
///-----------------------------------
/** 
Specify if the table is editable. If yes, an edit/done button is automatically added to the left/right of the navigation bar.
*/
@property (nonatomic, assign) CKTableCollectionViewControllerEditingType editableType;

/**
 */
@property (nonatomic, retain) UIBarButtonItem *editButton;

/**
 */
@property (nonatomic, retain) UIBarButtonItem *doneButton;

///-----------------------------------
/// @name Searching
///-----------------------------------
/** 
 Specify if search is enabled. It will add a search bar at the top of the view and call objectTableViewController:(CKTableCollectionViewController*)controller didSearch:(NSString*)filter on the delegate and didSearch:(NSString*)text; on itself for inherited view controllers.
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
@property(nonatomic,copy)CKTableCollectionViewControllerSearchBlock searchBlock;


//private
- (void)didSearch:(NSString*)text;

@end


/********************************* CKTableCollectionViewControllerDelegate *********************************
 */

/**
 */
@protocol CKTableCollectionViewControllerDelegate
@optional

///-----------------------------------
/// @name Managing the Selection
///-----------------------------------

/**
 */
- (void)objectTableViewController:(CKTableCollectionViewController*)controller didSelectRowAtIndexPath:(NSIndexPath*)indexPath withObject:(id)object;

/**
 */
- (void)objectTableViewController:(CKTableCollectionViewController*)controller didSelectAccessoryViewRowAtIndexPath:(NSIndexPath*)indexPath withObject:(id)object;

///-----------------------------------
/// @name Searching
///-----------------------------------

/**
 */
- (void)objectTableViewController:(CKTableCollectionViewController*)controller didSearch:(NSString*)filter;
@end

