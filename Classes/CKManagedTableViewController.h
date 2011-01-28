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
	BOOL _canMoveRowsOut;
	BOOL _canMoveRowsIn;
}

@property (nonatomic, retain, readonly) NSArray *cellControllers;
@property (nonatomic, retain, readwrite) NSString *headerTitle;
@property (nonatomic, retain, readwrite) NSString *footerTitle;
@property (nonatomic, retain, readwrite) UIView *headerView;
@property (nonatomic, retain, readwrite) UIView *footerView;
@property (nonatomic, assign) BOOL canMoveRowsOut;
@property (nonatomic, assign) BOOL canMoveRowsIn;

- (id)initWithCellControllers:(NSArray *)cellControllers;
- (void)insertCellController:(CKTableViewCellController *)cellController atIndex:(NSUInteger)index;
- (void)removeCellControllerAtIndex:(NSUInteger)index;

@end

//

@interface CKManagedTableViewController : CKTableViewController <UIScrollViewDelegate> {
	id _managedTableViewDelegate;
	NSMutableArray *_sections;
	NSMutableDictionary *_valuesForKeys;
}

@property (nonatomic, assign) id managedTableViewDelegate;
@property (nonatomic, readonly) NSDictionary *valuesForKeys;

- (void)setup;
- (void)clear;
- (void)reload;

// Cell Controllers Management

- (void)addSection:(CKTableSection *)section;
- (CKTableSection *)addSectionWithCellControllers:(NSArray *)cellControllers;
- (CKTableSection *)addSectionWithCellControllers:(NSArray *)cellControllers headerTitle:(NSString *)headerTitle footerTitle:(NSString *)footerTitle;
- (void)insertCellController:(CKTableViewCellController*)cellController atIndex:(NSUInteger)index inSection:(NSUInteger)sectionIndex;
- (CKTableSection*)sectionAtIndex:(NSUInteger)index;

@end

//

@protocol CKManagedTableViewControllerDelegate
@optional
- (void)tableViewController:(CKManagedTableViewController *)tableViewController cellControllerValueDidChange:(CKTableViewCellController *)cellController;
- (void)tableViewController:(CKManagedTableViewController *)tableViewController cellControllerDidDelete:(CKTableViewCellController *)cellController;
- (void)tableViewController:(CKManagedTableViewController *)tableViewController cellControllerDidMoveFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;
@end
