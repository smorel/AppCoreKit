//
//  CKViewControllerCellController.m
//  YellowPages
//
//  Created by Sebastien Morel on 11-12-05.
//  Copyright (c) 2011 WhereCloud Inc. All rights reserved.
//

#import "CKViewControllerCellController.h"
#import "CKUIView+Positioning.h"

@implementation CKViewControllerCellController
@synthesize viewController = _viewController;

- (void)dealloc{
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
    controllerView.frame = cell.contentView.bounds;
    controllerView.x += self.contentInsets.left;
    controllerView.y += self.contentInsets.top;
    controllerView.width -= self.contentInsets.left + self.contentInsets.right;
    controllerView.height -= self.contentInsets.top + self.contentInsets.bottom;
    [cell.contentView addSubview:controllerView];
    
    [self setupViewControllerView:controllerView];
    [_viewController viewWillAppear:NO];
    [_viewController viewDidAppear:NO];
}

- (void)cellDidDisappear{
    [super cellDidDisappear];
    [_viewController viewWillDisappear:NO];
    [_viewController viewDidDisappear:NO];
}

+ (CKItemViewFlags)flagsForObject:(id)object withParams:(NSDictionary*)params{
	return CKItemViewFlagNone;
}

- (void)setupViewControllerView:(UIView*)view{
    
}

@end
