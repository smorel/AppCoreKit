//
//  CKSwipableCollectionCellContentViewController.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2/12/2014.
//  Copyright (c) 2014 Sebastien Morel. All rights reserved.
//

#import "CKSwipableCollectionCellContentViewController.h"
#import <objc/runtime.h>
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
#import "UIView+Name.h"
#import "UIGestureRecognizer+BlockBasedInterface.h"
#import "NSObject+Invocation.h"

@interface CKCollectionCellContentViewController()
@property(nonatomic,assign) BOOL isComputingSize;
- (void)setCollectionCellController:(CKCollectionCellController *)c;
@end


static char CKCollectionCellContentViewControllerParentSwipeableControllerKey;

@implementation CKCollectionCellContentViewController(CKSwipableCollectionCellContentViewController)

- (void)setParentSwipeableContentViewController:(CKSwipableCollectionCellContentViewController*)controller{
    objc_setAssociatedObject(self,
                             &CKCollectionCellContentViewControllerParentSwipeableControllerKey,
                             controller,
                             OBJC_ASSOCIATION_ASSIGN);
}

- (CKSwipableCollectionCellContentViewController*) parentSwipeableContentViewController{
    return objc_getAssociatedObject(self, &CKCollectionCellContentViewControllerParentSwipeableControllerKey);
}

@end



@interface CKSwipableCollectionCellContentViewController ()<UIScrollViewDelegate, UIGestureRecognizerDelegate>
@property(nonatomic,retain) CKCollectionCellContentViewController* contentViewController;
@property(nonatomic,retain) CKSwipableCollectionCellAction* currentLeftAction;
@property(nonatomic,retain) CKSwipableCollectionCellAction* currentRightAction;
@property(nonatomic,assign) CGPoint lastScrollOffset;
@property(nonatomic,assign) BOOL isAnimatingPendingAction;
@property(nonatomic,assign) BOOL viewDidAppear;
@property(nonatomic,retain) NSString* internalBindingsContext;
@end

@implementation CKSwipableCollectionCellContentViewController

static NSTimeInterval animationDuration = 0.25;
static CGFloat bounceVsDistanceRatio = 0.1;

- (void)dealloc{
    [NSObject removeAllBindingsForContext:self.internalBindingsContext];
    [_internalBindingsContext release];
    [_currentRightAction release];
    [_currentLeftAction release];
    [_contentViewController release];
    [_rightActions release];
    [_leftActions release];
    [super dealloc];
}


- (NSString*)reuseIdentifier{
	return [NSString stringWithFormat:@"%@-%@",[super reuseIdentifier],[self.contentViewController reuseIdentifier]];
}

#pragma Content View Controller And Layout Updates Management

- (id)initWithContentViewController:(CKCollectionCellContentViewController*)contentViewController{
    self = [super init];
    self.enabled = YES;
    self.internalBindingsContext = [NSString stringWithFormat:@"CKSwipableCollectionCellContentViewController_<%p>",self];
    [self setContentViewController:contentViewController];
    [contentViewController setParentSwipeableContentViewController:self];
    return self;
}

- (void)setCollectionCellController:(CKCollectionCellController *)c{
    [super setCollectionCellController:c];
    [self.contentViewController setCollectionCellController:c];
}

- (void)prepareForReuseUsingContentView:(UIView*)contentView contentViewCell:(UIView*)contentViewCell{
    [super prepareForReuseUsingContentView:contentView contentViewCell:contentViewCell];
    [self.contentViewController prepareForReuseUsingContentView:[self scrollContentView] contentViewCell:contentViewCell];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [NSObject removeAllBindingsForContext:self.internalBindingsContext];
    self.contentViewController.view.invalidatedLayoutBlock = nil;//To avoid being called when calling [self.contentViewController viewWillAppear:animated];
    
    self.viewDidAppear = NO;
    
    [self setupTapGestureRecognizer];
    [self applyStyleToActions];
    
    [self.contentViewController viewWillAppear:animated];
    
   // if(self.isComputingSize)
   //     return;
    
    [self layoutActionViews];
    [self updatesScrollViewContentSize];
    
    self.scrollView.delegate = self;
    
    __unsafe_unretained CKSwipableCollectionCellContentViewController* bself = self;
    self.contentViewController.view.invalidatedLayoutBlock = ^(NSObject<CKLayoutBoxProtocol>* layoutBox){
       [bself updatesScrollViewContentSize];
        
        if(!bself.viewDidAppear)
            return;
        
        if([[bself collectionCellController]respondsToSelector:@selector(invalidateSize)]){
            [[bself collectionCellController]performSelector:@selector(invalidateSize) withObject:nil];
        }
    };
    
    
    [NSObject beginBindingsContext:self.internalBindingsContext policy:CKBindingsContextPolicyRemovePreviousBindings];
    
    __block CGSize oldSize = CGSizeZero;
    [self.view bind:@"frame" executeBlockImmediatly:YES withBlock:^(id value) {
        if(![bself.view window])
            return;
        
        if(!CGSizeEqualToSize(oldSize, bself.view.bounds.size)){
            [bself updatesScrollViewContentSize];
            oldSize = bself.view.bounds.size;
        }
    }];
    
    [self setupActionViewsBindings];
    [NSObject endBindingsContext];
    
    [self setupEnableState];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.viewDidAppear = YES;
    [self.contentViewController viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.contentViewController viewWillDisappear:animated];
    [NSObject removeAllBindingsForContext:self.internalBindingsContext];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.contentViewController viewDidDisappear:animated];
}

