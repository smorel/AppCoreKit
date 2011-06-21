//
//  CKBasicCellController.h
//  CloudKit
//
//  Created by Olivier Collet on 09-12-15.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import "CKItemViewController.h"
#import "CKManagedTableViewController.h"
#import "CKModelObject.h"
#import "CKNSDictionary+TableViewAttributes.h"
#import "CKCallback.h"

enum{
	CKTableViewCellFlagNone = CKItemViewFlagNone,
	CKTableViewCellFlagSelectable = CKItemViewFlagSelectable,
	CKTableViewCellFlagEditable = CKItemViewFlagEditable,
	CKTableViewCellFlagRemovable = CKItemViewFlagRemovable,
	CKTableViewCellFlagMovable = CKItemViewFlagMovable,
	CKTableViewCellFlagAll = CKItemViewFlagAll
};
typedef NSUInteger CKTableViewCellFlags;


typedef enum CKTableViewCellStyle {
    CKTableViewCellStyleDefault = UITableViewCellStyleDefault,	
    CKTableViewCellStyleValue1 = UITableViewCellStyleValue1,		
    CKTableViewCellStyleValue2 = UITableViewCellStyleValue2,		
    CKTableViewCellStyleSubtitle = UITableViewCellStyleSubtitle,
	CKTableViewCellStyleValue3
} CKTableViewCellStyle;             

@interface CKTableViewCellController : CKItemViewController {
	UITableViewCellAccessoryType _accessoryType;
	CKTableViewCellStyle _cellStyle;
	
	NSString* _key;
	CGFloat _value3Ratio;
	CGFloat _value3LabelsSpace;
	
	
#ifdef DEBUG 
	id debugModalController;
#endif
}

@property (nonatomic, readonly) UITableViewCell *tableViewCell;
@property (nonatomic, assign) CKTableViewCellStyle cellStyle;
@property (assign, readwrite) UITableViewCellAccessoryType accessoryType;
@property (nonatomic, retain) NSString* key;

@property (nonatomic, assign) CGFloat value3Ratio;
@property (nonatomic, assign) CGFloat value3LabelsSpace;

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

+ (BOOL)hasAccessoryResponderWithValue:(id)object;
+ (UIResponder*)responderInView:(UIView*)view;

- (void)layoutCell:(UITableViewCell *)cell;

- (CKTableViewController*)parentTableViewController;
- (UITableView*)parentTableView;

- (CGRect)value3FrameForCell:(UITableViewCell*)cell;

@end
