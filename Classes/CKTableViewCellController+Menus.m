//
//  CKTableViewCellController+Menus.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-04.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKTableViewCellController+Menus.h"
#import "CKTableViewCellController.h"


@implementation CKTableViewCellController (CKMenus)

+ (CKTableViewCellController*)cellControllerWithTitle:(NSString*)title action:(void(^)(CKTableViewCellController* controller))action{
    return [CKTableViewCellController cellControllerWithTitle:title subtitle:nil image:nil action:action];
}

+ (CKTableViewCellController*)cellControllerWithTitle:(NSString*)title subtitle:(NSString*)subTitle action:(void(^)(CKTableViewCellController* controller))action{
    return [CKTableViewCellController cellControllerWithTitle:title subtitle:subTitle image:nil action:action];
}

+ (CKTableViewCellController*)cellControllerWithTitle:(NSString*)title image:(UIImage*)image action:(void(^)(CKTableViewCellController* controller))action{
    return [CKTableViewCellController cellControllerWithTitle:title subtitle:nil image:image action:action];
}

+ (CKTableViewCellController*)cellControllerWithTitle:(NSString*)title subtitle:(NSString*)subTitle image:(UIImage*)image action:(void(^)(CKTableViewCellController* controller))action{
    id value = nil;
    if(title != nil){
        value = title;
    }
    else if(subTitle != nil){
        value = subTitle;
    }
    else if(image != nil){
        value = image;
    }
    
    if(value == nil)
        return nil;
    
    CKTableViewCellController* cellController = [CKTableViewCellController cellController];
    cellController.value = value;
    cellController.cellStyle = ((subTitle != nil) ? CKTableViewCellStyleSubtitle : CKTableViewCellStyleDefault);
    cellController.name = [NSString stringWithFormat:@"cellDescriptorWithTitle<%d>",cellController.cellStyle];
    cellController.flags = ((action != nil) ? CKItemViewFlagSelectable : CKItemViewFlagNone);
    
    [cellController setSetupBlock:^(CKTableViewCellController *controller, UITableViewCell *cell) {
        controller.tableViewCell.textLabel.text = title;
        controller.tableViewCell.detailTextLabel.text = subTitle;
        controller.tableViewCell.imageView.image = image;
        controller.tableViewCell.accessoryType = ((action != nil) ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone);
        controller.tableViewCell.selectionStyle = ((action != nil) ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone);
    }];

    if(action != nil){
        [cellController setSelectionBlock:^(CKTableViewCellController *controller) {
            action(controller);
        }];
    }
    return cellController;
}

@end