- (CGSize)preferredSizeConstraintToSize:(CGSize)size{
    CGSize ret = [self.contentViewController preferredSizeConstraintToSize:size];
    return ret;
}

#pragma Scroll View and Actions Creation

- (UIScrollView*)scrollView{
    return [self.view viewWithKeyPath:@"ScrollView"];
}

- (UIView*)scrollContentView{
    return [self.scrollView viewWithKeyPath:@"ScrollContentView"];
}

- (UIView*)leftActionsViewContainer{
    return [self.scrollView viewWithKeyPath:@"LeftActionsViewContainer"];
}

- (UIView*)rightActionsViewContainer{
    return [self.scrollView viewWithKeyPath:@"RightActionsViewContainer"];
}

- (void)setEnabled:(BOOL)bo{
    if(_enabled == bo)
        return;
    
    _enabled = bo;
    
    if(self.view){
        [self setupEnableState];
    }
}

- (void)setupEnableState{
    self.scrollView.contentOffset = CGPointZero;
    self.scrollView.scrollEnabled = self.enabled;
    self.leftActionsViewContainer.hidden = !self.enabled;
    self.rightActionsViewContainer.hidden = !self.enabled;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    UIScrollView* scrollView = [[[UIScrollView alloc]initWithFrame:self.view.bounds]autorelease];
   // scrollView.autoresizingMask = UIViewAutoresizingFlexibleSize;
    scrollView.name = @"ScrollView";
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.scrollsToTop = NO; // need to do this because if not tapping the status bar to scroll the tableview to the top no longer works...
    
    [self.view addSubview:scrollView];
    
    
    UIView* leftActionsViewContainer = [[[UIView alloc]init]autorelease];
    leftActionsViewContainer.name = @"LeftActionsViewContainer";
    leftActionsViewContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    leftActionsViewContainer.layer.zPosition = 0;
    leftActionsViewContainer.clipsToBounds = YES;
    [scrollView addSubview:leftActionsViewContainer];
    
    UIView* rightActionsViewContainer = [[[UIView alloc]init]autorelease];
    rightActionsViewContainer.name = @"RightActionsViewContainer";
    rightActionsViewContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    rightActionsViewContainer.layer.zPosition = 0;
    rightActionsViewContainer.clipsToBounds = YES;
    [scrollView addSubview:rightActionsViewContainer];
    
    UIView* scrollContentView = [[[UIView alloc]initWithFrame:self.view.bounds]autorelease];
    //  scrollContentView.autoresizingMask = UIViewAutoresizingFlexibleSize;
    scrollContentView.sizeToFitLayoutBoxes = YES;
    scrollContentView.name = @"ScrollContentView";
    scrollContentView.layer.zPosition = 1;
    [scrollView addSubview:scrollContentView];
    
    for(CKSwipableCollectionCellAction* action in self.leftActions.actions){
        UIView* view =  [[[UIButton alloc]init]autorelease];
        view.userInteractionEnabled = NO;
        view.name = action.name;
        view.hidden = YES;
        view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [leftActionsViewContainer addSubview:view];
    }
    
    for(CKSwipableCollectionCellAction* action in self.rightActions.actions){
        UIView* view =  [[[UIButton alloc]init]autorelease];
        view.userInteractionEnabled = NO;
        view.name = action.name;
        view.hidden = YES;
        view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [rightActionsViewContainer addSubview:view];
    }
    
    [self.contentViewController prepareForReuseUsingContentView:scrollContentView contentViewCell:self.contentViewCell];
    [self.contentViewController viewDidLoad];
}


