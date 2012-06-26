//
//  CKTableViewCellController+CKDynamicLayout.h
//  CloudKit
//
//  Created by Sebastien Morel on 12-04-17.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKTableViewCellController.h"


/**
 */
@interface CKTableViewCellController (CKDynamicLayout)

///-----------------------------------
/// @name Computing dynamic size
///-----------------------------------

/**
 */
- (CGSize)computeSize;

///-----------------------------------
/// @name Accessing table view cell content sizes
///-----------------------------------

/**
 */
- (CGFloat)tableViewCellWidth;

/**
 */
- (CGFloat)contentViewWidth;

/**
 */
- (CGFloat)accessoryWidth;

/**
 */
- (CGFloat)editingWidth;

@end
