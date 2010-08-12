//
//  CKManagedTableViewController.h
//  CloudKit
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
- (void)insertCellController:(CKTableViewCellController *)cellController atIndex:(NSUInteger)index;
- (void)removeCellControllerAtIndex:(NSUInteger)index;

@end

//

@interface CKManagedTableViewController : CKTableViewController <UIScrollViewDelegate> {
	id _delegate;
	NSMutableArray *_sections;
	NSMutableDictionary *_valuesForKeys;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, readonly) NSDictionary *valuesForKeys;

- (void)setup;
- (void)clear;
- (void)reload;

// Cell Controllers Management

- (void)addSection:(CKTableSection *)section;
- (void)addSectionWithCellControllers:(NSArray *)cellControllers;
- (void)addSectionWithCellControllers:(NSArray *)cellControllers headerTitle:(NSString *)headerTitle footerTitle:(NSString *)footerTitle;

@end

//

@protocol CKManagedTableViewControllerDelegate
@optional
- (void)tableViewController:(CKManagedTableViewController *)tableViewController cellControllerValueDidChange:(CKTableViewCellController *)cellController;
- (void)tableViewController:(CKManagedTableViewController *)tableViewController cellControllerDidDelete:(CKTableViewCellController *)cellController;
- (void)tableViewController:(CKManagedTableViewController *)tableViewController cellControllerDidMoveFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;
@end