#pragma Scroll View Updates

- (void)updatesScrollViewContentSize{
    CGPoint offset = self.scrollView.contentOffset;
    
    CGSize size = [self preferredSizeConstraintToSize:CGSizeMake(self.view.bounds.size.width,MAXFLOAT)];
    [self scrollContentView].frame = CGRectMake(0,0,size.width,size.height);
    [self scrollView].frame = [self scrollContentView].frame;
    
    [self scrollView].contentSize = CGSizeMake(size.width ,size.height);
    [self scrollView].contentOffset = offset;
}

#pragma Actions Management and Layout

- (void)applyStyleToActions{
    if(self.scrollView.appliedStyle == nil || [self.scrollView.appliedStyle isEmpty]){
        [self.scrollView  findAndApplyStyleFromStylesheet:[self.contentViewController controllerStyle] propertyName:@"scrollView"];
    }
    
    if(self.leftActionsViewContainer.appliedStyle == nil || [self.leftActionsViewContainer.appliedStyle isEmpty]){
        [self.leftActionsViewContainer  findAndApplyStyleFromStylesheet:[self.contentViewController controllerStyle] propertyName:@"leftActionsViewContainer"];
    }
    
    if(self.rightActionsViewContainer.appliedStyle == nil || [self.rightActionsViewContainer.appliedStyle isEmpty]){
        [self.rightActionsViewContainer findAndApplyStyleFromStylesheet:[self.contentViewController controllerStyle] propertyName:@"rightActionsViewContainer"];
    }
    
    if(self.leftActions.setupActionGroupViewAppearance){
        self.leftActions.setupActionGroupViewAppearance(self.leftActionsViewContainer);
    }
    
    for(CKSwipableCollectionCellAction* action in self.leftActions.actions){
        if(action.setupActionViewAppearance){
            UIView* view = [self.leftActionsViewContainer viewWithKeyPath:action.name];
            action.setupActionViewAppearance((UIButton*)view);
        }
    }
    
    if(self.rightActions.setupActionGroupViewAppearance){
        self.rightActions.setupActionGroupViewAppearance(self.rightActionsViewContainer);
    }
    
    for(CKSwipableCollectionCellAction* action in self.rightActions.actions){
        if(action.setupActionViewAppearance){
            UIView* view = [self.rightActionsViewContainer viewWithKeyPath:action.name];
            action.setupActionViewAppearance((UIButton*)view);
        }
    }
}

- (void)layoutActionViews{
    
    self.leftActionsViewContainer.hidden = NO;
    self.rightActionsViewContainer.hidden = NO;
    
    NSInteger catchWidthLeft = 0;
    NSInteger maximumLeftWidth = 0;
    for(CKSwipableCollectionCellAction* action in self.leftActions.actions){
        UIView* view = [self.leftActionsViewContainer viewWithKeyPath:action.name];
        if(action.enabled){
            view.userInteractionEnabled = NO;
            CGSize size = [view sizeThatFits:self.scrollView.bounds.size];
            catchWidthLeft += size.width;
            if(size.width > maximumLeftWidth){
                maximumLeftWidth = size.width;
            }
        }else{
            view.hidden = YES;
        }
    }
    
    if(self.leftActions.style == CKSwipableCollectionCellActionGroupStyleSwipeToAction){
        self.leftActionsViewContainer.width = maximumLeftWidth > 0 ? (maximumLeftWidth + 20) : 0;
    }else{
        self.leftActionsViewContainer.width = catchWidthLeft;
    }
    
    NSInteger catchWidthRight = 0;
    NSInteger maximumRightWidth = 0;
    for(CKSwipableCollectionCellAction* action in self.rightActions.actions){
        UIView* view = [self.rightActionsViewContainer viewWithKeyPath:action.name];
        if(action.enabled){
            view.userInteractionEnabled = NO;
            CGSize size = [view sizeThatFits:self.scrollView.bounds.size];
            catchWidthRight += size.width;
            if(size.width > maximumRightWidth){
                maximumRightWidth = size.width;
            }
        }else{
            view.hidden = YES;
        }
    }
    
    
    if(self.rightActions.style == CKSwipableCollectionCellActionGroupStyleSwipeToAction){
        self.rightActionsViewContainer.width = maximumRightWidth > 0 ? (maximumRightWidth + 20) : 0;
    }else{
        self.rightActionsViewContainer.width = catchWidthRight;
    }
    
    
    self.scrollView.contentInset = UIEdgeInsetsMake(0, catchWidthLeft, 0, catchWidthRight);
    self.scrollView.contentOffset = CGPointMake(0, 0);
}

