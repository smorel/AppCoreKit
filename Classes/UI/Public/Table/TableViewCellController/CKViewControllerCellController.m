//
//  CKViewControllerCellController.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 WhereCloud Inc. All rights reserved.
//

#import "CKViewControllerCellController.h"
#import "UIView+Positioning.h"
#import "CKContainerViewController.h"

@interface CKCollectionCellController()
@property (nonatomic, assign, readwrite) CKCollectionViewController* containerController;
@property (nonatomic, assign) BOOL isViewAppeared;
@end

@interface CKViewControllerCellController()
@property(nonatomic,assign) BOOL controllerHasBeenInitialized;
@end

@implementation CKViewControllerCellController
@synthesize viewController = _viewController;
@synthesize controllerHasBeenInitialized = _controllerHasBeenInitialized;

- (void)postInit{
    [super postInit];
    _controllerHasBeenInitialized = NO;
}

- (void)dealloc{
    [_viewController setContainerViewController:nil];
    
    [_viewController release];
    _viewController = nil;
    [super dealloc];
}

- (NSString *)identifier{
    NSMutableString* theIdentifier = [NSMutableString stringWithString:[super identifier]];
    if([_viewController respondsToSelector:@selector(name)]){
        NSString* name = [_viewController performSelector:@selector(name)];
        [theIdentifier appendFormat:@"-%@-%@",[[_viewController class]description],name];
    }
    else{
        [theIdentifier appendFormat:@"-%@",[_viewController class]];
    }
    return theIdentifier;
}

- (void)setupCell:(UITableViewCell *)cell {
    [super setupCell:cell];
    
	UIView* controllerView = [_viewController view];
    controllerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    CGRect frame = cell.contentView.bounds;
    frame.origin.x += self.contentInsets.left;
    frame.origin.y += self.contentInsets.top;
    frame.size.width -= self.contentInsets.left + self.contentInsets.right;
    frame.size.height -= self.contentInsets.top + self.contentInsets.bottom;
    controllerView.frame = CGRectIntegral(frame);
    [cell.contentView addSubview:controllerView];
    
    //Clips to bounds avoiding the view controllers content to get displayed out of the
    //cells bounds
    cell.contentView.clipsToBounds = YES;
    cell.clipsToBounds = YES;
    
    [self setupViewControllerView:controllerView];
    
    if(!self.controllerHasBeenInitialized){
        [_viewController viewWillAppear:NO];
        [_viewController viewDidAppear:NO];
        self.controllerHasBeenInitialized = YES;
    }
}

- (void)cellDidAppear:(UITableViewCell *)cell{
    [super cellDidAppear:cell];
    
    if(!self.controllerHasBeenInitialized){
        [_viewController viewWillAppear:NO];
        [_viewController viewDidAppear:NO];
        self.controllerHasBeenInitialized = YES;
    }
}

- (void)cellDidDisappear{
    [super cellDidDisappear];
    
    if(self.controllerHasBeenInitialized){
        [_viewController viewWillDisappear:NO];
        [_viewController viewDidDisappear:NO];
        self.controllerHasBeenInitialized = NO;
    }
}

- (void)setupViewControllerView:(UIView*)view{
    
}

- (void)setViewController:(UIViewController *)theViewController{
    [_viewController release];
    _viewController = [theViewController retain];
    [_viewController setContainerViewController:self.containerController];
}

- (void)setContainerController:(CKCollectionViewController *)containerController{
    [super setContainerController:containerController];
    [_viewController setContainerViewController:containerController];
}

@end
