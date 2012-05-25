//  CKContainerViewController.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-11.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKContainerViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CKVersion.h"
#import "CKWeakRef.h"
#import <objc/runtime.h>
#import "CKRuntime.h"
#import "CKUIView+Positioning.h"

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
@property (nonatomic, readwrite) NSUInteger selectedIndex;
@property (nonatomic, retain) UIView *containerView;
@property (nonatomic, assign) BOOL needsToCallViewDidAppearOnSelectedController;
@end

//

@implementation CKContainerViewController

@synthesize viewControllers = _viewControllers;
@synthesize selectedIndex = _selectedIndex;
@synthesize containerView = _containerView;
@synthesize needsToCallViewDidAppearOnSelectedController;

- (void)postInit{
    [super postInit];
    self.needsToCallViewDidAppearOnSelectedController = NO;
}

- (id)initWithViewControllers:(NSArray *)viewControllers {
	self = [super init];
	if (self) {
		self.viewControllers = viewControllers;
	}
	return self;
}

- (void)dealloc {
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
    
    if(self.viewIsOnScreen){
        [self showViewControllerAtIndex:_selectedIndex withTransition:CKTransitionNone];
    }
}

#pragma mark - View lifecycle

- (void)loadView {
	[super loadView];

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

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
    
    [UIView setAnimationsEnabled:NO];
    
    UIViewController *newController = self.selectedViewController;
    if(newController && [newController.view superview] != nil){
        if([CKOSVersion() floatValue] < 5){
            [newController viewWillAppear:animated];
            self.needsToCallViewDidAppearOnSelectedController = YES;
        }
    }
    else{
        [self showViewControllerAtIndex:self.selectedIndex withTransition:CKTransitionNone];
    }
    
    [UIView setAnimationsEnabled:YES];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
    
    if(self.needsToCallViewDidAppearOnSelectedController){
        UIViewController *newController = self.selectedViewController;
        if(newController){
            [newController viewDidAppear:animated];
        }
        self.needsToCallViewDidAppearOnSelectedController = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self.selectedViewController viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[self.selectedViewController viewDidDisappear:animated];
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
    
	container.title = viewController.title;
    [container.navigationItem setLeftBarButtonItem:viewController.navigationItem.leftBarButtonItem animated:YES];
	[container.navigationItem setRightBarButtonItem:viewController.navigationItem.rightBarButtonItem animated:YES];
	container.navigationItem.backBarButtonItem = viewController.navigationItem.backBarButtonItem;	
	container.navigationItem.title = viewController.navigationItem.title;
	container.navigationItem.prompt = viewController.navigationItem.prompt;
	container.navigationItem.titleView = viewController.navigationItem.titleView;
    container.toolbarItems = viewController.toolbarItems;
}

//

- (void)showViewControllerAtIndex:(NSUInteger)index withTransition:(CKTransitionType)transition {
    if([self isViewLoaded]){
	//NSAssert(index < [self.viewControllers count], @"No viewController at index: %d", index);
        if(index >= [self.viewControllers count] )
            return;
        
        UIViewController *newController = [self.viewControllers objectAtIndex:index];
        if(index == self.selectedIndex && [newController.view superview] != nil){
            return;
        }
        
        UIViewController *oldController = (index == _selectedIndex) ? nil : [self.viewControllers objectAtIndex:_selectedIndex];
        
        [self setNavigationItemFromViewController:newController];
        newController.view.frame = self.containerView.bounds;
        newController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        //if([CKOSVersion() floatValue] < 5){
            [oldController viewWillDisappear:YES];
            [newController viewWillAppear:YES];
        //}
        
        UIView *containerView = self.containerView;
        __block UIViewController *bOldController = oldController;
        __block UIViewController *bNewController = newController;
        
        if(transition == CKTransitionPush ||
           transition == CKTransitionPop){
            CKTransition *animation = [[[CKTransition alloc] init]autorelease];
            if(transition == CKTransitionPush){
                animation.type = kCATransitionPush;
                animation.subtype = kCATransitionFromRight;
            }
            else  if(transition == CKTransitionPop){
                animation.type = kCATransitionPush;
                animation.subtype = kCATransitionFromLeft;
            }
            animation.duration = 0.4f;
            animation.removedOnCompletion = YES;
            [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            [[containerView layer] addAnimation:animation forKey:kCATransition];
            
            animation.endBlock = ^(){
                if(bOldController){
                    //if([CKOSVersion() floatValue] < 5){
                        [bOldController viewDidDisappear:YES];
                    //}
                    [bOldController release];
                }
                if(bNewController){
                    //if([CKOSVersion() floatValue] < 5){
                        [bNewController viewDidAppear:YES];
                    //}
                    [bNewController release];
                }
            };
            
            if(oldController){
                [bOldController retain];
                [oldController.view removeFromSuperview];
            }
            if(newController){
                [bNewController retain];
                [containerView addSubview:newController.view];
            }
        }
        else{
            [bNewController retain];
            [bOldController retain];
            
            if(bOldController){
                [bOldController.view removeFromSuperview];
            }
            if(bNewController){
                [containerView addSubview:bNewController.view];
            }
                       
            [UIView transitionWithView:containerView
                              duration:0.4f 
                               options:(UIViewAnimationOptions)transition
                            animations:^(void){} 
                            completion:^(BOOL finished){
                                if(bOldController){
                                    //if([CKOSVersion() floatValue] < 5){
                                        [bOldController viewDidDisappear:YES];
                                    //}
                                    [bOldController release];
                                }
                                if(bNewController){
                                    //if([CKOSVersion() floatValue] < 5){
                                        [bNewController viewDidAppear:YES];
                                    //}
                                    [bNewController release];
                                }
                            }];
        }
    }
	_selectedIndex = index;
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
 

@end

#pragma mark - UIViewController Additions
@interface UIViewController ()
@property (nonatomic,retain)CKWeakRef* containerViewControllerRef;
@end

@implementation UIViewController (CKContainerViewController)

static char CKUIViewControllerContainerViewControllerKey;

- (void)setContainerViewControllerRef:(CKWeakRef *)ref {
    objc_setAssociatedObject(self, 
                             &CKUIViewControllerContainerViewControllerKey,
                             ref,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CKWeakRef *)containerViewControllerRef {
    return objc_getAssociatedObject(self, &CKUIViewControllerContainerViewControllerKey);
}



- (void)setContainerViewController:(UIViewController *)viewController {
    if(viewController == nil){
        if([self isViewLoaded]){
            [self viewWillDisappear:NO];
            [[self view]removeFromSuperview];
            [self viewDidDisappear:NO];
        }
    }
    
    
    CKWeakRef* ref = self.containerViewControllerRef;
    if(!ref){
        ref = [CKWeakRef weakRefWithObject:viewController];
        objc_setAssociatedObject(self, 
                                 &CKUIViewControllerContainerViewControllerKey,
                                 ref,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    else{
        ref.object = viewController;
    }
    
    if([CKOSVersion() floatValue] >= 5){
        if(viewController == nil){
            [self removeFromParentViewController];
        }else{
            [viewController addChildViewController:self];
        }
    }
}

- (UIViewController *)containerViewController {
    CKWeakRef* ref = self.containerViewControllerRef;
    return [ref object];
}

- (UIInterfaceOrientation)UIViewController_CKContainerController_interfaceOrientation{
    if(self.containerViewController){
        return [self.containerViewController interfaceOrientation];
    }else if(self.navigationController){
        return [self.navigationController interfaceOrientation];
    }
    return [self UIViewController_CKContainerController_interfaceOrientation];
}

@end

#pragma mark - CKUIViewController Additions

@implementation CKUIViewController (CKContainerViewController)

- (UINavigationController *)navigationController {
	return (self.containerViewController && self.containerViewController.navigationController) ? self.containerViewController.navigationController : [super navigationController];
}

- (UINavigationItem *)navigationItem {
	return self.containerViewController ? self.containerViewController.navigationItem : [super navigationItem];
}

@end



@interface UINavigationController (CKContainerViewController)
@end


@implementation UINavigationController (CKContainerViewController)

- (BOOL)UINavigationController_CKContainerViewController_wantsFullScreenLayout{
    //FIXME :
    //here we should return no when in container but this method is called too early by the nav controller itself ...
    if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad){
        return NO;
    }
    return [self UINavigationController_CKContainerViewController_wantsFullScreenLayout ];
}

- (void)setContainerViewController:(UIViewController *)containerViewController{
    [super setContainerViewController:containerViewController];
    if(containerViewController){
        [self setWantsFullScreenLayout:NO];
        self.navigationBar.y = 0;
    }
}

@end



bool swizzle_CKContainerViewController(){
    CKSwizzleSelector([UINavigationController class],@selector(wantsFullScreenLayout),@selector(UINavigationController_CKContainerViewController_wantsFullScreenLayout));
    CKSwizzleSelector([UIViewController class],@selector(interfaceOrientation),@selector(UIViewController_CKContainerController_interfaceOrientation));
    return 1;
}

static bool bo_swizzle_CKContainerViewController = swizzle_CKContainerViewController();
