//
//  CKReusableViewController.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-10-23.
//  Copyright (c) 2013 Sebastien Morel. All rights reserved.
//

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

/** The collection view
 
    UITableView,
    UICollectionView,
    MKMapView
 */
@property(nonatomic,readonly) UIView* contentView;


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


/** This method is called after the cell accessory view has been selected
 */
- (void)didSelectAccessory;

/**
 */
@property(nonatomic,copy) void(^didSelectAccessoryBlock)(CKReusableViewController* controller);


/** This method is called after the cell has been selected
 */
- (void)didDeselect;

/**
 */
@property(nonatomic,copy) void(^didDeselectBlock)(CKReusableViewController* controller);

/** This method is called after the cell has been removec
 */
- (void)didRemove;

/**
 */
@property(nonatomic,copy) void(^didRemoveBlock)(CKReusableViewController* controller);


/** This method is called after the cell has been highlighted
 */
- (void)didHighlight;

/**
 */
@property(nonatomic,copy) void(^didHighlightBlock)(CKReusableViewController* controller);

/** This method is called after the cell has been unhighlighted
 */
- (void)didUnhighlight;

/**
 */
@property(nonatomic,copy) void(^didUnhighlightBlock)(CKReusableViewController* controller);



/** Ensure you call the super implementation !
 */
- (void)prepareForReuseUsingContentView:(UIView*)contentView contentViewCell:(UIView*)contentViewCell;

/**
 */
- (NSString*)reuseIdentifier;



/** The IndexPath of the reusable view controller in section container
 */
@property(nonatomic,readonly) NSIndexPath* indexPath;

/** Returns YES if the reusable view controller is a header controller in a section
 */
@property(nonatomic,readonly) BOOL isHeaderViewController;

/** Returns YES if the reusable view controller is a footer controller in a section
 */
@property(nonatomic,readonly) BOOL isFooterViewController;






/** Default is 320,44
 */
@property(nonatomic,assign) CGSize estimatedSize;


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


/**
 */
@interface NSIndexPath(CKReusableViewController)

/**
 */
+ (NSIndexPath*)indexPathForHeaderInSection:(NSInteger)section;

/**
 */
- (BOOL)isSectionHeaderIndexPath;

/**
 */
+ (NSIndexPath*)indexPathForFooterInSection:(NSInteger)section;

/**
 */
- (BOOL)isSectionFooterIndexPath;

@end


#import "CKReusableViewController+ResponderChain.h"
