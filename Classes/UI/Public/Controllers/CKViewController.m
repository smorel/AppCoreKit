//
//  CKViewController.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKViewController.h"
#import "UIViewController+Style.h"
#import "CKStyleManager.h"
#import "CKDebug.h"
#include <execinfo.h>
#import "NSObject+Bindings.h"
#import "CKObject.h"
#import <QuartzCore/QuartzCore.h>
#import "CKVersion.h"
#import "CKStyle+Parsing.h"
#import "UIView+Style.h"
#import "CKRuntime.h"
#import "CKContainerViewController.h"
#import "CKConfiguration.h"
#import "UINavigationController+Style.h"
#import "Layout.h"
#import "UIView+Positioning.h"
#import "CKResourceManager.h"
#import "CKResourceDependencyContext.h"
#import <objc/runtime.h>
#import "CKReusableViewController.h"
#import "CKSectionContainer.h"


@interface UIViewController (AppCoreKit_Private)<UIGestureRecognizerDelegate>
@property(nonatomic,retain) NSString* navigationItemsBindingContext;
@property(nonatomic,retain) NSString* navigationTitleBindingContext;
@property(nonatomic,assign) BOOL styleHasBeenApplied;
@property (nonatomic, assign, readwrite) CKViewControllerState state;
@property(nonatomic,retain,readwrite) CKInlineDebuggerController* inlineDebuggerController;

- (void)adjustStyleViewWithToolbarHidden:(BOOL)hidden animated:(BOOL)animated;

@end



@implementation UIViewController (AppCoreKit_Private)


static char UIViewControllerNavigationItemsBindingContextKey;
- (void)setNavigationItemsBindingContext:(NSString *)navigationItemsBindingContext{
    objc_setAssociatedObject(self, &UIViewControllerNavigationItemsBindingContextKey, navigationItemsBindingContext, OBJC_ASSOCIATION_RETAIN);
}

- (NSString*)navigationItemsBindingContext{
    return objc_getAssociatedObject(self, &UIViewControllerNavigationItemsBindingContextKey);
}

static char UIViewControllerNavigationTitleBindingContextKey;
- (void)setNavigationTitleBindingContext:(NSString *)navigationTitleBindingContext{
    objc_setAssociatedObject(self, &UIViewControllerNavigationTitleBindingContextKey, navigationTitleBindingContext, OBJC_ASSOCIATION_RETAIN);
}

- (NSString*)navigationTitleBindingContext{
    return objc_getAssociatedObject(self, &UIViewControllerNavigationTitleBindingContextKey);
    
}

static char UIViewControllerStyleHasBeenAppliedKey;
- (void)setStyleHasBeenApplied:(BOOL)styleHasBeenApplied{
    objc_setAssociatedObject(self, &UIViewControllerStyleHasBeenAppliedKey, @(styleHasBeenApplied), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)styleHasBeenApplied{
    id value = objc_getAssociatedObject(self, &UIViewControllerStyleHasBeenAppliedKey);
    return value ? [value boolValue] : NO;
}

static char UIViewControllerStateKey;
- (void)setState:(CKViewControllerState)state{
    objc_setAssociatedObject(self, &UIViewControllerStateKey, @(state), OBJC_ASSOCIATION_RETAIN);
}

- (CKViewControllerState)state{
    id value = objc_getAssociatedObject(self, &UIViewControllerStateKey);
    return value ? [value integerValue] : CKViewControllerStateNone;
}

- (void)stateExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"CKViewControllerState",
                                                 CKViewControllerStateNone,
                                                 CKViewControllerStateWillAppear,
                                                 CKViewControllerStateDidAppear,
                                                 CKViewControllerStateWillDisappear,
                                                 CKViewControllerStateDidDisappear,
                                                 CKViewControllerStateDidUnload,
                                                 CKViewControllerStateDidLoad);
}

static char UIViewControllerInlineDebuggerControllerKey;
- (void)setInlineDebuggerController:(CKInlineDebuggerController *)inlineDebuggerController{
    objc_setAssociatedObject(self, &UIViewControllerInlineDebuggerControllerKey, inlineDebuggerController, OBJC_ASSOCIATION_RETAIN);
}

- (CKInlineDebuggerController*)inlineDebuggerController{
    return objc_getAssociatedObject(self, &UIViewControllerInlineDebuggerControllerKey);
}

- (void)adjustStyleViewWithToolbarHidden:(BOOL)hidden animated:(BOOL)animated{
    if([[self.view subviews]count] <= 0)
        return;
    
    if(self.isViewDisplayed){
        UIView* v0 = [[self.view subviews]objectAtIndex:0];
        if([v0 isKindOfClass:[CKStyleView class]]){
            if(hidden){
                v0.frame = self.view.bounds;
            }else{
                CGFloat toolbarHeight = self.navigationController.toolbar.bounds.size.height;
                v0.frame = CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height+toolbarHeight);
            }
        }
    }
}

@end




@implementation UIViewController (AppCoreKit)

@dynamic viewWillAppearBlock;

static char UIViewControllerViewWillAppearBlockKey;
- (void)setViewWillAppearBlock:(CKViewControllerAnimatedBlock)block{
    objc_setAssociatedObject(self, &UIViewControllerViewWillAppearBlockKey, [block copy], OBJC_ASSOCIATION_RETAIN);
}

- (CKViewControllerAnimatedBlock)viewWillAppearBlock{
    return objc_getAssociatedObject(self, &UIViewControllerViewWillAppearBlockKey);
}

@dynamic viewWillAppearEndBlock;

static char UIViewControllerViewWillAppearEndBlockKey;
- (void)setViewWillAppearEndBlock:(CKViewControllerAnimatedBlock)block{
    objc_setAssociatedObject(self, &UIViewControllerViewWillAppearEndBlockKey, [block copy], OBJC_ASSOCIATION_RETAIN);
}

- (CKViewControllerAnimatedBlock)viewWillAppearEndBlock{
    return objc_getAssociatedObject(self, &UIViewControllerViewWillAppearEndBlockKey);
}

