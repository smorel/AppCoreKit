//
//  CKTableViewCellController+CKBlockBasedInterface.m
//  CloudKit
//
//  Created by Martin Dufort on 12-04-17.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKTableViewCellController+CKBlockBasedInterface.h"

@implementation CKTableViewCellController (CKBlockBasedInterface)


- (void)setInitBlock:(void(^)(CKTableViewCellController* controller, UITableViewCell* cell))block{
    if(block){
        self.initCallback = [CKCallback callbackWithBlock:^id(id value) {
            CKTableViewCellController* controller = (CKTableViewCellController*)value;
            UITableViewCell* cell = controller.tableViewCell;
            block(controller,cell);
            return (id)nil;
        }];
    }
}

- (void)setSetupBlock:(void(^)(CKTableViewCellController* controller, UITableViewCell* cell))block{
    if(block){
        self.setupCallback = [CKCallback callbackWithBlock:^id(id value) {
            CKTableViewCellController* controller = (CKTableViewCellController*)value;
            UITableViewCell* cell = controller.tableViewCell;
            block(controller,cell);
            return (id)nil;
        }];
    }
}

- (void)setSelectionBlock:(void(^)(CKTableViewCellController* controller))block{
    if(block){
        self.selectionCallback = [CKCallback callbackWithBlock:^id(id value) {
            CKTableViewCellController* controller = (CKTableViewCellController*)value;
            block(controller);
            return (id)nil;
        }];
    }
}

- (void)setAccessorySelectionBlock:(void(^)(CKTableViewCellController* controller))block{
    if(block){
        self.accessorySelectionCallback = [CKCallback callbackWithBlock:^id(id value) {
            CKTableViewCellController* controller = (CKTableViewCellController*)value;
            block(controller);
            return (id)nil;
        }];
    }
}

- (void)setBecomeFirstResponderBlock:(void(^)(CKTableViewCellController* controller))block{
    if(block){
        self.becomeFirstResponderCallback = [CKCallback callbackWithBlock:^id(id value) {
            CKTableViewCellController* controller = (CKTableViewCellController*)value;
            block(controller);
            return (id)nil;
        }];
    }
}

- (void)setResignFirstResponderBlock:(void(^)(CKTableViewCellController* controller))block{
    if(block){
        self.resignFirstResponderCallback = [CKCallback callbackWithBlock:^id(id value) {
            CKTableViewCellController* controller = (CKTableViewCellController*)value;
            block(controller);
            return (id)nil;
        }];
    }
}

- (void)setViewDidAppearBlock:(void(^)(CKTableViewCellController* controller, UITableViewCell* cell))block{
    if(block){
        self.viewDidAppearCallback = [CKCallback callbackWithBlock:^id(id value) {
            CKTableViewCellController* controller = (CKTableViewCellController*)value;
            UITableViewCell* cell = controller.tableViewCell;
            block(controller,cell);
            return (id)nil;
        }];
    }
}

- (void)setViewDidDisappearBlock:(void(^)(CKTableViewCellController* controller, UITableViewCell* cell))block{
    if(block){
        self.viewDidDisappearCallback = [CKCallback callbackWithBlock:^id(id value) {
            CKTableViewCellController* controller = (CKTableViewCellController*)value;
            UITableViewCell* cell = controller.tableViewCell;
            block(controller,cell);
            return (id)nil;
        }];
    }
}

- (void)setLayoutBlock:(void(^)(CKTableViewCellController* controller, UITableViewCell* cell))block{
    if(block){
        self.layoutCallback = [CKCallback callbackWithBlock:^id(id value) {
            CKTableViewCellController* controller = (CKTableViewCellController*)value;
            UITableViewCell* cell = controller.tableViewCell;
            block(controller,cell);
            return (id)nil;
        }];
    }
}

@end
