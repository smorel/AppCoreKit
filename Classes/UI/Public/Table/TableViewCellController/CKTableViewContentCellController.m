//
//  CKTableViewContentCellController.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2/12/2014.
//  Copyright (c) 2014 Sebastien Morel. All rights reserved.
//

#import "CKTableViewContentCellController.h"
#import "NSObject+Bindings.h"
#import "UIView+Positioning.h"
#import "UIView+Style.h"
#import "UIViewController+Style.h"
#import "CKLayoutBox.h"
#import "UIView+CKLayout.h"
#import "CKContainerViewController.h"
#import "CKStyleManager.h"
#import "CKResourceManager.h"
#import "CKResourceDependencyContext.h"



@interface CKTableViewCellController ()
@property (nonatomic, retain) NSMutableDictionary* textLabelStyle;
@property (nonatomic, retain) NSMutableDictionary* detailTextLabelStyle;
@property (nonatomic, assign) BOOL isInSetup;
@property (nonatomic, assign) CKTableViewCellController* parentCellController;//In case of grids, ...
@property (nonatomic, assign) BOOL invalidatedSize;
@property (nonatomic, assign) BOOL sizeHasBeenQueriedByTableView;
@end


@interface CKCollectionCellContentViewController ()
@property(nonatomic,assign,readwrite) CKCollectionCellController* collectionCellController;
@end

@interface CKTableViewContentCellController()
@property(nonatomic,retain) CKCollectionCellContentViewController* contentViewController;
@end

@implementation CKTableViewContentCellController

- (id)initWithContentViewController:(CKCollectionCellContentViewController*)contentViewController{
    self = [super init];
    self.cellStyle = CKTableViewCellStyleCustomLayout;
    [self setContentViewController:contentViewController];
    [contentViewController setCollectionCellController:self];
    return self;
}

- (void)dealloc{
    [_contentViewController release];
    [super dealloc];
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

- (void)initView:(UIView *)view{
    [super initView:view];
    
    if([self contentViewController]){
        UIView* contentView = [view valueForKey:@"contentView"];
        if(contentView == nil){ contentView = view; }
        
        [[self contentViewController]prepareForReuseUsingContentView:contentView contentViewCell:view];
        [[self contentViewController]viewDidLoad];
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
    [[self contentViewController]setView:nil];
}

- (void)setView:(UIView *)view{
    [super setView:view];
    if(view == nil){
        [[self contentViewController]setView:nil];
    }
}
 
- (CGSize)preferredSizeConstraintToSize:(CGSize)size{
    return [self.contentViewController preferredSizeConstraintToSize:size];
}

@end
