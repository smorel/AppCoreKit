//
//  CKPropertyTableViewCellController+DynamicLayout.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKPropertyTableViewCellController.h"

@interface CKPropertyTableViewCellController (CKDynamicLayout)

- (void)performValidationLayout;
- (CGRect)rectForValidationButtonWithCell:(UITableViewCell*)cell;

@end
