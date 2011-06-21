//
//  CKItemViewContainerController.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-05-25.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKUIViewController.h"

#import "CKObjectController.h"
#import "CKObjectViewControllerFactory.h"
#import "CKDocumentCollection.h"
#import "CKItemViewController.h"

//not needed in this implementation but very often used when inheriting ...
#import "CKNSDictionary+TableViewAttributes.h"
#import "CKObjectViewControllerFactory.h"
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
 - (NSArray*)visibleViews
 - (void)updateParams
 - (UIView*)dequeueReusableViewWithIdentifier:(NSString*)identifier
 
   you SHOULD implement :
 
 - (void)onReload
 - (void)onBeginUpdates
 - (void)onEndUpdates
 - (void)onInsertObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths
 - (void)onRemoveObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths
*/

@interface CKItemViewContainerController : CKUIViewController<CKObjectControllerDelegate> {
	id _objectController;
	CKObjectViewControllerFactory* _controllerFactory;
	
	//Internal view/controller management
	NSMutableDictionary* _viewsToControllers;
	NSMutableDictionary* _viewsToIndexPath;
	NSMutableDictionary* _indexPathToViews;
	NSMutableArray* _weakViews;
	
	NSMutableDictionary* _params;
	
	id _delegate;
	int _numberOfObjectsToprefetch;
}

@property (nonatomic, retain) id objectController;
@property (nonatomic, retain) CKObjectViewControllerFactory* controllerFactory;
@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) int numberOfObjectsToprefetch;

//private property
@property (nonatomic, retain) NSMutableDictionary* params;

//init
- (id)initWithCollection:(CKDocumentCollection*)collection mappings:(NSArray*)mappings;
- (id)initWithObjectController:(id)controller withControllerFactory:(CKObjectViewControllerFactory*)factory;
- (id)initWithCollection:(CKDocumentCollection*)collection mappings:(NSArray*)mappings withNibName:(NSString*)nib;
- (id)initWithObjectController:(id)controller withControllerFactory:(CKObjectViewControllerFactory*)factory  withNibName:(NSString*)nib;

//update
- (void)updateVisibleViewsIndexPath;
- (void)updateVisibleViewsRotation;
- (void)updateViewsVisibility:(BOOL)visible;

//view representation management
- (CKItemViewController*)controllerAtIndexPath:(NSIndexPath *)indexPath;
- (UIView*)viewAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath*)indexPathForView:(UIView*)view;
- (NSArray*)visibleViews;
- (UIView*)createViewAtIndexPath:(NSIndexPath*)indexPath;
- (UIView*)dequeueReusableViewWithIdentifier:(NSString*)identifier;
- (BOOL)isValidIndexPath:(NSIndexPath*)indexPath;

- (id)objectAtIndexPath:(NSIndexPath*)indexPath;
- (NSArray*)objectsForSection:(NSInteger)section;
- (NSInteger)indexOfObject:(id)object inSection:(NSInteger)section;

//hierarchy management
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

//Helpers
- (CKFeedSource*)collectionDataSource;

//Private
- (void)updateParams;
- (void)postInit; // Subclasses can override this method to perform additional initialization

@end



@protocol CKItemViewContainerControllerDelegate
@optional
- (void)itemViewContainerController:(CKItemViewContainerController*)controller didSelectViewAtIndexPath:(NSIndexPath*)indexPath withObject:(id)object;
- (void)itemViewContainerController:(CKItemViewContainerController*)controller didSelectAccessoryViewAtIndexPath:(NSIndexPath*)indexPath withObject:(id)object;
@end
