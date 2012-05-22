//
//  CKMapAnnotationController+CKBlockBasedInterface.m
//  CloudKit
//
//  Created by Sebastien Morel on 12-04-17.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKMapAnnotationController+CKBlockBasedInterface.h"

@implementation CKMapAnnotationController (CKBlockBasedInterface)


- (void)setInitBlock:(void(^)(CKMapAnnotationController* controller, MKAnnotationView* view))block{
    if(block){
        self.initCallback = [CKCallback callbackWithBlock:^id(id value) {
            CKMapAnnotationController* controller = (CKMapAnnotationController*)value;
            MKAnnotationView* view = (MKAnnotationView*)controller.view;
            block(controller,view);
            return (id)nil;
        }];
    }else{ self.initCallback = nil; }
}

- (void)setSetupBlock:(void(^)(CKMapAnnotationController* controller, MKAnnotationView* view))block{
    if(block){
        self.setupCallback = [CKCallback callbackWithBlock:^id(id value) {
            CKMapAnnotationController* controller = (CKMapAnnotationController*)value;
            MKAnnotationView* view = (MKAnnotationView*)controller.view;
            block(controller,view);
            return (id)nil;
        }];
    }else{ self.setupCallback = nil; }
}

- (void)setSelectionBlock:(void(^)(CKMapAnnotationController* controller))block{
    if(block){
        self.selectionCallback = [CKCallback callbackWithBlock:^id(id value) {
            CKMapAnnotationController* controller = (CKMapAnnotationController*)value;
            block(controller);
            return (id)nil;
        }];
    }else{ self.selectionCallback = nil; }
}


- (void)setDeselectionBlock:(void(^)(CKMapAnnotationController* controller))block{
    if(block){
        self.deselectionCallback = [CKCallback callbackWithBlock:^id(id value) {
            CKMapAnnotationController* controller = (CKMapAnnotationController*)value;
            block(controller);
            return (id)nil;
        }];
    }else{ self.deselectionCallback = nil; }
}

- (void)setAccessorySelectionBlock:(void(^)(CKMapAnnotationController* controller))block{
    if(block){
        self.accessorySelectionCallback = [CKCallback callbackWithBlock:^id(id value) {
            CKMapAnnotationController* controller = (CKMapAnnotationController*)value;
            block(controller);
            return (id)nil;
        }];
    }else{ self.accessorySelectionCallback = nil; }
}

- (void)setViewDidAppearBlock:(void(^)(CKMapAnnotationController* controller, MKAnnotationView* view))block{
    if(block){
        self.viewDidAppearCallback = [CKCallback callbackWithBlock:^id(id value) {
            CKMapAnnotationController* controller = (CKMapAnnotationController*)value;
            MKAnnotationView* view = (MKAnnotationView*)controller.view;
            block(controller,view);
            return (id)nil;
        }];
    }else{ self.viewDidAppearCallback = nil; }
}

- (void)setViewDidDisappearBlock:(void(^)(CKMapAnnotationController* controller, MKAnnotationView* view))block{
    if(block){
        self.viewDidDisappearCallback = [CKCallback callbackWithBlock:^id(id value) {
            CKMapAnnotationController* controller = (CKMapAnnotationController*)value;
            MKAnnotationView* view = (MKAnnotationView*)controller.view;
            block(controller,view);
            return (id)nil;
        }];
    }else{ self.viewDidDisappearCallback = nil; }
}

- (void)setLayoutBlock:(void(^)(CKMapAnnotationController* controller, MKAnnotationView* view))block{
    if(block){
        self.layoutCallback = [CKCallback callbackWithBlock:^id(id value) {
            CKMapAnnotationController* controller = (CKMapAnnotationController*)value;
            MKAnnotationView* view = (MKAnnotationView*)controller.view;
            block(controller,view);
            return (id)nil;
        }];
    }else{ self.layoutCallback = nil; }
}

@end
