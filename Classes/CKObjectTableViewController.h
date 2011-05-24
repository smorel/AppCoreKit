//
//  RootViewController.h
//  FeedView
//
//  Created by Sebastien Morel on 11-03-16.
//  Copyright Wherecloud 2011. All rights reserved.
//

#import "CKTableViewController.h"
#import "CKObjectController.h"
#import "CKObjectViewControllerFactory.h"
#import "CKDocumentCollection.h"
#import "CKTableViewCellController.h"

//not needed in this implementation but very often used when inheriting ...
#import "CKNSDictionary+TableViewAttributes.h"
#import "CKObjectViewControllerFactory.h"
#import "CKDocumentController.h"

@interface CKObjectTableViewController : CKTableViewController<CKObjectControllerDelegate,UISearchBarDelegate> {
	id _objectController;
	CKObjectViewControllerFactory* _controllerFactory;
	
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
	NSMutableDictionary* _cellsToControllers;
	NSMutableDictionary* _cellsToIndexPath;
	NSMutableDictionary* _indexPathToCells;
	NSMutableDictionary* _params;
	NSMutableArray* _weakCells;
	NSIndexPath* _indexPathToReachAfterRotation;
	NSMutableDictionary* _headerViewsForSections;
	
	id _delegate;
	
	UISearchBar* _searchBar;
	CGFloat _liveSearchDelay;
	
	CGRect _frameBeforeKeyboardNotification;
}

@property (nonatomic, retain) id objectController;
@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) CKObjectViewControllerFactory* controllerFactory;

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
@property (nonatomic, assign) CGFloat liveSearchDelay;

@property (nonatomic, retain) UIBarButtonItem *editButton;
@property (nonatomic, retain) UIBarButtonItem *doneButton;

- (id)initWithCollection:(CKDocumentCollection*)collection mappings:(NSArray*)mappings;
- (id)initWithObjectController:(id)controller withControllerFactory:(CKObjectViewControllerFactory*)factory;

- (id)initWithCollection:(CKDocumentCollection*)collection mappings:(NSArray*)mappings withNibName:(NSString*)nib;
- (id)initWithObjectController:(id)controller withControllerFactory:(CKObjectViewControllerFactory*)factory  withNibName:(NSString*)nib;

- (void)fetchMoreIfNeededAtIndexPath:(NSIndexPath*)indexPath;
- (CKTableViewCellController*)controllerForRowAtIndexPath:(NSIndexPath *)indexPath;

@end


@protocol CKObjectTableViewControllerDelegate
@optional
- (void)objectTableViewController:(CKObjectTableViewController*)controller didSelectRowAtIndexPath:(NSIndexPath*)indexPath withObject:(id)object;
- (void)objectTableViewController:(CKObjectTableViewController*)controller didSelectAccessoryViewRowAtIndexPath:(NSIndexPath*)indexPath withObject:(id)object;
- (void)objectTableViewController:(CKObjectTableViewController*)controller didSearch:(NSString*)filter;
@end