@dynamic viewDidAppearBlock;

static char UIViewControllerViewDidAppearBlockKey;
- (void)setViewDidAppearBlock:(CKViewControllerAnimatedBlock)block{
    objc_setAssociatedObject(self, &UIViewControllerViewDidAppearBlockKey, [block copy], OBJC_ASSOCIATION_RETAIN);
}

- (CKViewControllerAnimatedBlock)viewDidAppearBlock{
    return objc_getAssociatedObject(self, &UIViewControllerViewDidAppearBlockKey);
}

@dynamic viewWillDisappearBlock;

static char UIViewControllerViewWillDisappearBlockKey;
- (void)setViewWillDisappearBlock:(CKViewControllerAnimatedBlock)block{
    objc_setAssociatedObject(self, &UIViewControllerViewWillDisappearBlockKey, [block copy], OBJC_ASSOCIATION_RETAIN);
}

- (CKViewControllerAnimatedBlock)viewWillDisappearBlock{
    return objc_getAssociatedObject(self, &UIViewControllerViewWillDisappearBlockKey);
}

@dynamic viewDidDisappearBlock;

static char UIViewControllerViewDidDisappearBlockKey;
- (void)setViewDidDisappearBlock:(CKViewControllerAnimatedBlock)block{
    objc_setAssociatedObject(self, &UIViewControllerViewDidDisappearBlockKey, [block copy], OBJC_ASSOCIATION_RETAIN);
}

- (CKViewControllerAnimatedBlock)viewDidDisappearBlock{
    return objc_getAssociatedObject(self, &UIViewControllerViewDidDisappearBlockKey);
}

@dynamic orientationChangeBlock;

static char UIViewControllerOrientationChangeBlockKey;
- (void)setOrientationChangeBlock:(CKViewControllerOrientationBlock)block{
    objc_setAssociatedObject(self, &UIViewControllerOrientationChangeBlockKey, [block copy], OBJC_ASSOCIATION_RETAIN);
}

- (CKViewControllerOrientationBlock)orientationChangeBlock{
    return objc_getAssociatedObject(self, &UIViewControllerOrientationChangeBlockKey);
}

@dynamic viewDidLoadBlock;

static char UIViewControllerViewDidLoadBlockKey;
- (void)setViewDidLoadBlock:(CKViewControllerBlock)block{
    objc_setAssociatedObject(self, &UIViewControllerViewDidLoadBlockKey, [block copy], OBJC_ASSOCIATION_RETAIN);
}

- (CKViewControllerBlock)viewDidLoadBlock{
    return objc_getAssociatedObject(self, &UIViewControllerViewDidLoadBlockKey);
}

@dynamic viewDidUnloadBlock;

static char UIViewControllerViewDidUnloadBlockKey;
- (void)setViewDidUnloadBlock:(CKViewControllerBlock)block{
    objc_setAssociatedObject(self, &UIViewControllerViewDidUnloadBlockKey, [block copy], OBJC_ASSOCIATION_RETAIN);
}

- (CKViewControllerBlock)viewDidUnloadBlock{
    return objc_getAssociatedObject(self, &UIViewControllerViewDidUnloadBlockKey);
}

@dynamic deallocBlock;

static char UIViewControllerDeallocBlockKey;
- (void)setDeallocBlock:(CKViewControllerBlock)block{
    objc_setAssociatedObject(self, &UIViewControllerDeallocBlockKey, [block copy], OBJC_ASSOCIATION_COPY);
}

- (CKViewControllerBlock)deallocBlock{
    return objc_getAssociatedObject(self, &UIViewControllerDeallocBlockKey);
}


@dynamic editingBlock;

static char UIViewControllerEditingBlockKey;
- (void)setEditingBlock:(CKViewControllerEditingBlock)block{
    objc_setAssociatedObject(self, &UIViewControllerEditingBlockKey, [block copy], OBJC_ASSOCIATION_RETAIN);
}

- (CKViewControllerEditingBlock)editingBlock{
    return objc_getAssociatedObject(self, &UIViewControllerEditingBlockKey);
}



@dynamic isViewDisplayed;

- (BOOL)isViewDisplayed{
    if(![self isViewLoaded])
        return NO;
    
    return self.state & CKViewControllerStateWillAppear || self.state & CKViewControllerStateDidAppear;
}

@dynamic supportedInterfaceOrientations;

static char UIViewControllerSupportedInterfaceOrientationKey;
- (void)setSupportedInterfaceOrientations:(CKInterfaceOrientation)supportedInterfaceOrientations{
    objc_setAssociatedObject(self, &UIViewControllerSupportedInterfaceOrientationKey, @(supportedInterfaceOrientations), OBJC_ASSOCIATION_RETAIN);
}

- (CKInterfaceOrientation)supportedInterfaceOrientations{
    id value = objc_getAssociatedObject(self, &UIViewControllerSupportedInterfaceOrientationKey);
    return value ? [value integerValue] : CKInterfaceOrientationAll;
}

- (void)supportedInterfaceOrientationsExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
#ifdef __IPHONE_6_0
    attributes.enumDescriptor = CKBitMaskDefinition(@"CKInterfaceOrientation",
                                                    CKInterfaceOrientationPortrait,
                                                    CKInterfaceOrientationLandscape,
                                                    UIInterfaceOrientationMaskPortrait,
                                                    UIInterfaceOrientationMaskLandscape,
                                                    CKInterfaceOrientationAll);
#else
    attributes.enumDescriptor = CKBitMaskDefinition(@"CKInterfaceOrientation",
                                                    CKInterfaceOrientationPortrait,
                                                    CKInterfaceOrientationLandscape,
                                                    CKInterfaceOrientationAll);
#endif
}






/**
 */
@dynamic preferredStatusBarStyle;

static char UIViewControllerPreferredStatusBarStyleKey;
- (void)setPreferredStatusBarStyle:(UIStatusBarStyle)style{
    objc_setAssociatedObject(self, &UIViewControllerPreferredStatusBarStyleKey, @(style), OBJC_ASSOCIATION_RETAIN);
}

