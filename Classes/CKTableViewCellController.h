//
//  CKBasicCellController.h
//  CloudKit
//
//  Created by Olivier Collet on 09-12-15.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKItemViewController.h"
#import "CKManagedTableViewController.h"
#import "CKModelObject.h"
#import "CKNSDictionary+TableViewAttributes.h"
#import "CKCallback.h"

@class CKObjectTableViewController;


/** TODO
 */
@interface CKUITableViewCell : UITableViewCell

@property(nonatomic,assign) CKTableViewCellController* delegate;
@property(nonatomic,retain) UIImage* disclosureIndicatorImage;//can be customized via stylesheets
@property(nonatomic,retain) UIImage* checkMarkImage;//can be customized via stylesheets
@property(nonatomic,retain) UIButton* disclosureButton;//can be customized via stylesheets

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier delegate:(CKTableViewCellController*)delegate;

@end





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
	CKTableViewCellStylePropertyGrid
} CKTableViewCellStyle;             

/** TODO
 */
@interface CKTableViewCellController : CKItemViewController {
	UITableViewCellAccessoryType _accessoryType;
	CKTableViewCellStyle _cellStyle;
	
	NSString* _key;
	CGFloat _componentsRatio;
	CGFloat _componentsSpace;
    UIEdgeInsets _contentInsets;
    
    NSString* _cacheLayoutBindingContextId;
	
#ifdef DEBUG 
	id debugModalController;
#endif
    
    //DEPRECATED 1.5
    CGFloat _rowHeight;
    BOOL _movable;
    BOOL _editable;
    BOOL _removable;
    BOOL _selectable;
}

@property (nonatomic, readonly) UITableViewCell *tableViewCell;
@property (nonatomic, assign) CKTableViewCellStyle cellStyle;
@property (assign, readwrite) UITableViewCellAccessoryType accessoryType;
@property (nonatomic, retain) NSString* key;

//for propertygrid and value3 only ...
@property (nonatomic, assign) CGFloat componentsRatio;
@property (nonatomic, assign) CGFloat componentsSpace;
@property (nonatomic, assign) UIEdgeInsets contentInsets;


- (UITableViewCell *)cellWithStyle:(CKTableViewCellStyle)style;

- (void)cellDidAppear:(UITableViewCell *)cell;
- (void)cellDidDisappear;

- (UITableViewCell *)loadCell;
- (void)setupCell:(UITableViewCell *)cell;
- (void)rotateCell:(UITableViewCell*)cell withParams:(NSDictionary*)params animated:(BOOL)animated;

- (NSIndexPath *)willSelectRow;
- (void)didSelectRow;

// Calls -setupCell with the cell associated with this controller.
// Does not call -setupCell if the cell is not visible.
- (void)setNeedsSetup;

//private
- (void)initTableViewCell:(UITableViewCell*)cell;
- (void)layoutCell:(UITableViewCell*)cell;

+ (BOOL)hasAccessoryResponderWithValue:(id)object;
+ (UIResponder*)responderInView:(UIView*)view;

- (CKTableViewController*)parentTableViewController;
- (UITableView*)parentTableView;

+ (NSValue*)viewSizeForObject:(id)object withParams:(NSDictionary*)params;
+ (CGFloat)contentViewWidthInParentController:(CKObjectTableViewController*)controller;

- (void)scrollToRow;
- (void)scrollToRowAfterDelay:(NSTimeInterval)delay;

@end

@interface CKTableViewCellController (DEPRECATED_IN_CLOUDKIT_VERSION_1_5_AND_LATER)

@property (nonatomic, getter = heightForRow) CGFloat rowHeight DEPRECATED_ATTRIBUTE;
@property (nonatomic, getter = isMovable) BOOL movable DEPRECATED_ATTRIBUTE;
@property (nonatomic, getter = isEditable) BOOL editable DEPRECATED_ATTRIBUTE;
@property (nonatomic, getter = isRemovable) BOOL removable DEPRECATED_ATTRIBUTE;
@property (nonatomic, getter = isSelectable) BOOL selectable DEPRECATED_ATTRIBUTE;

@property (nonatomic, assign) CGFloat value3Ratio DEPRECATED_ATTRIBUTE;
@property (nonatomic, assign) CGFloat value3LabelsSpace DEPRECATED_ATTRIBUTE;

- (CGFloat)heightForRow DEPRECATED_ATTRIBUTE;
- (BOOL)isMovable DEPRECATED_ATTRIBUTE;
- (BOOL)isEditable DEPRECATED_ATTRIBUTE;
- (BOOL)isRemovable DEPRECATED_ATTRIBUTE;
- (BOOL)isSelectable DEPRECATED_ATTRIBUTE;

@end






//FIXME use layout when available !

@interface CKTableViewCellController (CKLayout)

- (id)performStandardLayout:(CKTableViewCellController *)controller;

- (CGRect)value3TextFrameForCell:(UITableViewCell*)cell;
- (CGRect)value3DetailFrameForCell:(UITableViewCell*)cell;

- (CGRect)propertyGridTextFrameForCell:(UITableViewCell*)cell;
- (CGRect)propertyGridDetailFrameForCell:(UITableViewCell*)cell;

@end

