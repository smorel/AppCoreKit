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
#import "CKCollectionViewLayoutController.h"
#import "CKCollectionViewCell.h"
#import "UIView+Positioning.h"
#import "CKViewCellCache.h"
#import "NSObject+Bindings.h"

@interface CKReusableViewController ()
@property(nonatomic,assign) BOOL isComputingSize;
@property(nonatomic,assign,readwrite) CKCollectionCellController* collectionCellController;
@end


@interface CKCollectionContentCellController()
@property(nonatomic,retain) CKReusableViewController* contentViewController;
@property(nonatomic,assign) BOOL isContentViewDidAppear;
@end

@implementation CKCollectionContentCellController
@synthesize deselectionCallback = _deselectionCallback;

- (id)initWithContentViewController:(CKReusableViewController*)contentViewController{
    self = [super init];
    self.contentViewController = contentViewController;
    [contentViewController setCollectionCellController:self];
    self.isContentViewDidAppear = NO;
    [contentViewController postInit];
    return self;
}

- (NSString*)identifier{
    return [NSString stringWithFormat:@"%@_%@",[super identifier],[self.contentViewController reuseIdentifier]];
}

- (void)dealloc{
    [_contentViewController release];
    [_deselectionCallback release];
    [super dealloc];
}


- (void)applyStyle{
    [super applyStyle];
    
    if(!self.view || ![self contentViewController])
        return;
    
    UIView* contentView = [self.view valueForKey:@"contentView"];
    if(contentView == nil){ contentView = self.view; }
    
    contentView.flexibleSize = YES;
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
    
    self.isContentViewDidAppear = YES;
}

- (void)viewDidAppear:(UIView *)view{
    [super viewDidAppear:view];
    
    if(![self contentViewController] || self.isContentViewDidAppear)
        return;
    
    [self setupView:view];
}

- (void)setView:(UIView *)view{
    [super setView:view];
    if(view == nil){
        [self viewDidDisappear];
    }
}

- (void)viewDidDisappear{
    [super viewDidDisappear];
    
    if(![self contentViewController] || !self.isContentViewDidAppear)
        return;
    
    [[self contentViewController]viewWillDisappear:NO];
    [[self contentViewController]viewDidDisappear:NO];
    
    [[self contentViewController]prepareForReuseUsingContentView:nil contentViewCell:nil];
    self.isContentViewDidAppear = NO;
}


- (CGSize)preferredSizeConstraintToSize:(CGSize)size{
    [self contentViewController].isComputingSize = YES;
    if(self.view){
        //TODO : CHECK IF REQUIERED OR WHY ITS REQUIERED ?
        //ARE SOME VIEWS STILL ATTACHED TO CONTROLLER AND THEY SHOULD NOT ?
        [self setupView:self.view];
        CGSize result =  [[self contentViewController] preferredSizeConstraintToSize:size];
        [self contentViewController].isComputingSize = NO;
        
        return result;
    }else{
        
        CKCollectionViewCell* view = (CKCollectionViewCell*)[[CKViewCellCache sharedInstance]reusableViewWithIdentifier:[self identifier]];
        
        if(!view){
            view = [[[CKCollectionViewCell alloc]init]autorelease];
            view.height = size.height;
            view.width  = size.width;
            
            UIView* original = self.view; //For styles to apply correctly on view.
            self.view = view;
            
            [self initView:view];
            self.view = original;
            [[CKViewCellCache sharedInstance]setReusableView:view forIdentifier:[self identifier]];
        }
        
        UIView* original = self.view; //For styles to apply correctly on view.
        self.view = view;
        [self setupView:view];
        CGSize result = [[self contentViewController] preferredSizeConstraintToSize:size];
        
        [self viewDidDisappear];
        [view clearBindingsContext];
    
        self.view = original;
        [self contentViewController].isComputingSize = NO;
        
        return result;
   }

}

- (void)didSelect{
    [super didSelect];
    [self.contentViewController didSelect];
}

- (void)didDeselect{
    if(self.deselectionCallback != nil){
        [self.deselectionCallback execute:self];
    }
}

- (BOOL)didRemove{
    if([super didRemove])
        return YES;
    
    return [self.contentViewController didRemove];
}

- (void)didBecomeFirstResponder{
    [super didBecomeFirstResponder];
    [self.contentViewController didBecomeFirstResponder];
}

- (void)didResignFirstResponder{
    
    [super didResignFirstResponder];
    [self.contentViewController didResignFirstResponder];
}

@end
