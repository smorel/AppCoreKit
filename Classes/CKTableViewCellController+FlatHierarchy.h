//
//  CKTableViewCellController+FlatHierarchy.h
//  CloudKit
//
//  Created by Guillaume Campagna on 12-06-12.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import <CloudKit/CloudKit.h>

@interface CKTableViewCellController (FlatHierarchy)

@property (nonatomic, assign) BOOL wantFlatHierarchy;
- (void)flattenHierarchyHighlighted:(BOOL)highlighted;
- (void)restoreViews;

@end
