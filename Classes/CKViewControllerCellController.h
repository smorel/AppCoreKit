//
//  CKViewControllerCellController.h
//  YellowPages
//
//  Created by Sebastien Morel on 11-12-05.
//  Copyright (c) 2011 WhereCloud Inc. All rights reserved.
//

#import "CKTableViewCellController.h"

@interface CKViewControllerCellController : CKTableViewCellController
@property(nonatomic,retain) UIViewController* viewController;

- (void)setupViewControllerView:(UIView*)view;

@end
