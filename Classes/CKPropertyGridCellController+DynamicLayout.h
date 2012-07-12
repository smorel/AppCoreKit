//
//  CKPropertyGridCellController+DynamicLayout.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKPropertyGridCellController.h"

@interface CKPropertyGridCellController (CKDynamicLayout)

- (void)performValidationLayout;
- (CGRect)rectForValidationButtonWithCell:(UITableViewCell*)cell;

@end
