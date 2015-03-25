//
//  CKObjectController.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


/**
 */
@protocol CKObjectController 
@optional

///-----------------------------------
/// @name Managing the delegate
///-----------------------------------

/** CKObjectControllerDelegate (Usually a CKCollectionViewControllerOld)
 */
- (void)setDelegate:(id)delegate;


///-----------------------------------
/// @name Managing the Sections
///-----------------------------------

/**
 */
- (NSUInteger)numberOfSections;

/**
 */
- (NSUInteger)numberOfObjectsForSection:(NSInteger)section;

/**
 */
- (NSString*)headerTitleForSection:(NSInteger)section;

/**
 */
- (UIView*)headerViewForSection:(NSInteger)section;

/**
 */
- (NSString*)footerTitleForSection:(NSInteger)section;

/**
 */
- (UIView*)footerViewForSection:(NSInteger)section;

///-----------------------------------
/// @name Managing the Content
///-----------------------------------

/**
 */
- (id)objectAtIndexPath:(NSIndexPath *)indexPath;

/**
 */
- (void)removeObjectAtIndexPath:(NSIndexPath *)indexPath;

/**
 */
- (NSIndexPath*)targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath;

/**
 */
- (void)moveObjectFromIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)indexPath;

///-----------------------------------
/// @name Fetching More Content
///-----------------------------------

/**
 */
- (void)fetchRange:(NSRange)range forSection:(NSInteger)section;

//FIXME : this should stay private !!!
//For multithreading purpose all incoming event while locked should be ignored !!!
- (void)lock;
- (void)unlock;

@end


/**
 */
@protocol CKObjectControllerDelegate

///-----------------------------------
/// @name Notifying for document updates
///-----------------------------------

@optional

/** 
 */
- (void)objectControllerReloadData:(id)controller;

/** 
 */
- (void)objectControllerDidBeginUpdating:(id)controller;

/** 
 */
- (void)objectControllerDidEndUpdating:(id)controller;  

/** 
 */
- (void)objectController:(id)controller insertObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths;

/** 
 */
- (void)objectController:(id)controller removeObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths;

/** 
 */
- (void)objectController:(id)controller insertSectionAtIndex:(NSInteger)index;

/** 
 */
- (void)objectController:(id)controller removeSectionAtIndex:(NSInteger)index;

@end