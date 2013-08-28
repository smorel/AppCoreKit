//
//  CKTableViewCellController.h
//  AppCoreKit
//
//  Created by Olivier Collet.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKCollectionCellController.h"
#import "CKTableViewController.h"
#import "CKObject.h"
#import "CKCallback.h"
#import "CKWeakRef.h"

/********************************************** CKUITableViewCell *************************************/

@class CKTableCollectionViewController;
@class CKTableViewCellController;
@class CKTableViewController;

/**
 */
@interface CKUITableViewCell : UITableViewCell


///-----------------------------------
/// @name Initializing a CKUITableViewCell instance
///-----------------------------------

/**
 */
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier delegate:(CKTableViewCellController*)delegate;


///-----------------------------------
/// @name Managing the delegate
///-----------------------------------

/**
 */
@property(nonatomic,readonly) CKTableViewCellController* delegate;

///-----------------------------------
/// @name Getting the TableViewCell status
///-----------------------------------

/**
 */
@property(nonatomic, assign) UITableViewCellStateMask editingMask;

///-----------------------------------
/// @name Customizing the Appearance
///-----------------------------------

/**
 */
@property(nonatomic,retain) UIImage*   disclosureIndicatorImage;

/**
 */
@property(nonatomic,retain) UIImage*   checkMarkImage;

/**
 */
@property(nonatomic,retain) UIImage*   highlightedDisclosureIndicatorImage;

/**
 */
@property(nonatomic,retain) UIImage*   highlightedCheckMarkImage;

/**
 */
@property(nonatomic,retain) UIButton*  disclosureButton;

///-----------------------------------
/// @name Accessing The Layout Prefered Height
///-----------------------------------

/** Return the contentView Layout prefered height for the specified width
 Return MAXFLOAT in case no layout applies to the contentView.
 //This allow to compute the prefered height of the row when the parent table view is in portrait orientation
 */
- (CGFloat)preferedHeightConstraintToWidth:(CGFloat)width;

/** Return the contentView Layout prefered height for the specified width
 Return MAXFLOAT in case no layout applies to the contentView.
 //This allow to compute the prefered width of the row when the parent table view is in portrait landscape
 */
- (CGFloat)preferedWidthConstraintToHeight:(CGFloat)height;

@end



/********************************************** CKTableViewCellController *************************************/

/**
 */
enum{
	CKTableViewCellFlagNone = CKItemViewFlagNone,
	CKTableViewCellFlagSelectable = CKItemViewFlagSelectable,
	CKTableViewCellFlagEditable = CKItemViewFlagEditable,
	CKTableViewCellFlagRemovable = CKItemViewFlagRemovable,
	CKTableViewCellFlagMovable = CKItemViewFlagMovable,
	CKTableViewCellFlagAll = CKItemViewFlagAll
};
typedef NSUInteger CKTableViewCellFlags;


/**
 */
typedef enum CKTableViewCellStyle {
    CKTableViewCellStyleDefault = UITableViewCellStyleDefault,	
    CKTableViewCellStyleValue1 = UITableViewCellStyleValue1,		
    CKTableViewCellStyleValue2 = UITableViewCellStyleValue2,		
    CKTableViewCellStyleSubtitle = UITableViewCellStyleSubtitle,
    
	CKTableViewCellStyleIPadForm,
	CKTableViewCellStyleIPhoneForm,
	CKTableViewCellStyleSubtitle2,
    
	CKTableViewCellStyleCustomLayout
} CKTableViewCellStyle;           


typedef CGSize(^CKTableViewCellControllerSizeBlock)(CKTableViewCellController* controller);

/**
 */
@interface CKTableViewCellController : CKCollectionCellController

///-----------------------------------
/// @name Creating TableView Cell Controller Objects
///-----------------------------------

/**
 */
+ (id)cellController;

/**
 */
+ (id)cellControllerWithName:(NSString*)name;

///-----------------------------------
/// @name Customizing the appearance
///-----------------------------------

/**
 */
@property (nonatomic, assign) CKTableViewCellStyle cellStyle;

/**
 */
@property (nonatomic, assign) NSInteger indentationLevel;

/**
 */
@property (nonatomic) UITableViewCellSelectionStyle  selectionStyle;

/**
 */
@property (nonatomic) UITableViewCellAccessoryType   accessoryType;

/**
 */
@property (nonatomic,retain) UIView                 *accessoryView;

/**
 */
@property (nonatomic) UITableViewCellAccessoryType   editingAccessoryType;

/**
 */
@property (nonatomic,retain) UIView                 *editingAccessoryView;

/**
 */
@property (nonatomic, assign) CGFloat componentsRatio;

/**
 */
@property (nonatomic, assign) CGFloat horizontalSpace;
/**
 */
@property (nonatomic, assign) CGFloat verticalSpace;

/**
 */
@property (nonatomic, assign) UIEdgeInsets contentInsets;

///-----------------------------------
/// @name Accessing the content
///-----------------------------------

/**
 */
@property (nonatomic, retain) NSString* text;

/**
 */
@property (nonatomic, retain) NSString* detailText;

/**
 */
@property (nonatomic, retain) UIImage*  image;

///-----------------------------------
/// @name Getting the Table View Cell
///-----------------------------------

/** tableViewCell is a weak reference to the view currently associated to this controller.
    As tableViewCell are reused, this property will be null when the controller is not displayed on screen.
    Do not keep any other reference between the tableViewCell and the controller to avoid problem with the reuse system.
 */
@property (nonatomic, readonly) UITableViewCell *tableViewCell;


///-----------------------------------
/// @name Getting the Parent TableView Controller and Table View
///-----------------------------------

/**
 */
- (CKTableViewController*)parentTableViewController;

/**
 */
- (UITableView*)parentTableView;

///-----------------------------------
/// @name Customizing the controller behaviour
///-----------------------------------

/**
 */
- (void)initTableViewCell:(UITableViewCell*)cell;
/**
 */
- (void)setupCell:(UITableViewCell *)cell;
/**
 */
- (void)rotateCell:(UITableViewCell*)cell animated:(BOOL)animated;
/**
 */
- (void)layoutCell:(UITableViewCell*)cell;

/**
 */
- (void)cellDidAppear:(UITableViewCell *)cell;

/**
 */
- (void)cellDidDisappear;

/**
 */
- (NSIndexPath *)willSelectRow;

/**
 */
- (void)didSelectRow;

///-----------------------------------
/// @name Scrolling
///-----------------------------------

/**
 */
- (void)scrollToRow;

/**
 */
- (void)scrollToRowAfterDelay:(NSTimeInterval)delay;


///-----------------------------------
/// @name Layouting
///-----------------------------------

/**
 */
@property (nonatomic,copy) CKTableViewCellControllerSizeBlock sizeBlock;


@end



/**
 */
@interface CKTableViewCellController(CKLayout)

///-----------------------------------
/// @name Layouting
///-----------------------------------

/**
 */
- (void)performLayout;

@end


#import "CKTableViewCellController+BlockBasedInterface.h"
#import "CKTableViewCellController+Responder.h"
#import "CKTableViewCellController+PropertyGrid.h"
#import "CKTableViewCellController+Menus.h"