- (UIStatusBarStyle)AppCoreKit_preferredStatusBarStyle{
    id value = objc_getAssociatedObject(self, &UIViewControllerPreferredStatusBarStyleKey);
    return value ? [value integerValue] : UIStatusBarStyleDefault;
}

- (void)preferredStatusBarStyleExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"UIStatusBarStyle",
                                                 UIStatusBarStyleDefault,
                                                 UIStatusBarStyleLightContent,
                                                 UIStatusBarStyleBlackTranslucent,
                                                 UIStatusBarStyleBlackOpaque );
}


/**
 */
@dynamic preferredStatusBarUpdateAnimation;

static char UIViewControllerPreferredStatusBarUpdateAnimationKey;
- (void)setPreferredStatusBarUpdateAnimation:(UIStatusBarAnimation)animation{
    objc_setAssociatedObject(self, &UIViewControllerPreferredStatusBarUpdateAnimationKey, @(animation), OBJC_ASSOCIATION_RETAIN);
}

- (UIStatusBarAnimation)AppCoreKit_preferredStatusBarUpdateAnimation{
    id value = objc_getAssociatedObject(self, &UIViewControllerPreferredStatusBarUpdateAnimationKey);
    return value ? [value integerValue] : UIStatusBarAnimationFade;
}

- (void)preferredStatusBarUpdateAnimationExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"UIStatusBarAnimation",
                                                 UIStatusBarAnimationNone,
                                                 UIStatusBarAnimationFade,
                                                 UIStatusBarAnimationSlide );
}


/**
 */
@dynamic prefersStatusBarHidden;

static char UIViewControllerPrefersStatusBarHiddenKey;
- (void)setPrefersStatusBarHidden:(BOOL)hidden{
    objc_setAssociatedObject(self, &UIViewControllerPrefersStatusBarHiddenKey, @(hidden), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)AppCoreKit_prefersStatusBarHidden{
    id value = objc_getAssociatedObject(self, &UIViewControllerPrefersStatusBarHiddenKey);
    return value ? [value boolValue] : NO;
}



- (void)postInit {	
    self.styleHasBeenApplied = NO;
    self.preferredStatusBarStyle = UIStatusBarStyleDefault;
    self.prefersStatusBarHidden = NO;
    self.preferredStatusBarUpdateAnimation = UIStatusBarAnimationFade;
    
    self.navigationItemsBindingContext = [NSString stringWithFormat:@"<%p>_navigationItems",self];
    self.navigationTitleBindingContext = [NSString stringWithFormat:@"<%p>_navigationTitle",self];
    self.supportedInterfaceOrientations = CKInterfaceOrientationAll;
    self.state = CKViewControllerStateNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(styleManagerDidUpdate:) name:CKStyleManagerDidReloadNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toolbarGetsDisplayed:) name:UINavigationControllerWillDisplayToolbar object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toolbarGetsHidden:) name:UINavigationControllerWillHideToolbar object:nil];
}



- (id)init {
    return [self initWithNibName:nil bundle:nil];
}

- (id)AppCoreKit_initWithCoder:(NSCoder *)coder {
    self = [self AppCoreKit_initWithCoder:coder];
    if (self) {
        [self postInit];
    }
    return self;
}

- (id)AppCoreKit_initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [self AppCoreKit_initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		[self postInit];
	}
	return self;
}

- (void)AppCoreKit_dealloc{
    [NSObject removeAllBindingsForContext:self.navigationItemsBindingContext];
    [NSObject removeAllBindingsForContext:self.navigationTitleBindingContext];
    [self clearBindingsContext];
    if([self isViewLoaded]){
        [self.view clearBindingsContext];
    }
    
    if(self.deallocBlock){
        self.deallocBlock(self);
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CKStyleManagerDidReloadNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UINavigationControllerWillDisplayToolbar object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UINavigationControllerWillHideToolbar object:nil];
    
    self.viewDidLoadBlock = nil;
    self.viewWillAppearBlock = nil;
    self.viewDidAppearBlock = nil;
    self.viewWillDisappearBlock = nil;
    self.viewDidDisappearBlock = nil;
    self.deallocBlock = nil;
    self.orientationChangeBlock = nil;
    self.leftButton = nil;
    self.rightButton = nil;
    self.viewDidUnloadBlock = nil;
    self.viewWillAppearEndBlock = nil;
    
	[self AppCoreKit_dealloc];
}

- (NSMutableDictionary*)stylesheet{
    return [self controllerStyle];
}

- (void)styleManagerDidUpdate:(NSNotification*)notification{
    if(notification.object == [self styleManager]){
        [self resourceManagerReloadUI];
    }
}

- (void)AppCoreKit_resourceManagerReloadUI{
    self.styleHasBeenApplied = NO;
    [self AppCoreKit_resourceManagerReloadUI];
}

+ (id)controller{
	return [[[[self class]alloc]init]autorelease];
}

+ (id)controllerWithName:(NSString*)name{
	CKViewController* controller = [[[[self class]alloc]init]autorelease];
    controller.name = name;
    return controller;
}


+ (id)controllerWithStylesheetFileName:(NSString*)stylesheetFileName{
    id c = [[self class]controller];
    [c setStylesheetFileName:stylesheetFileName];
    return c;
}

+ (id)controllerWithName:(NSString*)name stylesheetFileName:(NSString*)stylesheetFileName{
    id c = [[self class]controllerWithName:name];
    [c setStylesheetFileName:stylesheetFileName];
    return c;
}

#pragma mark - Style Management

