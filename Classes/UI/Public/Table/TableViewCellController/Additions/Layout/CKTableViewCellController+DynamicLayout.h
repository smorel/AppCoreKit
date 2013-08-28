//
//  CKTableViewCellController+DynamicLayout.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
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
