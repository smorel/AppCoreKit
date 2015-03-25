//
//  CKCollectionController.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKObjectController.h"
#import "CKCollection.h"


/** @see CKObjectController, CKObjectControllerDelegate
 */
@interface CKCollectionController : NSObject<CKObjectController> 

///-----------------------------------
/// @name Creating an initialized CKCollectionController Object
///-----------------------------------

/**
 */
+ (CKCollectionController*) controllerWithCollection:(CKCollection*)collection;

///-----------------------------------
/// @name Initializing a CKCollectionController Object
///-----------------------------------

/**
 */
- (id)initWithCollection:(CKCollection*)collection;

///-----------------------------------
/// @name Managing the delegate
///-----------------------------------

/** CKObjectControllerDelegate (Usually a CKCollectionViewControllerOld)
 */
@property (nonatomic, assign) id delegate;

///-----------------------------------
/// @name Getting the collection
///-----------------------------------

/**
 */
@property (nonatomic, retain,readonly) CKCollection* collection;


///-----------------------------------
/// @name Customizing the model representation
///-----------------------------------

/**
 */
@property (nonatomic, assign) BOOL appendSpinnerAsFooterCell;

/**
 */
@property (nonatomic, assign) NSInteger maximumNumberOfObjectsToDisplay;

@end
