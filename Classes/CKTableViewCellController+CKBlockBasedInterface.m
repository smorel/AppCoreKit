//
//  CKTableViewCellController+CKBlockBasedInterface.m
//  CloudKit
//
//  Created by Sebastien Morel on 12-04-17.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKTableViewCellController+CKBlockBasedInterface.h"

@implementation CKTableViewCellController (CKBlockBasedInterface)

- (void)setDeallocBlock:(void(^)(CKTableViewCellController* controller))block{
    if(block){
        self.deallocCallback = [CKCallback callbackWithBlock:^id(id value) {
            CKTableViewCellController* controller = (CKTableViewCellController*)value;
            block(controller);
            return (id)nil;
        }];
    }else{ self.deallocCallback = nil; }
}

- (void)setInitBlock:(void(^)(CKTableViewCellController* controller, UITableViewCell* cell))block{
    if(block){
        self.initCallback = [CKCallback callbackWithBlock:^id(id value) {
            CKTableViewCellController* controller = (CKTableViewCellController*)value;
            UITableViewCell* cell = controller.tableViewCell;
            block(controller,cell);
            return (id)nil;
        }];
    }else{ self.initCallback = nil; }
}

- (void)setSetupBlock:(void(^)(CKTableViewCellController* controller, UITableViewCell* cell))block{
    if(block){
        self.setupCallback = [CKCallback callbackWithBlock:^id(id value) {
            CKTableViewCellController* controller = (CKTableViewCellController*)value;
            UITableViewCell* cell = controller.tableViewCell;
            block(controller,cell);
            return (id)nil;
        }];
    }else{ self.setupCallback = nil; }
}

- (void)setSelectionBlock:(void(^)(CKTableViewCellController* controller))block{
    if(block){
        self.selectionCallback = [CKCallback callbackWithBlock:^id(id value) {
            CKTableViewCellController* controller = (CKTableViewCellController*)value;
            block(controller);
            return (id)nil;
        }];
    }else{ self.selectionCallback = nil; }
}

- (void)setAccessorySelectionBlock:(void(^)(CKTableViewCellController* controller))block{
    if(block){
        self.accessorySelectionCallback = [CKCallback callbackWithBlock:^id(id value) {
            CKTableViewCellController* controller = (CKTableViewCellController*)value;
            block(controller);
            return (id)nil;
        }];
    }else{ self.accessorySelectionCallback = nil; }
}

- (void)setBecomeFirstResponderBlock:(void(^)(CKTableViewCellController* controller))block{
    if(block){
        self.becomeFirstResponderCallback = [CKCallback callbackWithBlock:^id(id value) {
            CKTableViewCellController* controller = (CKTableViewCellController*)value;
            block(controller);
            return (id)nil;
        }];
    }else{ self.becomeFirstResponderCallback = nil; }
}

- (void)setResignFirstResponderBlock:(void(^)(CKTableViewCellController* controller))block{
    if(block){
        self.resignFirstResponderCallback = [CKCallback callbackWithBlock:^id(id value) {
            CKTableViewCellController* controller = (CKTableViewCellController*)value;
            block(controller);
            return (id)nil;
        }];
    }else{ self.resignFirstResponderCallback = nil; }
}

- (void)setViewDidAppearBlock:(void(^)(CKTableViewCellController* controller, UITableViewCell* cell))block{
    if(block){
        self.viewDidAppearCallback = [CKCallback callbackWithBlock:^id(id value) {
            CKTableViewCellController* controller = (CKTableViewCellController*)value;
            UITableViewCell* cell = controller.tableViewCell;
            block(controller,cell);
            return (id)nil;
        }];
    }else{ self.viewDidAppearCallback = nil; }
}

- (void)setViewDidDisappearBlock:(void(^)(CKTableViewCellController* controller, UITableViewCell* cell))block{
    if(block){
        self.viewDidDisappearCallback = [CKCallback callbackWithBlock:^id(id value) {
            CKTableViewCellController* controller = (CKTableViewCellController*)value;
            UITableViewCell* cell = controller.tableViewCell;
            block(controller,cell);
            return (id)nil;
        }];
    }else{ self.viewDidDisappearCallback = nil; }
}

- (void)setLayoutBlock:(void(^)(CKTableViewCellController* controller, UITableViewCell* cell))block{
    if(block){
        self.layoutCallback = [CKCallback callbackWithBlock:^id(id value) {
            CKTableViewCellController* controller = (CKTableViewCellController*)value;
            UITableViewCell* cell = controller.tableViewCell;
            block(controller,cell);
            return (id)nil;
        }];
    }else{ self.layoutCallback = nil; }
}

@end
