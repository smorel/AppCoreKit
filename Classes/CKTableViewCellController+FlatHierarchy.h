//
//  CKTableViewCellController+FlatHierarchy.h
//  AppCoreKit
//
//  Created by Guillaume Campagna.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKTableViewCellController.h"

@interface CKTableViewCellController (FlatHierarchy)

@property (nonatomic, assign) BOOL wantFlatHierarchy;
- (void)flattenHierarchyHighlighted:(BOOL)highlighted;
- (void)restoreViews;

@end