- (void)setupActionViewsBindings{
    __unsafe_unretained CKSwipableCollectionCellContentViewController* bself = self;
    
    __block BOOL needsLayoutUpdate = NO;
    
    for(CKSwipableCollectionCellAction* action in self.leftActions.actions){
        UIView* view = [self.leftActionsViewContainer viewWithKeyPath:action.name];
        if([view isKindOfClass:[UIButton class]]){
            [(UIButton*)view bindEvent:UIControlEventTouchUpInside withBlock:^{
                [bself triggerAction:action];
            }];
        }
        
        [action bind:@"enabled" withBlock:^(id value) {
            if(bself.view){
                if(bself.isAnimatingPendingAction){ needsLayoutUpdate = YES; }
                else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [bself layoutActionViews];
                    });
                }
            }
        }];
    }
    
    for(CKSwipableCollectionCellAction* action in self.rightActions.actions){
        UIView* view = [self.rightActionsViewContainer viewWithKeyPath:action.name];
        if([view isKindOfClass:[UIButton class]]){
            [(UIButton*)view bindEvent:UIControlEventTouchUpInside withBlock:^{
                [bself triggerAction:action];
            }];
        }
        
        [action bind:@"enabled" withBlock:^(id value) {
            if(bself.view){
                if(bself.isAnimatingPendingAction){ needsLayoutUpdate = YES; }
                else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [bself layoutActionViews];
                    });
                }
            }
        }];
    }
    
    [bself bind:@"isAnimatingPendingAction" withBlock:^(id value) {
        if(!bself.isAnimatingPendingAction && needsLayoutUpdate){
            needsLayoutUpdate = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [bself layoutActionViews];
            });
        }
    }];
}

- (void)dismissAllSingleActionsNonAnimated{
    if(self.leftActions.style == CKSwipableCollectionCellActionGroupStyleSwipeToAction){
        
        self.currentLeftAction = nil;
        
        for(CKSwipableCollectionCellAction* action in self.leftActions.actions){
            UIView* view = [self.leftActionsViewContainer viewWithKeyPath:action.name];
            view.frame = CGRectMake(-self.leftActionsViewContainer.width,0,self.leftActionsViewContainer.width,self.scrollView.height);
        }
    }
    
    if(self.rightActions.style == CKSwipableCollectionCellActionGroupStyleSwipeToAction){
        self.currentRightAction = nil;
        
        for(CKSwipableCollectionCellAction* action in self.rightActions.actions){
            UIView* view = [self.rightActionsViewContainer viewWithKeyPath:action.name];
            view.frame = CGRectMake(self.rightActionsViewContainer.width,0,self.rightActionsViewContainer.width,self.scrollView.height);
        }
    }
}