- (void)applyStyleForLeftBarButtonItem{
    if([self.styleManager isEmpty])
        return;

    
    UIBarButtonItem* leftBarButtonItem = self.navigationItem.leftBarButtonItem ;
    if([CKOSVersion() floatValue] >= 7){
        for(UIBarButtonItem* item in self.navigationItem.leftBarButtonItems){
            if(item.width == -9)//negative spacer
            continue;
            leftBarButtonItem = item;
            break;
        }
    }
    
    
    if(leftBarButtonItem){
        NSMutableDictionary* controllerStyle = [self controllerStyle];
        NSMutableDictionary* navControllerStyle = [controllerStyle styleForObject:self.navigationController  propertyName:@"navigationController"];
        NSMutableDictionary* navBarStyle = [navControllerStyle styleForObject:self.navigationController  propertyName:@"navigationBar"];
        
        NSMutableDictionary* barItemStyle = [navBarStyle styleForObject:leftBarButtonItem propertyName:@"leftBarButtonItem"];
        
        //This weird steps are needed to avoid super views layout to be called when setting the styles !
        UIBarButtonItem* item = leftBarButtonItem;
        
        self.navigationItem.leftBarButtonItem = nil;
        if([CKOSVersion() floatValue] >= 7){
            self.navigationItem.leftBarButtonItems = @[];
        }
        
        [item applyStyle:barItemStyle];
        
        if([CKOSVersion() floatValue] >= 7){
            UIBarButtonItem *negativeSpacer = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                            target:nil action:nil]autorelease];
            negativeSpacer.width = -9;
            [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, item, nil]];
        }else{
            self.navigationItem.leftBarButtonItem = item;
        }
        
        //HACK for versions before 4.2 due to the fact that setting a custom view on a UIBarButtonItem after it has been set in the navigationItem do not work.
        if([CKOSVersion() floatValue]< 4.2){
            UIBarButtonItem* bu = self.navigationItem.leftBarButtonItem;
            self.navigationItem.leftBarButtonItem = nil;
            [self.navigationItem setLeftBarButtonItem:bu animated:YES];
        }
    }
}

- (void)applyStyleForRightBarButtonItem{
    if([self.styleManager isEmpty])
        return;
    
    
    UIBarButtonItem* rightBarButtonItem = self.navigationItem.rightBarButtonItem ;
    if([CKOSVersion() floatValue] >= 7){
        for(UIBarButtonItem* item in self.navigationItem.rightBarButtonItems){
            if(item.width == -9)//negative spacer
            continue;
            rightBarButtonItem = item;
            break;
        }
    }
    
    if(rightBarButtonItem){
        NSMutableDictionary* controllerStyle = [self controllerStyle];
        NSMutableDictionary* navControllerStyle = [controllerStyle styleForObject:self.navigationController  propertyName:@"navigationController"];
        NSMutableDictionary* navBarStyle = [navControllerStyle styleForObject:self.navigationController  propertyName:@"navigationBar"];
        
        NSMutableDictionary* barItemStyle = [navBarStyle styleForObject:rightBarButtonItem propertyName:@"rightBarButtonItem"];
        
        //This weird steps are needed to avoid super views layout to be called when setting the styles !
        UIBarButtonItem* item = rightBarButtonItem;
        
        self.navigationItem.rightBarButtonItem = nil;
        if([CKOSVersion() floatValue] >= 7){
            self.navigationItem.rightBarButtonItems = @[];
        }
        
        [item applyStyle:barItemStyle];
        
        if([CKOSVersion() floatValue] >= 7){
            UIBarButtonItem *negativeSpacer = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                            target:nil action:nil]autorelease];
            negativeSpacer.width = -9;
            [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, item, nil]];
        }else{
            self.navigationItem.rightBarButtonItem = item;
        }
        
        //HACK for versions before 4.2 due to the fact that setting a custom view on a UIBarButtonItem after it has been set in the navigationItem do not work.
        if([CKOSVersion() floatValue]< 4.2){
            UIBarButtonItem* bu = self.navigationItem.rightBarButtonItem;
            self.navigationItem.rightBarButtonItem = nil;
            [self.navigationItem setRightBarButtonItem:bu animated:YES];
        }
    }
}

- (void)applyStyleForBackBarButtonItem{
    if([self.styleManager isEmpty])
        return;
    
    if(self.navigationItem.backBarButtonItem){
        NSMutableDictionary* controllerStyle = [self controllerStyle];
        NSMutableDictionary* navControllerStyle = [controllerStyle styleForObject:self.navigationController  propertyName:@"navigationController"];
        NSMutableDictionary* navBarStyle = [navControllerStyle styleForObject:self.navigationController  propertyName:@"navigationBar"];
        
        NSMutableDictionary* barItemStyle = [navBarStyle styleForObject:self.navigationItem.backBarButtonItem propertyName:@"backBarButtonItem"];
        
        //This weird steps are needed to avoid super views layout to be called when setting the styles !
        UIBarButtonItem* item = self.navigationItem.backBarButtonItem;
        self.navigationItem.backBarButtonItem = nil;
        [item applyStyle:barItemStyle];
        self.navigationItem.backBarButtonItem = item;
        
        //HACK for versions before 4.2 due to the fact that setting a custom view on a UIBarButtonItem after it has been set in the navigationItem do not work.
        if([CKOSVersion() floatValue]< 4.2){
            if(self.navigationItem.backBarButtonItem == self.navigationItem.leftBarButtonItem){
                UIBarButtonItem* bu = self.navigationItem.backBarButtonItem;
                self.navigationItem.leftBarButtonItem = nil;
                [self.navigationItem setLeftBarButtonItem:bu animated:YES];
            }
        }
    }
}

- (void)popViewController{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)applyStyleForController{
    if([self.styleManager isEmpty])
        return;
    
    //disable animations in case frames are set in stylesheets and currently in animation...
    [CATransaction begin];
    [CATransaction
     setValue: [NSNumber numberWithBool: YES]
     forKey: kCATransactionDisableActions];
    
    [self applyStyle];
          
    [CATransaction commit];
}

