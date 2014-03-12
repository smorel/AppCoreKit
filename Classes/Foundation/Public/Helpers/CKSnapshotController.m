//
//  CKSnapshotController.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 3/5/2014.
//  Copyright (c) 2014 Sebastien Morel. All rights reserved.
//

#import "CKSnapshotController.h"
#import <objc/runtime.h>
#import "UIView+Snapshot.h"


static char UIViewControllerRequiersDelayBeforeSnapshotKey;
static char UIViewControllerReadyForSnapshotBlockKey;

@implementation UIViewController(CKSnapshotController)
@dynamic requiersDelayBeforeSnapshot;

- (void)setRequiersDelayBeforeSnapshot:(BOOL)requiersDelayBeforeSnapshot{
    objc_setAssociatedObject(self,
                             &UIViewControllerRequiersDelayBeforeSnapshotKey,
                             [NSNumber numberWithBool:requiersDelayBeforeSnapshot],
                             OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)requiersDelayBeforeSnapshot{
    id value = objc_getAssociatedObject(self, &UIViewControllerRequiersDelayBeforeSnapshotKey);
    return value ? [value boolValue] : NO;
}

- (void)setReadyForSnapshotBlock:(void(^)())block{
    objc_setAssociatedObject(self,
                             &UIViewControllerReadyForSnapshotBlockKey,
                             [block copy],
                             OBJC_ASSOCIATION_COPY);
}

- (void(^)())readyForSnapshotBlock{
    return objc_getAssociatedObject(self, &UIViewControllerReadyForSnapshotBlockKey);
}

- (void)readyForSnapshot{
    if(self.readyForSnapshotBlock){
        self.readyForSnapshotBlock();
    }
}

@end



@interface CKSnapshotController ()
@property(nonatomic,retain) UIWindow* offscreenWindow;
@property(nonatomic,copy) void(^completion)(UIImage* image);
@property(nonatomic,retain) CKSnapshotController* selfRetain;
@property(nonatomic,retain) UIViewController* viewController;
@end

@implementation CKSnapshotController

- (void)dealloc{
    [_offscreenWindow release];
    [_completion release];
    [_selfRetain release];
    [_viewController release];
    [super dealloc];
}

+ (CKSnapshotController*)snapshotController{
    return [[CKSnapshotController alloc]init];
}

- (void)snapshotViewController:(UIViewController*)viewController
                          size:(CGSize)size
                         delay:(void(^)( void(^readyForSnapshot)()) )delay
                    completion:(void(^)(UIImage* image))completion
{
    self.viewController = viewController;
    self.completion = completion;
    
    [self startWithSize:size];
    [viewController.view layoutSubviews];
    
    if(delay){
        __unsafe_unretained CKSnapshotController* bself = self;
        delay(^(){
            [bself endSnapshot];
        });
    }else{
        [self endSnapshot];
    }
}


- (void)snapshotViewController:(UIViewController*)viewController
                          size:(CGSize)size
                    completion:(void(^)(UIImage* image))completion{
    
    if(viewController.requiersDelayBeforeSnapshot){
        [self snapshotViewController:viewController size:size delay:^(void(^readyForSnapshot)()) {
            [viewController setReadyForSnapshotBlock:^(){
                readyForSnapshot();
            }];
        } completion:^(UIImage *image) {
            [viewController setReadyForSnapshotBlock:nil];
            if(completion){
                completion(image);
            }
        }];
    }else{
        [self snapshotViewController:viewController size:size delay:nil completion:completion];
    }
    
}

- (void)readyForSnapshot{
    [self endSnapshot];
}

- (void)startWithSize:(CGSize)size{
    self.selfRetain = self;
    
    self.offscreenWindow = [[UIWindow alloc]initWithFrame:CGRectMake(0,0,size.width,size.height)];
    
    self.viewController.view.frame = self.offscreenWindow.bounds;
    [self.viewController viewWillAppear:NO];
    [self.offscreenWindow addSubview:self.viewController.view];
    [self.viewController viewDidAppear:NO];
}

- (void)endSnapshot{
    UIImage* snapshot = [self.viewController.view snapshot];
    
    if(self.completion){
        self.completion(snapshot);
    }
    
    [self.viewController viewWillDisappear:NO];
    [self.viewController viewDidDisappear:NO];
    
    self.offscreenWindow = nil;
    self.viewController = nil;
    self.completion = nil;
    self.selfRetain = nil;
}

@end

