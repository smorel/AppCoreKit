//
//  CKTableViewCellController+CKDynamicLayout.h
//  CloudKit
//
//  Created by Sebastien Morel on 12-04-17.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKTableViewCellController.h"

@interface CKTableViewCellController (CKDynamicLayout)

@property (nonatomic, assign) CGFloat componentsRatio;
@property (nonatomic, assign) CGFloat componentsSpace;
@property (nonatomic, assign) UIEdgeInsets contentInsets;

- (void)performLayout;
- (void)invalidateSize;
- (CGSize)computeSize;

- (CGRect)value3TextFrameForCell:(UITableViewCell*)cell;
- (CGRect)value3DetailFrameForCell:(UITableViewCell*)cell;

- (CGRect)propertyGridTextFrameForCell:(UITableViewCell*)cell;
- (CGRect)propertyGridDetailFrameForCell:(UITableViewCell*)cell;

//Retrieving Data to compute cell height wether or not the tableViewCell exists
//It will query the stylesheets if the view do not exists when getting the value.

- (UIFont*)fontForViewWithKeyPath:(NSString*)keyPath;

- (UIFont*)textLabelFont;
- (UIFont*)detailTextLabelFont;
- (CGFloat)contentViewWidth;

@end