- (void)applyStyleForNavigation{
    if([self.styleManager isEmpty])
        return;
    
    
    //disable animations in case frames are set in stylesheets and currently in animation...
    [CATransaction begin];
    [CATransaction 
     setValue: [NSNumber numberWithBool: YES]
     forKey: kCATransactionDisableActions];
    
    
    NSMutableDictionary* controllerStyle =  [self controllerStyle];;
    
    if(!self.styleHasBeenApplied){
        controllerStyle = [self applyStyle];
        self.styleHasBeenApplied = YES;
    }
    
    UIBarButtonItem* leftBarButtonItem = self.navigationItem.leftBarButtonItem ;
    if([CKOSVersion() floatValue] >= 7){
        for(UIBarButtonItem* item in self.navigationItem.leftBarButtonItems){
            if(item.width == -9)//negative spacer
                continue;
            leftBarButtonItem = item;
            break;
        }
    }
    
    NSMutableDictionary* navControllerStyle = [controllerStyle styleForObject:self.navigationController  propertyName:@"navigationController"];
    NSMutableDictionary* navBarStyle = [self.navigationController.navigationBar applyStyle:navControllerStyle propertyName:@"navigationBar"];
    
   // UIViewController* topStackController = self;
    if(leftBarButtonItem && leftBarButtonItem != self.navigationItem.backBarButtonItem){
        NSMutableDictionary* barItemStyle = [navBarStyle styleForObject:leftBarButtonItem propertyName:@"leftBarButtonItem"];
        
        //This weird steps are needed to avoid super views layout to be called when setting the styles !
        UIBarButtonItem* item = leftBarButtonItem;
        
        self.navigationItem.leftBarButtonItem = nil;
        if([CKOSVersion() floatValue] >= 7){
            self.navigationItem.leftBarButtonItems = @[];
        }
        
        [item applyStyle:barItemStyle];
        
        if([CKOSVersion() floatValue] >= 7){
            UIBarButtonItem *negativeSpacer = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                            target:nil action:nil]autorelease];
            negativeSpacer.width = -9;
            [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, item, nil]];
        }else{
            self.navigationItem.leftBarButtonItem = item;
        }
        
        if(item.customView /*&& [[item.customView layoutBoxes]count] > 0*/){
            CGSize preferedSize = [item.customView preferredSizeConstraintToSize:self.navigationController.navigationBar.bounds.size];
            item.customView.width = preferedSize.width;
            item.customView.height = preferedSize.height;
        }
    }
    
    //Back button
    if(self.navigationItem.hidesBackButton){
        self.navigationItem.backBarButtonItem = self.navigationItem.leftBarButtonItem = nil;
        if([CKOSVersion() floatValue] >= 7){
            self.navigationItem.leftBarButtonItems = @[];
        }
    }
    else if(self.navigationItem.backBarButtonItem){
        NSMutableDictionary* backBarItemStyle = [navBarStyle styleForObject:self.navigationItem.backBarButtonItem propertyName:@"backBarButtonItem"];
        
        //This weird steps are needed to avoid super views layout to be called when setting the styles !
        UIBarButtonItem* item = self.navigationItem.backBarButtonItem;
        self.navigationItem.backBarButtonItem = nil;
        [item applyStyle:backBarItemStyle];
        self.navigationItem.backBarButtonItem = item;
        
        if(item.customView /*&& [[item.customView layoutBoxes]count] > 0*/){
            CGSize preferedSize = [item.customView preferredSizeConstraintToSize:self.navigationController.navigationBar.bounds.size];
            item.customView.width = preferedSize.width;
            item.customView.height = preferedSize.height;
        }
    }
    else if(!leftBarButtonItem /*&& [self.navigationController.viewControllers lastObject] == topStackController*/){
        NSMutableDictionary* backBarItemStyle = [navBarStyle styleForObject:self.navigationItem.backBarButtonItem propertyName:@"backBarButtonItem"];
        if(backBarItemStyle && ![backBarItemStyle isEmpty] && [self.navigationController.viewControllers count] > 1){
            UIViewController* previousController = [self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count] - 2];
            self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc]initWithTitle:previousController.title style:UIBarButtonItemStyleBordered target:self action:@selector(popViewController)]autorelease];
            
            //This weird steps are needed to avoid super views layout to be called when setting the styles !
            UIBarButtonItem* item = self.navigationItem.backBarButtonItem;
            self.navigationItem.backBarButtonItem = nil;
            self.navigationItem.leftBarButtonItem = nil;
            if([CKOSVersion() floatValue] >= 7){
                self.navigationItem.leftBarButtonItems = @[];
            }
            [item applyStyle:backBarItemStyle];
            self.navigationItem.backBarButtonItem = item;
            
            
            if(item.customView /*&& [[item.customView layoutBoxes]count] > 0*/){
                CGSize preferedSize = [item.customView preferredSizeConstraintToSize:self.navigationController.navigationBar.bounds.size];
                item.customView.width = preferedSize.width;
                item.customView.height = preferedSize.height;
            }
            
            if([CKOSVersion() floatValue] >= 7){
                UIBarButtonItem *negativeSpacer = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                                                                target:nil action:nil]autorelease];
                negativeSpacer.width = -9;
                [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, self.navigationItem.backBarButtonItem, nil]];
            }else{
                self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
            }
        }
    }
    
    UIBarButtonItem* rightBarButtonItem = self.navigationItem.rightBarButtonItem ;
    if([CKOSVersion() floatValue] >= 7){
        for(UIBarButtonItem* item in self.navigationItem.rightBarButtonItems){
            if(item.width == -9)//negative spacer
                continue;
            rightBarButtonItem = item;
            break;
        }
    }
    
    if(rightBarButtonItem){
        NSMutableDictionary* barItemStyle = [navBarStyle styleForObject:rightBarButtonItem propertyName:@"rightBarButtonItem"];
        
        //This weird steps are needed to avoid super views layout to be called when setting the styles !
        UIBarButtonItem* item = rightBarButtonItem;
        self.navigationItem.rightBarButtonItem = nil;
        if([CKOSVersion() floatValue] >= 7){
            self.navigationItem.rightBarButtonItems = @[];
        }
        
        [item applyStyle:barItemStyle];
        
        if([CKOSVersion() floatValue] >= 7){
            UIBarButtonItem *negativeSpacer = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                            target:nil action:nil]autorelease];
            negativeSpacer.width = -9;
            [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, item, nil]];
        }else{
            self.navigationItem.rightBarButtonItem = item;
        }
        
        
        if(item.customView /*&& [[item.customView layoutBoxes]count] > 0*/){
            CGSize preferedSize = [item.customView preferredSizeConstraintToSize:self.navigationController.navigationBar.bounds.size];
            item.customView.width = preferedSize.width;
            item.customView.height = preferedSize.height;
        }
    }
    
    if(self.navigationItem.titleView){
        //This weird steps are needed to avoid super views layout to be called when setting the styles !
        UIView* view = self.navigationItem.titleView;
        self.navigationItem.titleView = nil;
        [view applyStyle:navBarStyle propertyName:@"titleView"];
        self.navigationItem.titleView = view;
        
        if([view isKindOfClass:[UILabel class]]){
            
            UILabel* label = (UILabel*)view;
            [label sizeToFit];
            
            [NSObject beginBindingsContext:self.navigationTitleBindingContext policy:CKBindingsContextPolicyRemovePreviousBindings];
            [self bind:@"title" withBlock:^(id value) {
                label.text = [value isKindOfClass:[NSString class]] ? value : nil;
                [label sizeToFit];
            }];
            [view bind:@"text" withBlock:^(id value) {
                [label sizeToFit];
            }];
            [NSObject endBindingsContext];
        }else {//if([[view layoutBoxes]count] > 0){
            CGSize preferedSize = [view preferredSizeConstraintToSize:self.navigationController.navigationBar.bounds.size];
            view.width = preferedSize.width;
            view.height = preferedSize.height;
        }
    }else{
        UILabel* label = [[[UILabel alloc]init]autorelease];
        label.font = [UIFont boldSystemFontOfSize:20];
        label.textColor = [UIColor whiteColor];
        label.shadowOffset = CGSizeMake(0,-1);
        label.shadowColor = [UIColor darkGrayColor];
        label.backgroundColor = [UIColor clearColor];
        label.text = self.title;
        
        self.navigationItem.titleView = label;
        [label applyStyle:navBarStyle propertyName:@"titleView"];
        
        [label sizeToFit];
        
        [NSObject beginBindingsContext:self.navigationTitleBindingContext policy:CKBindingsContextPolicyRemovePreviousBindings];
        [self bind:@"title" withBlock:^(id value) {
            label.text = [value isKindOfClass:[NSString class]] ? value : nil;
            [label sizeToFit];
        }];
        [label bind:@"text" withBlock:^(id value) {
            [label sizeToFit];
        }];
        [NSObject endBindingsContext];
    }
    
    
    [CATransaction commit];
    
    //ios7
    //http://stackoverflow.com/questions/19054625/changing-back-button-in-ios-7-disables-swipe-to-navigate-back
    if([CKOSVersion() floatValue] >= 7){
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
}

