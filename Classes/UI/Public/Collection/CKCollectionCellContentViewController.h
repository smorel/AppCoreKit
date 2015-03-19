//
//  CKCollectionCellContentViewController.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-10-23.
//  Copyright (c) 2013 Sebastien Morel. All rights reserved.
//

#import "CKCollectionViewController.h"

#import "NSObject+Bindings.h"
#import "Layout.h"
#import "UIView+Name.h"



typedef NS_ENUM(NSInteger,CKViewControllerFlags){
    CKViewControllerFlagsNone = 1UL << 0,
    CKViewControllerFlagsSelectable = 1UL << 1,
    CKViewControllerFlagsEditable = 1UL << 2,
    CKViewControllerFlagsRemovable = 1UL << 3,
    CKViewControllerFlagsMovable = 1UL << 4,
    CKViewControllerFlagsAll = CKViewControllerFlagsSelectable | CKViewControllerFlagsEditable | CKViewControllerFlagsRemovable | CKViewControllerFlagsMovable
};


/**
 */
@interface CKCollectionCellContentViewController : UIViewController


/** The CKCollectionViewController managing the collection of CKCollectionCellController and the collectionView
 
    CKTableViewControllerOld,
    CKTableCollectionViewViewController, 
    CKFormTableViewController , 
    CKCarouselCollectionViewController, 
    CKGridCollectionViewController, 
    CKMapCollectionViewController,
    CKCollectionViewLayoutController
 */
@property(nonatomic,readonly) CKViewController* collectionViewController;


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
    MKMapAnnotationView,
    UITableViewHeaderFooterView
 */
@property(nonatomic,readonly) UIView* contentViewCell;



/** The Model Represented by the collectionCellController
 */
@property(nonatomic,readonly) id value;

/** The IndexPath of the collectionCellController
 */
@property(nonatomic,readonly) NSIndexPath* indexPath;

/** default value is selectable
 */
@property(nonatomic,assign) CKViewControllerFlags flags;


/** default value is selectable
 */
@property(nonatomic,assign) CKViewControllerState state;

/** Identifying the controller by a name
 */
@property(nonatomic,readonly) NSString* name;

/**
 */
- (NSString*)reuseIdentifier;

/** Default is 44
 */
@property(nonatomic,assign) CGFloat estimatedRowHeight;

/** Ensure you call the super implementation !
 */
- (void)prepareForReuseUsingContentView:(UIView*)contentView contentViewCell:(UIView*)contentViewCell;

/**
 */
- (CGSize)preferredSizeConstraintToSize:(CGSize)size;

/** The postInit method mimics the postInit method from CKViewController. It will be called after the content view controller has been inserted in a cell controller so that we can custom the parent cell controller if needed.
 */
- (void)postInit;

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

/**
 */
- (void)scrollToCell;

/**
 */
- (UINavigationController*)navigationController;

/**
 */
@property(nonatomic,copy) void(^didSelectBlock)();


/** The accessoryType when the CKStandardContentViewController is presented in a table view.
 Default value is UITableViewCellAccessoryNone
 */
@property(nonatomic,assign) UITableViewCellAccessoryType accessoryType;

@end
