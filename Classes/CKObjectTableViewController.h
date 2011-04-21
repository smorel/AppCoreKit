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
#import "CKNSDictionary+TableViewAttributes.h"
#import "CKDocumentCollection.h"

@interface CKObjectTableViewController : CKTableViewController<CKObjectControllerDelegate> {
	id _objectController;
	CKObjectViewControllerFactory* _controllerFactory;
	
	CKTableViewOrientation _orientation;
	BOOL _resizeOnKeyboardNotification;
	
	int _currentPage;
	int _numberOfPages;
	int _numberOfObjectsToprefetch;
	
	BOOL _scrolling;
	BOOL _editable;
	
	UITableViewRowAnimation _rowInsertAnimation;
	UITableViewRowAnimation _rowRemoveAnimation;
	
	//for editable tables
	UIBarButtonItem *editButton;
	UIBarButtonItem *doneButton;
	
	//internal
	NSMutableDictionary* _cellsToControllers;
	NSMutableDictionary* _cellsToIndexPath;
	NSMutableDictionary* _indexPathToCells;
	NSMutableArray* _weakCells;
	NSIndexPath* _indexPathToReachAfterRotation;
	NSMutableDictionary* _headerViewsForSections;
}

@property (nonatomic, retain) id objectController;
@property (nonatomic, retain) CKObjectViewControllerFactory* controllerFactory;

@property (nonatomic, assign) CKTableViewOrientation orientation;
@property (nonatomic, assign) UITableViewRowAnimation rowInsertAnimation;
@property (nonatomic, assign) UITableViewRowAnimation rowRemoveAnimation;
@property (nonatomic, assign) BOOL resizeOnKeyboardNotification;
@property (nonatomic, assign) int currentPage;
@property (nonatomic, assign) int numberOfPages;
@property (nonatomic, assign) int numberOfObjectsToprefetch;
@property (nonatomic, assign, readonly) BOOL scrolling;
@property (nonatomic, assign) BOOL editable;

@property (nonatomic, retain) UIBarButtonItem *editButton;
@property (nonatomic, retain) UIBarButtonItem *doneButton;

- (id)initWithCollection:(CKDocumentCollection*)collection mappings:(NSDictionary*)mappings;
- (id)initWithObjectController:(id)controller withControllerFactory:(CKObjectViewControllerFactory*)factory;
- (void)fetchMoreIfNeededAtIndexPath:(NSIndexPath*)indexPath;

@end