- (void)applyStylesheet:(BOOL)animated{
    //Force to create the manager here !
    [self styleManager];
    
    if([CKResourceManager isResourceManagerConnected]){
        [CKResourceDependencyContext beginContext];
    }
    
    if([self containerViewControllerConformsToProtocol:@protocol(CKSectionContainerDelegate)] != nil
       || [self isKindOfClass:[UINavigationController class]]){
        //Style applied by super class
        /*
        NSMutableDictionary* controllerStyle = nil;
        if(!self.styleHasBeenApplied){
            [CATransaction begin];
            [CATransaction
             setValue: [NSNumber numberWithBool: YES]
             forKey: kCATransactionDisableActions];
            
            controllerStyle = [self applyStyle];
            self.styleHasBeenApplied = YES;
            
            [CATransaction commit];
        }*/
        
    }else{
        
        if(self.rightButton){
            [self.navigationItem setRightBarButtonItem:self.rightButton animated:animated];
        }
        
        if(self.leftButton){
            [self.navigationItem setLeftBarButtonItem:self.leftButton animated:animated];
        }
        
        [self applyStyleForNavigation];
        
        //HACK for versions before 4.2 due to the fact that setting a custom view on a UIBarButtonItem after it has been set in the navigationItem do not work.
        if([CKOSVersion() floatValue]< 4.2){
            UIBarButtonItem* left = self.navigationItem.leftBarButtonItem;
            UIBarButtonItem* right = self.navigationItem.rightBarButtonItem;
            self.navigationItem.leftBarButtonItem = nil;
            self.navigationItem.rightBarButtonItem = nil;
            [self.navigationItem setLeftBarButtonItem:left animated:animated];
            [self.navigationItem setRightBarButtonItem:right animated:animated];
        }
    }
    
    if([CKResourceManager isResourceManagerConnected]){
        NSSet* dependenciesFilePaths = [CKResourceDependencyContext endContext];
        [self.styleManager registerOnDependencies:dependenciesFilePaths];
    }
}

- (void)reapplyStylesheet{
    if(!self.isViewLoaded)
        return;
    
    self.styleHasBeenApplied = NO;
    [self applyStylesheet:NO];
}


#pragma mark Managing Life Cycle

- (void)AppCoreKit_viewWillAppear:(BOOL)animated{
    self.state = CKViewControllerStateWillAppear;
    if(self.viewWillAppearBlock){
        self.viewWillAppearBlock(self,animated);
    }
    
    [self applyStylesheet:animated];
    
    [self AppCoreKit_viewWillAppear:animated];
    
    if(self.viewWillAppearEndBlock){
        self.viewWillAppearEndBlock(self,animated);
    }
    
    if([self containerViewController] == nil){
        [self.inlineDebuggerController start];
    }
    
    [self adjustStyleViewWithToolbarHidden:[self.navigationController isToolbarHidden] animated:animated];
}


- (void)AppCoreKit_viewWillDisappear:(BOOL)animated{
    self.state = CKViewControllerStateWillDisappear;
    [self AppCoreKit_viewWillDisappear:animated];
    if(self.viewWillDisappearBlock){
        self.viewWillDisappearBlock(self,animated);
    }
}

- (void)AppCoreKit_viewDidAppear:(BOOL)animated{
    self.state = CKViewControllerStateDidAppear;
    [self AppCoreKit_viewDidAppear:animated];
    if(self.viewDidAppearBlock){
        self.viewDidAppearBlock(self,animated);
    }
}