- (void)presentsSingleAction:(CKSwipableCollectionCellAction*)action previousAction:(CKSwipableCollectionCellAction*)previousAction left:(BOOL)left direction:(CGFloat)direction{
    UIView* view = action ? (left ? [self.leftActionsViewContainer viewWithKeyPath:action.name] : [self.rightActionsViewContainer viewWithKeyPath:action.name]) : nil;
    UIView* previousview = previousAction ? (left ? [self.leftActionsViewContainer viewWithKeyPath:previousAction.name] : [self.rightActionsViewContainer viewWithKeyPath:previousAction.name]) : nil;
 
    view.hidden = NO;
    
    if(left){
        self.currentLeftAction = action;
        view.frame = (direction < 0) ? CGRectMake(-self.leftActionsViewContainer.width,0,self.leftActionsViewContainer.width,self.scrollView.height) : CGRectMake(self.leftActionsViewContainer.width,0,self.leftActionsViewContainer.width,self.scrollView.height);
        [UIView animateWithDuration:animationDuration animations:^{
            
            view.frame = CGRectMake(0,0,self.leftActionsViewContainer.width,self.scrollView.height);
            previousview.frame = (direction < 0) ? CGRectMake(self.leftActionsViewContainer.width,0,self.leftActionsViewContainer.width,self.scrollView.height) : CGRectMake(-self.leftActionsViewContainer.width,0,self.leftActionsViewContainer.width,self.scrollView.height);
            
        }completion:^(BOOL finished) {
            previousview.hidden = YES;
        }];
    }else{
        self.currentRightAction = action;
        
        view.frame = (direction > 0) ? CGRectMake(self.rightActionsViewContainer.width,0,self.rightActionsViewContainer.width,self.scrollView.height) : CGRectMake(-self.rightActionsViewContainer.width,0,self.rightActionsViewContainer.width,self.scrollView.height);
        [UIView animateWithDuration:animationDuration animations:^{
            
            view.frame = CGRectMake(0,0,self.rightActionsViewContainer.width,self.scrollView.height);
            previousview.frame = (direction > 0) ? CGRectMake(-self.rightActionsViewContainer.width,0,self.rightActionsViewContainer.width,self.scrollView.height) : CGRectMake(self.rightActionsViewContainer.width,0,self.rightActionsViewContainer.width,self.scrollView.height);
            
        }completion:^(BOOL finished) {
            previousview.hidden = YES;
        }];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat scrolledAmount = scrollView.contentOffset.x;
    
    self.leftActionsViewContainer.frame = CGRectMake(scrolledAmount,0,self.leftActionsViewContainer.width,scrollView.height);
    self.rightActionsViewContainer.frame = CGRectMake(scrollView.bounds.size.width - self.rightActionsViewContainer.width + scrolledAmount,0,self.rightActionsViewContainer.width,scrollView.height);
    
    if(self.isAnimatingPendingAction)
        return;
    
   // self.leftActionsViewContainer.hidden = YES;
   // self.rightActionsViewContainer.hidden = YES;
    
    if(self.leftActions.style == CKSwipableCollectionCellActionGroupStyleSwipeToAction){
        NSInteger accumulatedWidth = 0;
        
        CKSwipableCollectionCellAction* actionToPresent = nil;
        
        if(scrolledAmount < 0 && scrollView.tracking){
            self.leftActionsViewContainer.hidden = NO;
            for(CKSwipableCollectionCellAction* action in self.leftActions.actions){
                if(action.enabled){
                    accumulatedWidth += self.leftActionsViewContainer.width;
                    
                    if( fabs(scrolledAmount) >= accumulatedWidth){
                        actionToPresent = action;
                    }
                }
            }
        }
        
        if( self.currentLeftAction != actionToPresent){
            [self presentsSingleAction:actionToPresent previousAction:self.currentLeftAction left:YES direction:(scrolledAmount - self.lastScrollOffset.x)];
        }
    }else{
        self.leftActionsViewContainer.hidden = NO;
        NSInteger accumulatedWidth = 0;
        for(CKSwipableCollectionCellAction* action in self.leftActions.actions){
            if(action.enabled){
                UIView* view = [self.leftActionsViewContainer viewWithKeyPath:action.name];
                CGSize size = [view sizeThatFits:self.scrollView.bounds.size];
                view.frame = CGRectMake(accumulatedWidth,0,size.width,scrollView.height);
                view.hidden = (view.frame.origin.x + view.frame.size.width < 0);
                accumulatedWidth += view.width;
            }
        }
    }
    
    if(self.rightActions.style == CKSwipableCollectionCellActionGroupStyleSwipeToAction){
        NSInteger accumulatedWidth = 0;
        
        CKSwipableCollectionCellAction* actionToPresent = nil;
        
        if(scrolledAmount > 0 && scrollView.tracking){
            self.rightActionsViewContainer.hidden = NO;
            for(CKSwipableCollectionCellAction* action in self.rightActions.actions){
                if(action.enabled){
                    accumulatedWidth += self.rightActionsViewContainer.width;
                    
                    if( fabs(scrolledAmount) >= accumulatedWidth){
                        actionToPresent = action;
                    }
                }
            }
        }
        
        if( self.currentRightAction != actionToPresent){
            [self presentsSingleAction:actionToPresent previousAction:self.currentRightAction left:NO direction:(scrolledAmount - self.lastScrollOffset.x)];
        }
    }else{
        self.rightActionsViewContainer.hidden = NO;
        NSInteger accumulatedWidth = 0;
        for(CKSwipableCollectionCellAction* action in self.rightActions.actions){
            if(action.enabled){
                UIView* view = [self.rightActionsViewContainer viewWithKeyPath:action.name];
                CGSize size = [view sizeThatFits:self.scrollView.bounds.size];
                
                view.frame = CGRectMake(accumulatedWidth,0,size.width,scrollView.height);
                
                view.hidden = (view.frame.origin.x  > self.scrollView.bounds.size.width);
                accumulatedWidth += view.width;
            }
        }
    }
    
    self.lastScrollOffset = scrollView.contentOffset;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    if(self.isAnimatingPendingAction)
        return;
    
    //Break any additional scrolling animation
    scrollView.contentOffset = scrollView.contentOffset;
    *targetContentOffset = scrollView.contentOffset;
    
    CGFloat scrolledAmount = scrollView.contentOffset.x;
    
    if((self.leftActions.style == CKSwipableCollectionCellActionGroupStyleSwipeToAction && (scrolledAmount < 0 || velocity.x < 0))
       || (self.rightActions.style == CKSwipableCollectionCellActionGroupStyleSwipeToAction && (scrolledAmount > 0 || velocity.x > 0))){
        
        if(self.currentLeftAction && self.currentLeftAction.action){
            [self triggerAction:self.currentLeftAction];
        }else if(self.currentRightAction && self.currentRightAction.action){
            [self triggerAction:self.currentRightAction];
        }else{
            *targetContentOffset = CGPointZero;
            
            // Need to call this subsequently to remove flickering. Strange.
            dispatch_async(dispatch_get_main_queue(), ^{
                [scrollView setContentOffset:CGPointZero animated:YES];
            });
            
            for(CKSwipableCollectionCellAction* action in self.leftActions.actions){
                UIView* view = [self.leftActionsViewContainer viewWithKeyPath:action.name];
                view.userInteractionEnabled = NO;
            }
            
            for(CKSwipableCollectionCellAction* action in self.rightActions.actions){
                UIView* view = [self.rightActionsViewContainer viewWithKeyPath:action.name];
                view.userInteractionEnabled = NO;
            }
        }
    }else if(   self.rightActions.style == CKSwipableCollectionCellActionGroupStyleSwipeToReveal
             && scrolledAmount > 0
             && ( (velocity.x == 0 && fabs(scrolledAmount) > (self.rightActionsViewContainer.width / 2))  || velocity.x > 0 )
            ){
        *targetContentOffset = CGPointMake(self.rightActionsViewContainer.width,0);
        
        if(velocity.x < 0 ){
            // Need to call this subsequently to remove flickering. Strange.
            dispatch_async(dispatch_get_main_queue(), ^{
                [scrollView setContentOffset:CGPointMake(self.rightActionsViewContainer.width,0) animated:YES];
            });
        }
        
        for(CKSwipableCollectionCellAction* action in self.rightActions.actions){
            UIView* view = [self.rightActionsViewContainer viewWithKeyPath:action.name];
            view.userInteractionEnabled = YES;
        }
    }else if(  self.leftActions.style == CKSwipableCollectionCellActionGroupStyleSwipeToReveal
             && scrolledAmount < 0
             && ( (velocity.x == 0 && fabs(scrolledAmount) > (self.leftActionsViewContainer.width / 2))  || velocity.x < 0 )
            ){
        *targetContentOffset = CGPointMake(-self.leftActionsViewContainer.width,0);
        
        if(velocity.x > 0 ){
            // Need to call this subsequently to remove flickering. Strange.
            dispatch_async(dispatch_get_main_queue(), ^{
                [scrollView setContentOffset:CGPointMake(-self.leftActionsViewContainer.width,0) animated:YES];
            });
        }
        
        for(CKSwipableCollectionCellAction* action in self.leftActions.actions){
            UIView* view = [self.leftActionsViewContainer viewWithKeyPath:action.name];
            view.userInteractionEnabled = YES;
        }
    }else{
        *targetContentOffset = CGPointZero;
        
        for(CKSwipableCollectionCellAction* action in self.leftActions.actions){
            UIView* view = [self.leftActionsViewContainer viewWithKeyPath:action.name];
            view.userInteractionEnabled = NO;
        }
        
        for(CKSwipableCollectionCellAction* action in self.rightActions.actions){
            UIView* view = [self.rightActionsViewContainer viewWithKeyPath:action.name];
            view.userInteractionEnabled = NO;
        }
        
        // Need to call this subsequently to remove flickering. Strange.
        dispatch_async(dispatch_get_main_queue(), ^{
            [scrollView setContentOffset:CGPointZero animated:YES];
        });
    }
}

- (void)triggerAction:(CKSwipableCollectionCellAction*)action{
    
    
    //launch actionAnimation() then calls action()
    if(action.actionAnimation == nil){
        if(action.action){
            action.action();
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.currentLeftAction = nil;
            self.currentRightAction = nil;
            self.isAnimatingPendingAction = NO;
            [self.scrollView setContentOffset:CGPointZero animated:YES];
        });
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            //get the view in left or right container
            UIButton* view = nil;
            NSInteger index = [self.leftActions.actions indexOfObjectIdenticalTo:action];
            if(index != NSNotFound){
                view = [self.leftActionsViewContainer viewWithKeyPath:action.name];
                self.rightActionsViewContainer.hidden = YES;
            }else{
                view = [self.rightActionsViewContainer viewWithKeyPath:action.name];
                self.leftActionsViewContainer.hidden = YES;
            }
            
            self.isAnimatingPendingAction = YES;
            
            action.actionAnimation(self,view,^(){
                if(action.action){
                    action.action();
                }
                
                //Waiting for scrolling back to ZERO
                [self performBlock:^{
                    self.rightActionsViewContainer.hidden = NO;
                    self.leftActionsViewContainer.hidden = NO;
                    [self dismissAllSingleActionsNonAnimated];
                    self.isAnimatingPendingAction = NO;
                } afterDelay:animationDuration];
            });
        });
    }
}

