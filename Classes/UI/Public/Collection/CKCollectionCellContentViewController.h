//
//  CKCollectionCellContentViewController.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-10-23.
//  Copyright (c) 2013 Sebastien Morel. All rights reserved.
//

#import "CKCollectionViewController.h"

/**
 */
@interface CKCollectionCellContentViewController : UIViewController


/** The CKCollectionViewController managing the collection of CKCollectionCellController and the collectionView
 
    CKTableViewController,
    CKTableCollectionViewViewController, 
    CKFormTableViewController , 
    CKCarouselCollectionViewController, 
    CKGridCollectionViewController, 
    CKMapCollectionViewController,
    CKCollectionViewLayoutController
 */
@property(nonatomic,readonly) CKCollectionViewController* collectionViewController;


/** The collection view
 
    UITableView,
    UICollectionView,
    MKMapView
 */
@property(nonatomic,readonly) UIView* contentView;


/** The collectionCellController That will manage CKCollectionCellContentViewController appearance and reuse
 
    CKCollectionCellController,
    CKTableViewCellController, 
    CKMapAnnotationController
 */
@property(nonatomic,readonly) CKCollectionCellController* collectionCellController;


/** The reusable collection view currently associated to the collectionCellController
 
    UITableViewCell,
    UICollectionViewCell, 
    MKMapAnnotationView
 */
@property(nonatomic,readonly) UIView* contentViewCell;



/** The Model Represented by the collectionCellController
 */
@property(nonatomic,readonly) id value;

/** The IndexPath of the collectionCellController
 */
@property(nonatomic,readonly) NSIndexPath* indexPath;

/** Identifying the controller by a name
 */
@property(nonatomic,readonly) NSString* name;

/**
 */
- (NSString*)reuseIdentifier;

/** Ensure you call the super implementation !
 */
- (void)prepareForReuseUsingContentView:(UIView*)contentView contentViewCell:(UIView*)contentViewCell;

/**
 */
- (CGSize)preferredSizeConstraintToSize:(CGSize)size;

/** This method is called after the cell has been selected
 */
- (void)didSelect;

/** return YES if you manage the update of your models or NO if you want the system to remove the cell from the contentView.
 */
- (BOOL)didRemove;

/**
 */
- (void)didBecomeFirstResponder;

/**
 */
- (void)didResignFirstResponder;

@end
