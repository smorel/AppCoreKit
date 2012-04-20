//
//  CKBasicCellController.h
//  CloudKit
//
//  Created by Olivier Collet on 09-12-15.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKItemViewController.h"
#import "CKTableViewController.h"
#import "CKObject.h"
#import "CKCallback.h"
#import "CKWeakRef.h"

/********************************************** CKUITableViewCell *************************************/

@class CKBindedTableViewController;
@class CKTableViewCellController;
@class CKTableViewController;

/** TODO
 */
@interface CKUITableViewCell : UITableViewCell

///-----------------------------------
/// @name Managing CellController Connection
///-----------------------------------

@property(nonatomic,readonly) CKTableViewCellController* delegate;

///-----------------------------------
/// @name Customizing the View Visual Appearance
///-----------------------------------

@property(nonatomic,retain) UIImage*   disclosureIndicatorImage;
@property(nonatomic,retain) UIImage*   checkMarkImage;
@property(nonatomic,retain) UIImage*   highlightedDisclosureIndicatorImage;
@property(nonatomic,retain) UIImage*   highlightedCheckMarkImage;
@property(nonatomic,retain) UIButton*  disclosureButton;


///-----------------------------------
/// @name Initializing a CKUITableViewCell instance
///-----------------------------------

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier delegate:(CKTableViewCellController*)delegate;

@end



/********************************************** CKTableViewCellController *************************************/

/** TODO
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


/** TODO
 */
typedef enum CKTableViewCellStyle {
    CKTableViewCellStyleDefault = UITableViewCellStyleDefault,	
    CKTableViewCellStyleValue1 = UITableViewCellStyleValue1,		
    CKTableViewCellStyleValue2 = UITableViewCellStyleValue2,		
    CKTableViewCellStyleSubtitle = UITableViewCellStyleSubtitle,
    
	CKTableViewCellStyleValue3,
	CKTableViewCellStylePropertyGrid,
	CKTableViewCellStyleSubtitle2
} CKTableViewCellStyle;           


/** TODO
 */
@interface CKTableViewCellController : CKItemViewController

+ (CKTableViewCellController*)cellController;

@property (nonatomic, assign) CKTableViewCellStyle cellStyle;
@property (nonatomic, assign) NSInteger indentationLevel;

@property (nonatomic, retain) NSString* text;
@property (nonatomic, retain) NSString* detailText;
@property (nonatomic, retain) UIImage*  image;
@property (nonatomic) UITableViewCellAccessoryType   accessoryType;
@property (nonatomic,retain) UIView                 *accessoryView;
@property (nonatomic) UITableViewCellAccessoryType   editingAccessoryType;
@property (nonatomic,retain) UIView                 *editingAccessoryView;
@property (nonatomic) UITableViewCellSelectionStyle  selectionStyle;

@property (nonatomic, readonly) UITableViewCell *tableViewCell;
- (CKTableViewController*)parentTableViewController;
- (UITableView*)parentTableView;

- (void)initTableViewCell:(UITableViewCell*)cell;
- (void)setupCell:(UITableViewCell *)cell;
- (void)rotateCell:(UITableViewCell*)cell animated:(BOOL)animated;
- (void)layoutCell:(UITableViewCell*)cell;

- (void)cellDidAppear:(UITableViewCell *)cell;
- (void)cellDidDisappear;

- (NSIndexPath *)willSelectRow;
- (void)didSelectRow;

- (void)scrollToRow;
- (void)scrollToRowAfterDelay:(NSTimeInterval)delay;

//PRIVATE
@property (nonatomic, assign) BOOL sizeHasBeenQueriedByTableView;
- (void)onValueChanged;

@end


#import "CKTableViewCellController+CKBlockBasedInterface.h"
#import "CKTableViewCellController+CKDynamicLayout.h"
#import "CKTableViewCellController+Responder.h"
#import "CKTableViewCellController+PropertyGrid.h"
#import "CKTableViewCellController+Menus.h"