#pragma mark Manages tap gesture

- (void)setupTapGestureRecognizer{
    __unsafe_unretained CKSwipableCollectionCellContentViewController* bself = self;
    
    UITapGestureRecognizer* gesture = [[[UITapGestureRecognizer alloc]initWithBlock:^(UIGestureRecognizer *gestureRecognizer) {
        [bself handleTapGesture:gestureRecognizer];
    }shouldBeginBlock:^BOOL(UIGestureRecognizer *gestureRecognizer) {
        CGPoint location = [gestureRecognizer locationInView:gestureRecognizer.view];
        UIView* v = [gestureRecognizer.view hitTest:location withEvent:nil];
        if([v isKindOfClass:[UIControl class]]){
            return NO;
        }
        return YES;
    }]autorelease];
    
    
    UIGestureRecognizer* oldGesture = [self.contentViewController.view.gestureRecognizers firstObject];
    if(oldGesture && [oldGesture isKindOfClass:[UITapGestureRecognizer class]]){
        [self.contentViewController.view removeGestureRecognizer:oldGesture];
    }
    [self.contentViewController.view addGestureRecognizer:gesture];
}

- (void)handleTapGesture:(UIGestureRecognizer*)gestureRecognizer{
    if(self.isAnimatingPendingAction)
        return;
    
    if(self.scrollView.contentOffset.x != 0){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.scrollView setContentOffset:CGPointZero animated:YES];
        });
    }else{
        if([self.contentView isKindOfClass:[UITableView class]]){
            UITableView* tableView = (UITableView*)self.contentView;
            if ([tableView.delegate respondsToSelector:@selector(tableView:willSelectRowAtIndexPath:)]) {
                [tableView.delegate tableView:tableView willSelectRowAtIndexPath:self.indexPath];
            }
            
            [tableView selectRowAtIndexPath:self.indexPath animated:YES scrollPosition: UITableViewScrollPositionNone];
            
            if ([tableView.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
                [tableView.delegate tableView:tableView didSelectRowAtIndexPath:self.indexPath];
            }
        }else if([self.contentView isKindOfClass:[UICollectionView class]]){
            UICollectionView* collectionView = (UICollectionView*)self.contentView;
            
            [collectionView selectItemAtIndexPath:self.indexPath animated:YES scrollPosition: UICollectionViewScrollPositionNone];
            
            if ([collectionView.delegate respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)]) {
                [collectionView.delegate collectionView:collectionView didSelectItemAtIndexPath:self.indexPath];
            }
        }
    }
}

