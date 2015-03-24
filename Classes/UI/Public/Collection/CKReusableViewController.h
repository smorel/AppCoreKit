//
//  CKReusableViewController.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-10-23.
//  Copyright (c) 2013 Sebastien Morel. All rights reserved.
//

#import "CKCollectionViewController.h"

#import "NSObject+Bindings.h"
#import "Layout.h"
#import "UIView+Name.h"
#import "UIViewController+Style.h"
#import "CKViewController.h"



typedef NS_ENUM(NSInteger,CKViewControllerFlags){
    CKViewControllerFlagsNone = 1UL << 0,
    CKViewControllerFlagsSelectable = 1UL << 1,
    CKViewControllerFlagsRemovable = 1UL << 3,
    CKViewControllerFlagsAll = CKViewControllerFlagsSelectable  | CKViewControllerFlagsRemovable
};

typedef NS_ENUM(NSInteger,CKAccessoryType){
    CKAccessoryNone = UITableViewCellAccessoryNone,
    CKAccessoryDisclosureIndicator = UITableViewCellAccessoryDisclosureIndicator,
    CKAccessoryDetailDisclosureButton = UITableViewCellAccessoryDetailDisclosureButton,
    CKAccessoryCheckmark = UITableViewCellAccessoryCheckmark,
    CKAccessoryDetailButton = UITableViewCellAccessoryDetailButton,
    CKAccessoryActivityIndicator
};


/**
 */
@interface CKReusableViewController : UIViewController

/**
 */
- (void)postInit;

/**
 */
- (UINavigationController*)navigationController;

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


/** The collectionCellController That will manage CKReusableViewController appearance and reuse
 
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






/** default value is selectable
 */
@property(nonatomic,assign) CKViewControllerFlags flags;

/** This method is called after the cell has been selected
 */
- (void)didSelect;

/**
 */
@property(nonatomic,copy) void(^didSelectBlock)(CKReusableViewController* controller);

/** This method is called after the cell has been removec
 */
- (void)didRemove;

/**
 */
@property(nonatomic,copy) void(^didRemoveBlock)(CKReusableViewController* controller);





/** Ensure you call the super implementation !
 */
- (void)prepareForReuseUsingContentView:(UIView*)contentView contentViewCell:(UIView*)contentViewCell;

/**
 */
- (NSString*)reuseIdentifier;

/** The IndexPath of the collectionCellController
 */
@property(nonatomic,readonly) NSIndexPath* indexPath;







/** Default is 44
 */
@property(nonatomic,assign) CGFloat estimatedRowHeight;


/**
 */
- (CGSize)preferredSizeConstraintToSize:(CGSize)size;





/**
 */
- (void)scrollToCell;



/** The accessoryType when the CKStandardContentViewController is presented in a table view.
 Default value is UITableViewCellAccessoryNone
 */
@property(nonatomic,assign) CKAccessoryType accessoryType;

/** This method will be called by the container view controller if the separators or corners needs to be updated after some controllers have been removed/added in sections.
 */
- (void)setNeedsDisplay;

@end


#import "CKReusableViewController+ResponderChain.h"
