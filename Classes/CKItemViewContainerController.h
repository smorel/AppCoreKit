//
//  CKItemViewContainerController.h
//  CloudKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKUIViewController.h"

#import "CKObjectController.h"
#import "CKItemViewControllerFactory.h"
#import "CKDocumentCollection.h"
#import "CKItemViewController.h"

//not needed in this implementation but very often used when inheriting ...
#import "CKNSDictionary+TableViewAttributes.h"
#import "CKDocumentController.h"

/* This controller implements the logic to deals with objects via objectcontroller and controllerfactory.
   It will gives all the basic logic for live update from documents/view creation and reusing, controller creation/reusing
   and manage the item controller flags/selection/remove, ...
 
   By derivating this controller, you'll just have to implement the UIKit specific delegates and view creation and redirect
   to the basic implementation of CKItemViewContainerController
 
   By this way we centralize all the document/viewcontroller logic taht is redondant in this class
 
   For some specific implementations see : CKObjectTableViewController, CKObjectCarouselViewController and CKMapViewController
 
 
  *  derivating this controller means
 
   you MUST implement :
 
 - (UIView*)viewAtIndexPath:(NSIndexPath *)indexPath
 - (NSIndexPath*)indexPathForView:(UIView*)view
 - (void)updateParams
 - (UIView*)dequeueReusableViewWithIdentifier:(NSString*)identifier
 
   you SHOULD implement :
 
 - (void)onReload
 - (void)onBeginUpdates
 - (void)onEndUpdates
 - (void)onInsertObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths
 - (void)onRemoveObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths
*/


/** TODO
 */
@interface CKItemViewContainerController : CKUIViewController<CKObjectControllerDelegate> {
	id _objectController;
	CKItemViewControllerFactory* _controllerFactory;
	
	//Internal view/controller management
	NSMutableDictionary* _viewsToControllers;
	NSMutableDictionary* _viewsToIndexPath;
	NSMutableDictionary* _indexPathToViews;
	NSMutableArray* _weakViews;
    NSMutableArray* _sectionsToControllers; //containing NSMutableArray of CKItemViewController
	
	NSMutableDictionary* _params;
	
	id _delegate;
	int _numberOfObjectsToprefetch;
}

@property (nonatomic, retain) id objectController;
@property (nonatomic, retain) CKItemViewControllerFactory* controllerFactory;
@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) int numberOfObjectsToprefetch;

@property (nonatomic, assign, readonly) BOOL rotating;

//private property
@property (nonatomic, retain) NSMutableDictionary* params;

//init
- (id)initWithCollection:(CKDocumentCollection*)collection factory:(CKItemViewControllerFactory*)factory;
- (id)initWithObjectController:(id)controller factory:(CKItemViewControllerFactory*)factory;

- (id)initWithObjectController:(id)controller factory:(CKItemViewControllerFactory*)factory  nibName:(NSString*)nib;
- (id)initWithCollection:(CKDocumentCollection*)collection factory:(CKItemViewControllerFactory*)factory nibName:(NSString*)nib;

//setup
- (void)setupWithCollection:(CKDocumentCollection*)collection factory:(CKItemViewControllerFactory*)factory;

//update
- (void)updateVisibleViewsIndexPath;
- (void)updateVisibleViewsRotation;
- (void)updateViewsVisibility:(BOOL)visible;

//view representation management
- (CKItemViewController*)controllerAtIndexPath:(NSIndexPath *)indexPath;
- (UIView*)viewAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath*)indexPathForView:(UIView*)view;
- (NSArray*)visibleIndexPaths;
- (UIView*)createViewAtIndexPath:(NSIndexPath*)indexPath;
- (UIView*)dequeueReusableViewWithIdentifier:(NSString*)identifier;
- (BOOL)isValidIndexPath:(NSIndexPath*)indexPath;

- (id)objectAtIndexPath:(NSIndexPath*)indexPath;
- (NSArray*)objectsForSection:(NSInteger)section;
- (NSInteger)indexOfObject:(id)object inSection:(NSInteger)section;

//content management
- (NSInteger)numberOfSections;
- (NSInteger)numberOfObjectsForSection:(NSInteger)section;

- (void)fetchObjectsInRange:(NSRange)range  forSection:(NSInteger)section;
- (void)fetchMoreData;
- (void)fetchMoreIfNeededAtIndexPath:(NSIndexPath*)indexPath;

//items controller interactions
- (CGSize)sizeForViewAtIndexPath:(NSIndexPath *)indexPath;
- (CKItemViewFlags)flagsForViewAtIndexPath:(NSIndexPath*)indexPath;

- (BOOL)willSelectViewAtIndexPath:(NSIndexPath *)indexPath;
- (void)didSelectViewAtIndexPath:(NSIndexPath *)indexPath;
- (void)didSelectAccessoryViewAtIndexPath:(NSIndexPath *)indexPath;

- (BOOL)isViewEditableAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)isViewMovableAtIndexPath:(NSIndexPath *)indexPath;

//Parent controller interactions
- (void)didRemoveViewAtIndexPath:(NSIndexPath*)indexPath;
- (void)didMoveViewAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;
- (NSIndexPath*)targetIndexPathForMoveFromIndexPath:(NSIndexPath*)sourceIndexPath toProposedIndexPath:(NSIndexPath*)proposedDestinationIndexPath;

//document update callbacks
- (void)onReload;
- (void)onBeginUpdates;
- (void)onEndUpdates;
- (void)onInsertObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths;
- (void)onRemoveObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths;
- (void)onInsertSectionAtIndex:(NSInteger)index;
- (void)onRemoveSectionAtIndex:(NSInteger)index;

- (void)reload;

//Helpers
- (CKFeedSource*)collectionDataSource;

//Private
- (void)updateParams;

@end



/** TODO
 */
@protocol CKItemViewContainerControllerDelegate
@optional
- (void)itemViewContainerController:(CKItemViewContainerController*)controller didSelectViewAtIndexPath:(NSIndexPath*)indexPath withObject:(id)object;
- (void)itemViewContainerController:(CKItemViewContainerController*)controller didSelectAccessoryViewAtIndexPath:(NSIndexPath*)indexPath withObject:(id)object;
@end



/********************************* DEPRECATED *********************************
 */

@interface CKItemViewContainerController(DEPRECATED_IN_CLOUDKIT_VERSION_1_7_14_AND_LATER)
- (id)initWithCollection:(CKDocumentCollection*)collection mappings:(NSArray*)mappings DEPRECATED_ATTRIBUTE;
- (id)initWithCollection:(CKDocumentCollection*)collection mappings:(NSArray*)mappings withNibName:(NSString*)nib DEPRECATED_ATTRIBUTE;
- (id)initWithObjectController:(id)controller withControllerFactory:(CKItemViewControllerFactory*)factory DEPRECATED_ATTRIBUTE;
- (id)initWithObjectController:(id)controller withControllerFactory:(CKItemViewControllerFactory*)factory  withNibName:(NSString*)nib DEPRECATED_ATTRIBUTE;
- (void)setupWithCollection:(CKDocumentCollection*)collection mappings:(NSArray*)mappings DEPRECATED_ATTRIBUTE;
@end