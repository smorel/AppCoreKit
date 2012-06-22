//
//  CKTableViewCellController+CKDynamicLayout.h
//  CloudKit
//
//  Created by Sebastien Morel on 12-04-17.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKTableViewCellController.h"

@interface CKTableViewCellController (CKDynamicLayout)

@property (nonatomic, retain) NSMutableDictionary* textLabelStyle;
@property (nonatomic, retain) NSMutableDictionary* detailTextLabelStyle;

@property (nonatomic, assign) BOOL isInSetup;

@property (nonatomic, assign) CKTableViewCellController* parentCellController;//In case of grids, ...

extern NSString* CKDynamicLayoutTextAlignment;
extern NSString* CKDynamicLayoutFont;
extern NSString* CKDynamicLayoutNumberOfLines;
extern NSString* CKDynamicLayoutLineBreakMode;

@property (nonatomic, assign) BOOL invalidatedSize;

@property (nonatomic, assign) BOOL sizeHasBeenQueriedByTableView;
- (void)onValueChanged;

- (CGSize)computeSize;

+ (CGFloat)computeTableViewCellViewSizeUsingTableView:(UITableView*)tableView;
+ (CGFloat)computeTableViewCellMarginUsingTableView:(UITableView*)tableView;

- (CGFloat)computeContentViewSize;
- (CGFloat)computeContentViewSizeForSubCellController;

- (CGSize)sizeForText:(NSString*)text withStyle:(NSDictionary*)style constraintToWidth:(CGFloat)width;

- (CGSize)computeSizeUsingText:(NSString*)text detailText:(NSString*)detailText image:(UIImage*)image;

- (CGRect)value3TextFrameUsingText:(NSString*)text textStyle:(NSDictionary*)textStyle detailText:(NSString*)detailText detailTextStyle:(NSDictionary*)detailTextStyle image:(UIImage*)image;
- (CGRect)value3DetailFrameUsingText:(NSString*)text textStyle:(NSDictionary*)textStyle detailText:(NSString*)detailText detailTextStyle:(NSDictionary*)detailTextStyle image:(UIImage*)image;

- (CGRect)propertyGridTextFrameUsingText:(NSString*)text textStyle:(NSDictionary*)textStyle detailText:(NSString*)detailText detailTextStyle:(NSDictionary*)detailTextStyle image:(UIImage*)image;
- (CGRect)propertyGridDetailFrameUsingText:(NSString*)text textStyle:(NSDictionary*)textStyle detailText:(NSString*)detailText detailTextStyle:(NSDictionary*)detailTextStyle image:(UIImage*)image;

- (CGRect)subtitleTextFrameUsingText:(NSString*)text textStyle:(NSDictionary*)textStyle detailText:(NSString*)detailText detailTextStyle:(NSDictionary*)detailTextStyle image:(UIImage*)image;
- (CGRect)subtitleDetailFrameUsingText:(NSString*)text textStyle:(NSDictionary*)textStyle detailText:(NSString*)detailText detailTextStyle:(NSDictionary*)detailTextStyle image:(UIImage*)image textFrame:(CGRect)textFrame;

//Retrieving Data to compute cell height wether or not the tableViewCell exists
//It will query the stylesheets if the view do not exists when getting the value.

- (NSMutableDictionary*)styleForViewWithKeyPath:(NSString*)keyPath defaultStyle:(NSDictionary*)defaultStyle;

- (NSDictionary*)textStyle;
- (NSDictionary*)detailTextStyle;

- (CGFloat)tableViewCellWidth;
- (CGFloat)contentViewWidth;
- (CGFloat)accessoryWidth;
- (CGFloat)editingWidth;

@end
