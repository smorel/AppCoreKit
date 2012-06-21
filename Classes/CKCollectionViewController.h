//
//  CKCollectionViewController.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-05-25.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKViewController.h"

#import "CKObjectController.h"
#import "CKCollectionCellControllerFactory.h"
#import "CKCollection.h"
#import "CKCollectionCellController.h"
#import "CKCollectionController.h"

/* This controller implements the logic to deals with objects via objectcontroller and cellControllerfactory.
   It will gives all the basic logic for live update from documents/view creation and reusing, controller creation/reusing
   and manage the cell controller flags/selection/remove, ...
 
   By derivating this controller, you'll just have to implement the UIKit specific delegates and view creation and redirect
   to the basic implementation of CKCollectionViewController
 
   By this way we centralize all the document/cellcontroller logic that is redondant in this class
 
   For some specific implementations see : CKTableCollectionViewController, CKCarouselCollectionViewController and CKMapCollectionViewController
 
  *  derivating this controller means
 
   you MUST implement :
 
 - (UIView*)viewAtIndexPath:(NSIndexPath *)indexPath
 - (NSIndexPath*)indexPathForView:(UIView*)view
 - (UIView*)dequeueReusableViewWithIdentifier:(NSString*)identifier
 
   you SHOULD implement :
 
 - (void)didReload
 - (void)didBeginUpdates
 - (void)didEndUpdates
 - (void)didInsertObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths
 - (void)didRemoveObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths
*/


/** TODO
 */
@interface CKCollectionViewController : CKViewController<CKObjectControllerDelegate>
@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) int minimumNumberOfSupplementaryObjectsInSections;

@property (nonatomic, assign, readonly, getter = isRotating) BOOL rotating;

//init
- (id)initWithCollection:(CKCollection*)collection factory:(CKCollectionCellControllerFactory*)factory;

//setup at runtime
- (void)setupWithCollection:(CKCollection*)collection factory:(CKCollectionCellControllerFactory*)factory;

//view / cell controller management
- (CKCollectionCellController*)controllerAtIndexPath:(NSIndexPath *)indexPath;
- (UIView*)viewAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath*)indexPathForView:(UIView*)view;
- (NSArray*)visibleIndexPaths;
- (UIView*)createViewAtIndexPath:(NSIndexPath*)indexPath;
- (UIView*)dequeueReusableViewWithIdentifier:(NSString*)identifier;
- (BOOL)isValidIndexPath:(NSIndexPath*)indexPath;

//document objects management
- (id)objectAtIndexPath:(NSIndexPath*)indexPath;
- (NSArray*)objectsForSection:(NSInteger)section;
- (NSInteger)indexOfObject:(id)object inSection:(NSInteger)section;
- (NSIndexPath*)indexPathForObject:(id)object;

//content management
- (NSInteger)numberOfSections;
- (NSInteger)numberOfObjectsForSection:(NSInteger)section;

- (void)fetchObjectsInRange:(NSRange)range  forSection:(NSInteger)section;
- (void)fetchMoreData;
- (void)fetchMoreIfNeededFromIndexPath:(NSIndexPath*)indexPath;

//items controller interactions
- (CGSize)sizeForViewAtIndexPath:(NSIndexPath *)indexPath;
- (CKItemViewFlags)flagsForViewAtIndexPath:(NSIndexPath*)indexPath;

- (BOOL)willSelectViewAtIndexPath:(NSIndexPath *)indexPath;
- (void)didSelectViewAtIndexPath:(NSIndexPath *)indexPath;
- (void)didSelectAccessoryViewAtIndexPath:(NSIndexPath *)indexPath;

- (BOOL)isViewEditableAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)isViewMovableAtIndexPath:(NSIndexPath *)indexPath;

//Collection View Delegate Methods
- (void)didRemoveViewAtIndexPath:(NSIndexPath*)indexPath;
- (void)didMoveViewAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;
- (NSIndexPath*)targetIndexPathForMoveFromIndexPath:(NSIndexPath*)sourceIndexPath toProposedIndexPath:(NSIndexPath*)proposedDestinationIndexPath;

//Object Controller update callbacks
- (void)didReload;
- (void)didBeginUpdates;
- (void)didEndUpdates;
- (void)didInsertObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths;
- (void)didRemoveObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths;
- (void)didInsertSectionAtIndex:(NSInteger)index;
- (void)didRemoveSectionAtIndex:(NSInteger)index;

- (void)updateSizeForControllerAtIndexPath:(NSIndexPath*)index;

- (void)reload;

@end



/** TODO
 */
@protocol CKCollectionViewControllerDelegate
@optional
- (void)collectionViewController:(CKCollectionViewController*)controller didSelectViewAtIndexPath:(NSIndexPath*)indexPath withObject:(id)object;
- (void)collectionViewController:(CKCollectionViewController*)controller didSelectAccessoryViewAtIndexPath:(NSIndexPath*)indexPath withObject:(id)object;
@end