@end



@implementation CKSwipableCollectionCellAction

- (void)dealloc{
    [_name release];
    [_action release];
    [_setupActionViewAppearance release];
    [_actionAnimation release];
    [super dealloc];
}

- (id)initWithName:(NSString*)theName action:(void(^)())theAction{
    return [self initWithName:theName animationStyle:CKSwipableCollectionCellActionAnimationStyleNone action:theAction];
}

- (id)initWithName:(NSString*)theName animationStyle:(CKSwipableCollectionCellActionAnimationStyle)animationStyle action:(void(^)())theAction{
    self = [super init];
    self.name = theName;
    self.action = theAction;
    self.enabled = YES;
    [self setAnimationStyle:animationStyle];
    return self;
}

+ (CKSwipableCollectionCellAction*)actionWithName:(NSString*)name action:(void(^)())action{
    return [[[CKSwipableCollectionCellAction alloc]initWithName:name action:action]autorelease];
}

+ (CKSwipableCollectionCellAction*)actionWithName:(NSString*)name animationStyle:(CKSwipableCollectionCellActionAnimationStyle)animationStyle action:(void(^)())action{
    return [[[CKSwipableCollectionCellAction alloc]initWithName:name animationStyle:animationStyle action:action]autorelease];
}

- (void)setAnimationStyle:(CKSwipableCollectionCellActionAnimationStyle)style{
    switch(style){
        case CKSwipableCollectionCellActionAnimationStyleNone:{
            self.actionAnimation = nil;
            break;
        }
            
        case CKSwipableCollectionCellActionAnimationStyleBounceAndHiglight:{
            [self setupBoundAndHighlightAnimation];
            break;
        }
            
        case CKSwipableCollectionCellActionAnimationStyleSwipeOutContentLeft:{
            [self setupSwipeContentAnimationToLeft:YES];
            break;
        }
            
        case CKSwipableCollectionCellActionAnimationStyleSwipeOutContentRight:{
            [self setupSwipeContentAnimationToLeft:NO];
            break;
        }
    }
}

