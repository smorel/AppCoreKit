//
//  CKFormTableViewController+Menus.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-04.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKFormTableViewController.h"

@interface CKFormCellDescriptor(CKMenus)

+ (CKFormCellDescriptor*)cellDescriptorWithTitle:(NSString*)title action:(void(^)())action;
+ (CKFormCellDescriptor*)cellDescriptorWithTitle:(NSString*)title subtitle:(NSString*)subTitle action:(void(^)())action;
+ (CKFormCellDescriptor*)cellDescriptorWithTitle:(NSString*)title image:(UIImage*)image action:(void(^)())action;
+ (CKFormCellDescriptor*)cellDescriptorWithTitle:(NSString*)title subtitle:(NSString*)subTitle image:(UIImage*)image action:(void(^)())action;

@end