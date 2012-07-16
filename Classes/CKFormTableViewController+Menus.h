//
//  CKFormTableViewController+Menus.h
//  CloudKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKFormTableViewController.h"

@interface CKFormCellDescriptor(CKMenus)

+ (CKFormCellDescriptor*)cellDescriptorWithTitle:(NSString*)title action:(void(^)(CKTableViewCellController* controller))action;
+ (CKFormCellDescriptor*)cellDescriptorWithTitle:(NSString*)title subtitle:(NSString*)subTitle action:(void(^)(CKTableViewCellController* controller))action;
+ (CKFormCellDescriptor*)cellDescriptorWithTitle:(NSString*)title image:(UIImage*)image action:(void(^)(CKTableViewCellController* controller))action;
+ (CKFormCellDescriptor*)cellDescriptorWithTitle:(NSString*)title subtitle:(NSString*)subTitle image:(UIImage*)image action:(void(^)(CKTableViewCellController* controller))action;

@end