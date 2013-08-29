//
//  CKGridCollectionViewController.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKTableCollectionViewController.h"

/**
 */
@interface CKGridCollectionViewController : CKTableCollectionViewController

///-----------------------------------
/// @name Setting the grid layout
///-----------------------------------

/**
 */
@property(nonatomic,assign) CGSize size;

///-----------------------------------
/// @name Accessing cell controllers
///-----------------------------------

/**
 */
- (CKCollectionCellController*)subControllerForRow:(NSInteger)row column:(NSInteger)column;

@end