- (void)setupBoundAndHighlightAnimation{
    self.actionAnimation = ^(CKSwipableCollectionCellContentViewController* controller, UIButton* actionView, void(^endAnimation)() ){
        BOOL right = [actionView superview].x > 0;
        BOOL bounceEnabled = controller.scrollView.bounces;
        controller.scrollView.bounces = NO;
        
        [UIView animateKeyframesWithDuration:animationDuration delay:0 options:0 animations:^{
            [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.5 animations:^{
                [controller.scrollView setContentOffset:CGPointMake(right ? controller.rightActionsViewContainer.width : -controller.leftActionsViewContainer.width , 0)];
            }];
            [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.4 animations:^{
                [controller.scrollView setContentOffset:CGPointMake((right ? controller.rightActionsViewContainer.width : -controller.leftActionsViewContainer.width) + ((right ? 1 : -1) * (fabs(controller.scrollView.contentOffset.x)) * bounceVsDistanceRatio), 0)];
            }];
            [UIView addKeyframeWithRelativeStartTime:0.9 relativeDuration:0.1 animations:^{
                [controller.scrollView setContentOffset:CGPointMake(right ? controller.rightActionsViewContainer.width : -controller.leftActionsViewContainer.width , 0)];
            }];
        } completion:^(BOOL finished) {
            [controller.scrollView setContentOffset:CGPointMake(right ? controller.rightActionsViewContainer.width : -controller.leftActionsViewContainer.width , 0)];
            
            [UIView animateWithDuration:animationDuration animations:^{
                actionView.highlighted = YES;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:animationDuration animations:^{
                    actionView.highlighted = NO;
                } completion:^(BOOL finished) {
                    controller.scrollView.bounces = bounceEnabled;
                    [controller.scrollView setContentOffset:CGPointZero animated:YES];
                    endAnimation();
                }];
                
            }];
        }];
    };
}

- (void)setupSwipeContentAnimationToLeft:(BOOL)left{
    self.actionAnimation = ^(CKSwipableCollectionCellContentViewController* controller, UIButton* actionView, void(^endAnimation)() ){
        UIEdgeInsets insets = controller.scrollView.contentInset;
        controller.scrollView.contentInset = UIEdgeInsetsMake(insets.top, insets.left + (left ?  0 : controller.scrollView.width),
                                                              insets.bottom, insets.right + (left ? controller.scrollView.width : 0));
        
        [UIView animateWithDuration:.4 animations:^{
            controller.scrollView.contentOffset = left ? CGPointMake(controller.scrollView.width,0) : CGPointMake(-controller.scrollView.width,0);
        } completion:^(BOOL finished) {
            endAnimation();
        }];
    };
}


@end

@implementation CKSwipableCollectionCellActionGroup

- (void)dealloc{
    [_actions release];
    [_setupActionGroupViewAppearance release];
    [super dealloc];
}

- (id)initWithStyle:(CKSwipableCollectionCellActionGroupStyle)theStyle actions:(NSArray*)theActions{
    self = [super init];
    self.style = theStyle;
    self.actions = theActions;
    return self;
}

+ (CKSwipableCollectionCellActionGroup*)actionGroupWithStyle:(CKSwipableCollectionCellActionGroupStyle)style actions:(NSArray*)actions{
    return [[[CKSwipableCollectionCellActionGroup alloc]initWithStyle:style actions:actions]autorelease];
}

@end


