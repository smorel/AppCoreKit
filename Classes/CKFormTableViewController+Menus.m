//
//  CKFormTableViewController+Menus.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-04.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKFormTableViewController+Menus.h"
#import "CKTableViewCellController.h"


@implementation CKFormCellDescriptor (CKMenus)

+ (CKFormCellDescriptor*)cellDescriptorWithTitle:(NSString*)title action:(void(^)())action{
    return [CKFormCellDescriptor cellDescriptorWithTitle:title subtitle:nil image:nil action:action];
}

+ (CKFormCellDescriptor*)cellDescriptorWithTitle:(NSString*)title subtitle:(NSString*)subTitle action:(void(^)())action{
    return [CKFormCellDescriptor cellDescriptorWithTitle:title subtitle:subTitle image:nil action:action];
}

+ (CKFormCellDescriptor*)cellDescriptorWithTitle:(NSString*)title image:(UIImage*)image action:(void(^)())action{
    return [CKFormCellDescriptor cellDescriptorWithTitle:title subtitle:nil image:image action:action];
}

+ (CKFormCellDescriptor*)cellDescriptorWithTitle:(NSString*)title subtitle:(NSString*)subTitle image:(UIImage*)image action:(void(^)())action{
    id value = ((title != nil) ? title : ((subTitle != nil) ? subTitle : ((image != nil) ? image : nil)));
    if(value == nil)
        return nil;
    
    CKFormCellDescriptor* descriptor = [CKFormCellDescriptor cellDescriptorWithValue:value controllerClass:[CKTableViewCellController class]];
    [descriptor setCreateBlock:^id(id value) {
        CKTableViewCellController* controller = (CKTableViewCellController*)value;
        controller.cellStyle = ((subTitle != nil) ? UITableViewCellStyleSubtitle : UITableViewCellStyleDefault);
        return (id)nil;
    }];
    [descriptor setSetupBlock:^id(id value) {
        CKTableViewCellController* controller = (CKTableViewCellController*)value;
        controller.tableViewCell.textLabel.text = title;
        controller.tableViewCell.detailTextLabel.text = subTitle;
        controller.tableViewCell.imageView.image = image;
        return (id)nil;
    }];
    [descriptor setFlags:((action != nil) ? CKItemViewFlagSelectable : CKItemViewFlagNone)];
    if(action != nil){
        [descriptor setSelectionBlock:^id(id value) {
            action();
            return (id)nil;
        }];
    }
    return descriptor;
}

@end