- (void)AppCoreKit_viewDidDisappear:(BOOL)animated{
    self.state = CKViewControllerStateDidDisappear;
    [self AppCoreKit_viewDidDisappear:animated];
    if(self.viewDidDisappearBlock){
        self.viewDidDisappearBlock(self,animated);
    }
    [NSObject removeAllBindingsForContext:self.navigationItemsBindingContext];
    [NSObject removeAllBindingsForContext:self.navigationTitleBindingContext];
    
    if([self containerViewController] == nil){
        [self.inlineDebuggerController stop];
    }
}


-(void) AppCoreKit_viewDidLoad{
    self.state = CKViewControllerStateDidLoad;
	[self AppCoreKit_viewDidLoad];
    if(self.viewDidLoadBlock){
        self.viewDidLoadBlock(self);
    }
    self.styleHasBeenApplied = NO;
    
    //As this value needs to be set before viewWillAppear we force to set it here
    NSMutableDictionary* controllerStyle = [self controllerStyle];
    if([controllerStyle containsObjectForKey:@"contentSizeForViewInPopover"]){
        self.contentSizeForViewInPopover = [controllerStyle cgSizeForKey:@"contentSizeForViewInPopover"];
    }

	if(self.containerViewController == nil && [self isKindOfClass:[CKViewController class]]){
		self.inlineDebuggerController = [[[CKInlineDebuggerController alloc]initWithViewController:self]autorelease];
	}
}

-(void) AppCoreKit_viewDidUnload{
    self.state = CKViewControllerStateDidUnload;
	[self AppCoreKit_viewDidUnload];
    if(self.viewDidUnloadBlock){
        self.viewDidUnloadBlock(self);
    }
    
    [self.inlineDebuggerController release];
    self.inlineDebuggerController = nil;
}

#pragma Managing Orientation

- (BOOL)AppCoreKit_shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if(UIInterfaceOrientationIsPortrait(interfaceOrientation)
       && (self.supportedInterfaceOrientations & CKInterfaceOrientationPortrait))
        return YES;
    if(UIInterfaceOrientationIsLandscape(interfaceOrientation)
       && (self.supportedInterfaceOrientations & CKInterfaceOrientationLandscape))
        return YES;
    return NO;
}



- (void)AppCoreKit_willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    if(self.orientationChangeBlock){
        self.orientationChangeBlock(self,toInterfaceOrientation);
    }
    
    [self AppCoreKit_willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    NSMutableDictionary* viewStyle = [self.view appliedStyle];
    [[self.view class] applyStyle:viewStyle toView:self.view appliedStack:nil delegate:nil];//Apply only on view and not hierarchy !
    
    if(self.navigationController && ![self.navigationController isToolbarHidden]){
        NSMutableDictionary* navControllerStyle = [[self controllerStyle] styleForObject:self.navigationController  propertyName:@"navigationController"];
        [self.navigationController.toolbar applyStyle:navControllerStyle propertyName:@"toolbar"];
    }
    
    [self applyStyleForNavigation];
    [self adjustStyleViewWithToolbarHidden:self.navigationController.isToolbarHidden animated:NO];
}

#pragma mark - Buttons Management

@dynamic leftButton;

static char UIViewControllerLeftButtonKey;

- (void)setLeftButton:(UIBarButtonItem *)theleftButton{
    [self setLeftButton:theleftButton animated:NO];
}

- (UIBarButtonItem*)leftButton{
    return objc_getAssociatedObject(self, &UIViewControllerLeftButtonKey);
}

- (void)setLeftButton:(UIBarButtonItem*)theleftButton animated:(BOOL)animated{
    objc_setAssociatedObject(self, &UIViewControllerLeftButtonKey, theleftButton, OBJC_ASSOCIATION_RETAIN);
    
    if([CKOSVersion() floatValue] >= 7){
        UIBarButtonItem *negativeSpacer = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                         target:nil action:nil]autorelease];
        negativeSpacer.width = -9;
        [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, theleftButton, nil] animated:animated && self.isViewDisplayed];
    }else{
        [self.navigationItem setLeftBarButtonItem:theleftButton animated:animated && self.isViewDisplayed];
    }
    
    if(self.isViewDisplayed){
        [self applyStyleForLeftBarButtonItem];
        
        //HACK for versions before 4.2 due to the fact that setting a custom view on a UIBarButtonItem after it has been set in the navigationItem do not work.
        if([CKOSVersion() floatValue]< 4.2){
            self.navigationItem.leftBarButtonItem = nil;
            [self.navigationItem setLeftBarButtonItem:theleftButton animated:animated];
        }
    }
}


@dynamic rightButton;

static char UIViewControllerRightButtonKey;


- (void)setRightButton:(UIBarButtonItem *)theRightButton{
    [self setRightButton:theRightButton animated:NO];
}

- (UIBarButtonItem*)rightButton{
    return objc_getAssociatedObject(self, &UIViewControllerRightButtonKey);
}

- (void)setRightButton:(UIBarButtonItem*)theRightButton animated:(BOOL)animated{
    objc_setAssociatedObject(self, &UIViewControllerRightButtonKey, theRightButton, OBJC_ASSOCIATION_RETAIN);
    
    if([CKOSVersion() floatValue] >= 7){
        UIBarButtonItem *negativeSpacer = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                         target:nil action:nil]autorelease];
        negativeSpacer.width = -9;
        [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, theRightButton, nil] animated:animated && self.isViewDisplayed];
    }else{
        [self.navigationItem setRightBarButtonItem:theRightButton animated:animated && self.isViewDisplayed];
    }
    
    if(self.isViewDisplayed){
        [self applyStyleForRightBarButtonItem];
        
        //HACK for versions before 4.2 due to the fact that setting a custom view on a UIBarButtonItem after it has been set in the navigationItem do not work.
        if([CKOSVersion() floatValue]< 4.2){
            self.navigationItem.rightBarButtonItem = nil;
            [self.navigationItem setRightBarButtonItem:theRightButton animated:animated];
        }
    }
}

#pragma mark Managing Editing Mode

