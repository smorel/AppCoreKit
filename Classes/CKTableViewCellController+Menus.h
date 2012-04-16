//
//  CKTableViewCellController+Menus.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-04.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKFormTableViewController.h"


@interface CKTableViewCellController(CKMenus)

+ (CKTableViewCellController*)cellControllerWithTitle:(NSString*)title action:(void(^)(CKTableViewCellController* controller))action;
+ (CKTableViewCellController*)cellControllerWithTitle:(NSString*)title subtitle:(NSString*)subTitle action:(void(^)(CKTableViewCellController* controller))action;
+ (CKTableViewCellController*)cellControllerWithTitle:(NSString*)title image:(UIImage*)image action:(void(^)(CKTableViewCellController* controller))action;
+ (CKTableViewCellController*)cellControllerWithTitle:(NSString*)title subtitle:(NSString*)subTitle image:(UIImage*)image action:(void(^)(CKTableViewCellController* controller))action;

@end