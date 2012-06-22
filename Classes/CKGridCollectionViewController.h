//
//  CKGridCollectionViewController.h
//  CloudKit
//
//  Created by Martin Dufort on 12-05-14.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKTableCollectionViewController.h"

/** TODO
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
