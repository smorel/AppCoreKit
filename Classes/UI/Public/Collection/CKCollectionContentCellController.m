//
//  CKCollectionContentCellController.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-10-23.
//  Copyright (c) 2013 Sebastien Morel. All rights reserved.
//

#import "CKCollectionContentCellController.h"
#import "CKLayoutBox.h"
#import "CKStyleManager.h"
#import "UIView+Style.h"
#import "UIView+CKLayout.h"

@interface CKCollectionCellContentViewController ()
@property(nonatomic,assign,readwrite) CKCollectionCellController* collectionCellController;
@end


@interface CKCollectionContentCellController()
@property(nonatomic,retain) CKCollectionCellContentViewController* contentViewController;
@end

@implementation CKCollectionContentCellController
@synthesize deselectionCallback;

- (id)initWithContentViewController:(CKCollectionCellContentViewController*)contentViewController{
    self = [super init];
    [self setContentViewController:contentViewController];
    [contentViewController setCollectionCellController:self];
    return self;
}

- (void)dealloc{
    [_contentViewController release];
    [_contentViewController release];
    [super dealloc];
}

- (void)didDeselect{
	if(self.deselectionCallback != nil){
		[self.deselectionCallback execute:self];
	}
}

- (void)applyStyle{
    [super applyStyle];
    
    if(!self.view || ![self contentViewController])
        return;
    
    UIView* contentView = [self.view valueForKey:@"contentView"];
    if(contentView == nil){ contentView = self.view; }
    
    contentView.sizeToFitLayoutBoxes = NO;
    [contentView setAppliedStyle:nil];
    
    if(self.view.appliedStyle == nil || [self.view.appliedStyle isEmpty]){
        [self.view.appliedStyle setAppliedStyle:nil];
    }
}

- (void)setupView:(UIView*)view{
    if([self contentViewController]){
        UIView* contentView = [view valueForKey:@"contentView"];
        if(contentView == nil){ contentView = view; }
    
        [[self contentViewController]prepareForReuseUsingContentView:contentView contentViewCell:view];
        [[self contentViewController]viewWillAppear:NO];
    }
    
    [super setupView:view];
    
    if([self contentViewController]){
        [[self contentViewController]viewDidAppear:NO];
    }
}

- (void)viewDidDisappear{
    if(![self contentViewController])
        return;
    
    [[self contentViewController]viewWillDisappear:NO];
    [[self contentViewController]viewDidDisappear:NO];
}

@end
