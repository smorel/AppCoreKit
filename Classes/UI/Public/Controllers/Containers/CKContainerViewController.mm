//  CKContainerViewController.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKContainerViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CKVersion.h"
#import "CKWeakRef.h"
#import <objc/runtime.h>
#import "CKRuntime.h"
#import "UIView+Positioning.h"
#import "CKBinding.h"

typedef void(^CKTransitionBlock)();

@interface CKTransition : CATransition
@property(nonatomic,copy)CKTransitionBlock beginBlock;
@property(nonatomic,copy)CKTransitionBlock endBlock;
@end

@implementation CKTransition
@synthesize beginBlock = _beginBlock;
@synthesize endBlock = _endBlock;

- (id)init{
    self = [super init];
    self.delegate = self;
    return self;
}

- (void)dealloc{
    [_beginBlock release];_beginBlock = nil;
    [_endBlock release];_endBlock = nil;
    [super dealloc];
}

- (void)animationDidStart:(CAAnimation *)theAnimation{
    if(_beginBlock){
        _beginBlock();
    }
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag{
    if(_endBlock){
        _endBlock();
    }
}

@end

@interface CKContainerViewController ()
@property (nonatomic, retain) UIView *containerView;
@property (nonatomic, assign) BOOL needsToCallViewDidAppearOnSelectedController;
@property (nonatomic, retain) NSString* subControllerNavigationItemBindings;
@end

//

@implementation CKContainerViewController

@synthesize viewControllers = _viewControllers;
@synthesize selectedIndex = _selectedIndex;
@synthesize containerView = _containerView;
@synthesize needsToCallViewDidAppearOnSelectedController;
@synthesize presentsSelectedViewControllerItemsInNavigationBar = _presentsSelectedViewControllerItemsInNavigationBar;
@synthesize presentsSelectedViewControllerItemsInToolbar = _presentsSelectedViewControllerItemsInToolbar;

- (void)postInit{
    [super postInit];
    self.needsToCallViewDidAppearOnSelectedController = NO;
    _presentsSelectedViewControllerItemsInNavigationBar = YES;
    _presentsSelectedViewControllerItemsInToolbar = YES;
}

+ (id)controllerWithViewControllers:(NSArray *)viewControllers{
    return [[[[self class]alloc]initWithViewControllers:viewControllers]autorelease];
}

- (id)initWithViewControllers:(NSArray *)viewControllers {
	self = [super init];
	if (self) {
		self.viewControllers = viewControllers;
	}
	return self;
}

- (void)dealloc {
    if(self.subControllerNavigationItemBindings){
        [NSObject removeAllBindingsForContext:self.subControllerNavigationItemBindings];
    }
	[_containerView release]; _containerView = nil;
	[_viewControllers release]; _viewControllers = nil;
	[super dealloc];
}

- (void)setViewControllers:(NSArray *)viewControllers{
    for(UIViewController* controller in _viewControllers){
        [controller setContainerViewController:nil];
    }
    
    [_viewControllers release];
    _viewControllers = [[NSMutableArray arrayWithArray:viewControllers]retain];
    
    if ([self.viewControllers count] > 0) {
		for (UIViewController* controller in self.viewControllers) {
			[controller setContainerViewController:self];
		}
		_selectedIndex = 0;
	}
    
    if(self.isViewDisplayed){
        [self presentViewControllerAtIndex:_selectedIndex withTransition:CKTransitionNone];
    }
}

- (void)setSelectedIndex:(NSUInteger)theselectedIndex{
    if(theselectedIndex < [self.viewControllers count]){
        _selectedIndex = theselectedIndex;
        if(self.isViewDisplayed){
            [self presentViewControllerAtIndex:_selectedIndex withTransition:CKTransitionNone];
        }
    }
}

#pragma mark - View lifecycle

- (void)loadView {
	[super loadView];
    
    self.subControllerNavigationItemBindings = [NSString stringWithFormat:@"subControllerNavigationItemBindings_<%p>",self];

	if (self.containerView == nil) {
		self.containerView = [[[UIView alloc] initWithFrame:self.view.bounds] autorelease];
		self.containerView.backgroundColor = self.view.backgroundColor;
		self.containerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.containerView.clipsToBounds = YES;
		[self.view addSubview:self.containerView];
	}
}

- (void)viewDidUnload {
	[super viewDidUnload];
	self.containerView = nil;
}


- (void)resourceManagerReloadUI{
    [self reapplyStylesheet];
    //do not update childrens as it's done by the ResourceManager itself
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
    
    [UIView setAnimationsEnabled:NO];
    
    UIViewController *newController = self.selectedViewController;
    if([newController isViewLoaded] && [newController.view window] != nil && newController.state != CKViewControllerStateWillAppear ){
        //  [newController viewWillAppear:animated];
    }
    else{
        [self presentViewControllerAtIndex:self.selectedIndex withTransition:CKTransitionNone];
    }
    
    [UIView setAnimationsEnabled:YES];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
    
    UIViewController *newController = self.selectedViewController;
    //if(newController.state != CKViewControllerStateDidAppear ){
    //    [newController viewDidAppear:animated];
    // }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //   if( self.selectedViewController.state != CKViewControllerStateWillDisappear){
    //      [self.selectedViewController viewWillDisappear:animated];
    // }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    //if(self.selectedViewController.state != CKViewControllerStateDidDisappear){
    //    [self.selectedViewController viewDidDisappear:animated];
    // }
}

#pragma mark - Controllers management

- (UIViewController *)selectedViewController {
	if ([self.viewControllers count] < _selectedIndex+1) return nil;
	return [self.viewControllers objectAtIndex:_selectedIndex];
}

- (void)setNavigationItemFromViewController:(UIViewController *)viewController {
    /*
    [self.navigationController.navigationBar pushNavigationItem:self.navigationItem animated:NO];
    */
    
    
    UIViewController* container = self;
    while([container containerViewController]){
        container = [container containerViewController];
    }
    
    
    [NSObject beginBindingsContext:self.subControllerNavigationItemBindings policy:CKBindingsContextPolicyRemovePreviousBindings ];
    __unsafe_unretained UIViewController* bContainer = container;
    __unsafe_unretained UIViewController* bViewController = viewController;
    
    if(_presentsSelectedViewControllerItemsInNavigationBar){
        [viewController bind:@"title" executeBlockImmediatly:YES withBlock:^(id value) {
            bContainer.title = bViewController.title;
        }];
        
        
        [viewController.navigationItem bind:@"leftBarButtonItems" executeBlockImmediatly:YES withBlock:^(id value) {
            if([bViewController.navigationItem.leftBarButtonItems count] > 0){
                bContainer.navigationItem.leftBarButtonItems = bViewController.navigationItem.leftBarButtonItems;
            }else{
                bContainer.navigationItem.leftBarButtonItem = bViewController.navigationItem.leftBarButtonItem;
            }
        }];
        
        [viewController.navigationItem bind:@"leftBarButtonItem" executeBlockImmediatly:YES withBlock:^(id value) {
            if([bViewController.navigationItem.leftBarButtonItems count] > 0){
                bContainer.navigationItem.leftBarButtonItems = bViewController.navigationItem.leftBarButtonItems;
            }else{
                bContainer.navigationItem.leftBarButtonItem = bViewController.navigationItem.leftBarButtonItem;
            }
        }];
        
        [viewController.navigationItem bind:@"rightBarButtonItems" executeBlockImmediatly:YES withBlock:^(id value) {
            if([bViewController.navigationItem.rightBarButtonItems count] > 0){
                bContainer.navigationItem.rightBarButtonItems = bViewController.navigationItem.rightBarButtonItems;
            }else{
                bContainer.navigationItem.rightBarButtonItem = bViewController.navigationItem.rightBarButtonItem;
            }
        }];
        
        [viewController.navigationItem bind:@"rightBarButtonItem" executeBlockImmediatly:YES withBlock:^(id value) {
            if([bViewController.navigationItem.rightBarButtonItems count] > 0){
                bContainer.navigationItem.rightBarButtonItems = bViewController.navigationItem.rightBarButtonItems;
            }else{
                bContainer.navigationItem.rightBarButtonItem = bViewController.navigationItem.rightBarButtonItem;
            }
        }];
        
        
        [viewController.navigationItem bind:@"backBarButtonItem" executeBlockImmediatly:YES withBlock:^(id value) {
            bContainer.navigationItem.backBarButtonItem = bViewController.navigationItem.backBarButtonItem;
        }];
         
        
        [viewController.navigationItem bind:@"title" executeBlockImmediatly:YES withBlock:^(id value) {
            bContainer.navigationItem.title = bViewController.navigationItem.title;
        }];
        
        [viewController.navigationItem bind:@"prompt" executeBlockImmediatly:YES withBlock:^(id value) {
            bContainer.navigationItem.prompt = bViewController.navigationItem.prompt;
        }];
        
        [viewController.navigationItem bind:@"titleView" executeBlockImmediatly:YES withBlock:^(id value) {
            bContainer.navigationItem.titleView = bViewController.navigationItem.titleView;
        }];
        	
       // [self.navigationController.navigationBar pushNavigationItem:container.navigationItem animated:NO];
    }
    
    if(_presentsSelectedViewControllerItemsInToolbar){
        bContainer.toolbarItems = bViewController.toolbarItems;
     
        /*   [viewController.navigationItem bind:@"toolbarItems" executeBlockImmediatly:YES withBlock:^(id value) {
            bContainer.toolbarItems = bViewController.toolbarItems;
        }];
      */
    
    }
    
    [NSObject endBindingsContext];
     
}

//

- (void)presentViewControllerAtIndex:(NSUInteger)index withTransition:(CKTransitionType)transition completion:(void (^)())completion {
    if([self isViewLoaded]){
	//CKAssert(index < [self.viewControllers count], @"No viewController at index: %d", index);
        if(index >= [self.viewControllers count] )
            return;
        
        UIViewController *newController = [self.viewControllers objectAtIndex:index];
        if(index == self.selectedIndex && [newController.view superview] != nil){
            return;
        }
        
        UIViewController *oldController = (index == _selectedIndex) ? nil : [self.viewControllers objectAtIndex:_selectedIndex];
        
        newController.view.frame = self.containerView.bounds;
        newController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        if([CKOSVersion() floatValue] < 5){
            [oldController viewWillDisappear:YES];
            [newController viewWillAppear:YES];
        }
        
        UIView *containerView = self.containerView;
        __block UIViewController *bOldController = oldController;
        __block UIViewController *bNewController = newController;
        
        if(transition == CKTransitionPush ||
           transition == CKTransitionPop ||
           transition == CKTransitionSlideInFromTop ||
           transition == CKTransitionSlideAwayFromTop) {
            
            CKTransition *animation = [[[CKTransition alloc] init]autorelease];
            
            if(transition == CKTransitionPush){
                animation.type = kCATransitionPush;
                animation.subtype = kCATransitionFromRight;
            }
            else  if(transition == CKTransitionPop){
                animation.type = kCATransitionPush;
                animation.subtype = kCATransitionFromLeft;
            }
            else if(transition == CKTransitionSlideInFromTop){
                animation.type = kCATransitionMoveIn;
                animation.subtype = kCATransitionFromBottom;
            }
            else  if(transition == CKTransitionSlideAwayFromTop){
                animation.type = kCATransitionReveal;
                animation.subtype = kCATransitionFromTop;
            }
            
            animation.duration = 0.4f;
            animation.removedOnCompletion = YES;
            [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            [[containerView layer] addAnimation:animation forKey:kCATransition];
            
            animation.endBlock = ^(){
                if(bOldController){
                    if([CKOSVersion() floatValue] < 5){
                        [bOldController viewDidDisappear:YES];
                    }
                    
                    if(oldController){
                        [oldController.view removeFromSuperview];
                    }
                    
                    [bOldController release];
                }
                if(bNewController){
                    if([CKOSVersion() floatValue] < 5){
                        [bNewController viewDidAppear:YES];
                    }
                    [bNewController release];
                }
                if (completion) {
                    completion();
                }
            };
            
            
            if(oldController){
                [bOldController retain];
            }
            
            if(newController){
                [bNewController retain];
                [containerView addSubview:newController.view];
            }
        }
        else{
            [bNewController retain];
            [bOldController retain];
            
            if(bNewController){
                [containerView addSubview:bNewController.view];
            }
                       
            [UIView transitionWithView:containerView
                              duration:0.4f 
                               options:(UIViewAnimationOptions)transition
                            animations:^(void){} 
                            completion:^(BOOL finished){
                                if(bOldController){
                                    if([CKOSVersion() floatValue] < 5){
                                        [bOldController viewDidDisappear:YES];
                                    }
                                    
                                    if(bOldController){
                                        [bOldController.view removeFromSuperview];
                                    }
                                    
                                    [bOldController release];
                                }
                                if(bNewController){
                                    if([CKOSVersion() floatValue] < 5){
                                        [bNewController viewDidAppear:YES];
                                    }
                                    [bNewController release];
                                }
                                if (completion) {
                                    completion();
                                }
                            }];
        }
        [self setNavigationItemFromViewController:newController];
    }
	_selectedIndex = index;
}

- (void)presentViewControllerAtIndex:(NSUInteger)index withTransition:(CKTransitionType)transition {
    [self presentViewControllerAtIndex:index withTransition:transition completion:nil];
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    if([CKOSVersion() floatValue] < 5){
        [self.selectedViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    if([CKOSVersion() floatValue] < 5){
        [self.selectedViewController  didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration{
    [super willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:duration];
    
    if([CKOSVersion() floatValue] < 5){
        [self.selectedViewController  willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:duration];
    }
}

/*
- (BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers{ return NO; }
- (BOOL)shouldAutomaticallyForwardRotationMethods{ return NO; }
- (BOOL)shouldAutomaticallyForwardAppearanceMethods{ return NO; }
 */



@end

#pragma mark - UIViewController Additions

@implementation UIViewController (CKContainerViewController_InterfaceOrientation)

- (UIInterfaceOrientation)UIViewController_CKContainerController_interfaceOrientation{
    if(self.containerViewController){
        return [self.containerViewController interfaceOrientation];
    }else if(self.navigationController){
        return [self.navigationController interfaceOrientation];
    }
    return [self UIViewController_CKContainerController_interfaceOrientation];
}

@end

#pragma mark - CKViewController Additions

@implementation CKViewController (CKContainerViewController)

- (UINavigationController *)navigationController {
	return (self.containerViewController && self.containerViewController.navigationController) ? self.containerViewController.navigationController : [super navigationController];
}

/*
- (UINavigationItem *)navigationItem {
	return self.containerViewController ? self.containerViewController.navigationItem : [super navigationItem];
}*/


@end



@interface UINavigationController (CKContainerViewController)
@end


@implementation UINavigationController (CKContainerViewController)

- (BOOL)UINavigationController_CKContainerViewController_wantsFullScreenLayout{
    if([CKOSVersion() floatValue] < 7){
        //FIXME :
        //here we should return no when in container but this method is called too early by the nav controller itself ...
        if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad){
            return NO;
        }
    }
    return [self UINavigationController_CKContainerViewController_wantsFullScreenLayout ];
}

- (void)setContainerViewController:(UIViewController *)containerViewController{
    [super setContainerViewController:containerViewController];
     if([CKOSVersion() floatValue] < 7){
         if(containerViewController){
             [self setWantsFullScreenLayout:NO];
             self.navigationBar.y = 0;
         }
     }
}

@end



bool swizzle_CKContainerViewController(){
    CKSwizzleSelector([UINavigationController class],@selector(wantsFullScreenLayout),@selector(UINavigationController_CKContainerViewController_wantsFullScreenLayout));
    CKSwizzleSelector([UIViewController class],@selector(interfaceOrientation),@selector(UIViewController_CKContainerController_interfaceOrientation));
    return 1;
}

static bool bo_swizzle_CKContainerViewController = swizzle_CKContainerViewController();