+ (void)load {
    CKSwizzleSelector([UIViewController class], @selector(initWithCoder:), @selector(AppCoreKit_initWithCoder:));
    CKSwizzleSelector([UIViewController class], @selector(initWithNibName:bundle:), @selector(AppCoreKit_initWithNibName:bundle:));
    CKSwizzleSelector([UIViewController class], @selector(dealloc), @selector(AppCoreKit_dealloc));
    CKSwizzleSelector([UIViewController class], @selector(resourceManagerReloadUI), @selector(AppCoreKit_resourceManagerReloadUI));
    CKSwizzleSelector([UIViewController class], @selector(viewWillAppear:), @selector(AppCoreKit_viewWillAppear:));
    CKSwizzleSelector([UIViewController class], @selector(viewWillDisappear:), @selector(AppCoreKit_viewWillDisappear:));
    CKSwizzleSelector([UIViewController class], @selector(viewDidAppear:), @selector(AppCoreKit_viewDidAppear:));
    CKSwizzleSelector([UIViewController class], @selector(viewDidDisappear:), @selector(AppCoreKit_viewDidDisappear:));
    CKSwizzleSelector([UIViewController class], @selector(viewDidLoad), @selector(AppCoreKit_viewDidLoad));
    CKSwizzleSelector([UIViewController class], @selector(viewDidUnload), @selector(AppCoreKit_viewDidUnload));
    CKSwizzleSelector([UIViewController class], @selector(shouldAutorotateToInterfaceOrientation:), @selector(AppCoreKit_shouldAutorotateToInterfaceOrientation:));
    CKSwizzleSelector([UIViewController class], @selector(willAnimateRotationToInterfaceOrientation:duration:), @selector(AppCoreKit_willAnimateRotationToInterfaceOrientation:duration:));
    CKSwizzleSelector([UIViewController class], @selector(setEditing:), @selector(AppCoreKit_setEditing:));
    CKSwizzleSelector([UIViewController class], @selector(setEditing:animated:), @selector(AppCoreKit_setEditing:animated:));
    CKSwizzleSelector([UIViewController class], @selector(preferredStatusBarStyle), @selector(AppCoreKit_preferredStatusBarStyle));
    CKSwizzleSelector([UIViewController class], @selector(preferredStatusBarUpdateAnimation), @selector(AppCoreKit_preferredStatusBarUpdateAnimation));
    CKSwizzleSelector([UIViewController class], @selector(prefersStatusBarHidden), @selector(AppCoreKit_prefersStatusBarHidden));
}

//Adding KVO support for the editing property
- (void)AppCoreKit_setEditing:(BOOL)editing{
    [self willChangeValueForKey:@"editing"];
    [self AppCoreKit_setEditing:editing];
    [self didChangeValueForKey:@"editing"];
    
    if(self.editingBlock){
        self.editingBlock(editing);
    }
}

- (void)AppCoreKit_setEditing:(BOOL)editing animated:(BOOL)animated{
    [self willChangeValueForKey:@"editing"];
    [self AppCoreKit_setEditing:editing animated:animated];
    [self didChangeValueForKey:@"editing"];
    
    if(self.editingBlock){
        self.editingBlock(editing);
    }
}

#pragma mark Managing UI adjustments when displaying navigation artifacts


- (void)toolbarGetsDisplayed:(NSNotification*)notif{
    if(notif.object == self.navigationController){
        NSNumber* animated = [[notif userInfo]objectForKey:@"animated"];
        [self adjustStyleViewWithToolbarHidden:NO animated:[animated boolValue]];
    }
}

- (void)toolbarGetsHidden:(NSNotification*)notif{
    if(notif.object == self.navigationController){
        NSNumber* animated = [[notif userInfo]objectForKey:@"animated"];
        [self adjustStyleViewWithToolbarHidden:YES animated:[animated boolValue]];
    }
}


//ios 7
- (UIEdgeInsets)navigationControllerTransparencyInsets{
    if(self.view.window == nil)
        return UIEdgeInsetsMake(0,0,0,0);
    
    CGRect navigationbarRectInWindow = (self.navigationController && ![self.navigationController isNavigationBarHidden]) ? [self.navigationController.navigationBar convertRect:self.navigationController.navigationBar.bounds toView:self.navigationController.view] : CGRectMake(0,0,0,0);
    CGRect tabbarRectInWindow        = self.tabBarController ? [self.tabBarController.tabBar convertRect:self.tabBarController.tabBar.bounds toView:self.navigationController.view] : CGRectMake(0,0,0,0);
    
    CGRect viewRectInWindow = [self.view convertRect:self.view.bounds toView:self.navigationController.view];
    CGFloat insetTop = MAX(0,(navigationbarRectInWindow.origin.y + navigationbarRectInWindow.size.height) - viewRectInWindow.origin.y);
    CGFloat insetBottom = self.tabBarController ? MAX(0,(viewRectInWindow.origin.y + viewRectInWindow.size.height) - tabbarRectInWindow.origin.y) : 0;
    
    BOOL toolbarTransulcent = self.navigationController.toolbar.translucent;
    insetBottom += ((self.navigationController.isToolbarHidden || !toolbarTransulcent) ? 0 : self.navigationController.toolbar.bounds.size.height);
    
    return UIEdgeInsetsMake(insetTop,0,insetBottom,0);
}


@end






@implementation UIViewController(CKHierarchy)

- (UIViewController*)topMostRootPresentedViewController{
    UIViewController* current = self;
    while (current.presentedViewController || current.containerViewController || current.navigationController) {
        if(current.presentedViewController){
            current = current.presentedViewController;
        }else if(current.containerViewController){
            current = current.containerViewController;
        }else if(current.navigationController){
            current = current.navigationController;
        }
    }
    return current;
}

@end


@implementation CKViewController

#ifdef __IPHONE_6_0
- (BOOL)shouldAutorotate{
    return YES;
}
#endif

//This avoid keyboard to stay on screen in controllers presented as UIModalPresentationFormSheet
- (BOOL)disablesAutomaticKeyboardDismissal {
    return NO;
}

@end

