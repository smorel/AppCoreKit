//
//  CKFeedViewControllerProtocol.h
//  FeedView
//
//  Created by Sebastien Morel on 11-03-16.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CKObjectController 
@optional

//Sections
- (NSInteger)numberOfSections;
- (NSInteger)numberOfObjectsForSection:(NSInteger)section;

- (NSString*)headerTitleForSection:(NSInteger)section;
- (UIView*)headerViewForSection:(NSInteger)section;

//Objects Management
- (id)objectAtIndexPath:(NSIndexPath *)indexPath;

//remove
- (void)removeObjectAtIndexPath:(NSIndexPath *)indexPath;

//Move
- (NSIndexPath*)targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath;
- (void)moveObjectFromIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)indexPath;

//Fetch
- (void)fetchRange:(NSRange)range forSection:(int)section;

- (void)setDelegate:(id)delegate;//CKObjectControllerDelegate

//For multithreading purpose all incoming event while locked should be ignored !!!
- (void)lock;
- (void)unlock;

@end


@protocol CKObjectControllerDelegate

- (void)objectControllerReloadData:(id)controller;
- (void)objectControllerDidBeginUpdating:(id)controller;
- (void)objectControllerDidEndUpdating:(id)controller;  
- (void)objectController:(id)controller insertObject:(id)object atIndexPath:(NSIndexPath*)indexPath;
- (void)objectController:(id)controller removeObject:(id)object atIndexPath:(NSIndexPath*)indexPath;
- (void)objectController:(id)controller insertObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths;
- (void)objectController:(id)controller removeObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths;
- (void)objectController:(id)controller insertSectionAtIndex:(NSInteger)index;
- (void)objectController:(id)controller removeSectionAtIndex:(NSInteger)index;

@end