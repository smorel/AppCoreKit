//
//  CKManagedTableViewController.h
//  Urbanizer
//
//  Created by Olivier Collet on 10-03-02.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKTableViewController.h"

@class CKTableViewCellController;

@interface CKTableSection : NSObject {
	NSMutableArray *_cellControllers;
	NSString *_headerTitle;
	NSString *_footerTitle;
	UIView *_headerView;
	UIView *_footerView;
}

@property (nonatomic, retain, readonly) NSArray *cellControllers;
@property (nonatomic, retain, readwrite) NSString *headerTitle;
@property (nonatomic, retain, readwrite) NSString *footerTitle;
@property (nonatomic, retain, readwrite) UIView *headerView;
@property (nonatomic, retain, readwrite) UIView *footerView;

- (id)initWithCellControllers:(NSArray *)cellControllers;

@end

//

@interface CKManagedTableViewController : CKTableViewController <UIScrollViewDelegate> {
	NSMutableArray *_sections;
}

- (void)setup;
- (void)clear;
- (void)reload;

// Cell Controllers Management

- (void)addSection:(CKTableSection *)section;
- (void)addSectionWithCellControllers:(NSArray *)cellControllers;
- (void)addSectionWithCellControllers:(NSArray *)cellControllers headerTitle:(NSString *)headerTitle footerTitle:(NSString *)footerTitle;

@end
