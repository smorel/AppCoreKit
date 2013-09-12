//
//  CKInlineDebuggerController.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import "CKInlineDebuggerController.h"
#import "CKWeakRef.h"
#import "UIViewController+InlineDebugger.h"
#import "CKLocalization.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+Positioning.h"
#import "CKStoreExplorer.h"
#import "CKDocument.h"
#import "CKUserDefaults.h"
#import "CKStyleManager.h"
#import <objc/runtime.h>
#import "NSObject+Bindings.h"
#import "CKPopoverController.h"
#import "NSObject+Singleton.h"
#import "CKConfiguration.h"



@interface UIView(CKViewController)
@end


@interface UIViewController (CKViewController)

+ (void)findControllersDisplayedInWidow:(UIWindow*)window controllers:(NSMutableArray*)controllers views:(NSMutableArray*)views;

@end

@implementation UIView(CKViewController)

+ (void)createsPathRecursivelyForView:(UIView*)view inString:(NSMutableString*)string{
    UIView* parentView = [view superview];
    if(parentView){
        NSInteger index = [[parentView subviews]indexOfObjectIdenticalTo:view];
        if([string length] > 0){
            [string insertString:@"/" atIndex:0];
        }
        [string insertString:[NSString stringWithFormat:@"%ld",(long)index] atIndex:0];
        
        [UIControl createsPathRecursivelyForView:parentView inString:string];
    }
}

- (NSString*)computeMetricsPath{
    NSMutableString* string = [NSMutableString string];
    [UIControl createsPathRecursivelyForView:self inString:string];
    return string;
}

+ (void)appendViewHierarchyForView:(UIView*)view inArray:(NSMutableArray*)views{
    if(!view) return;
    
    [views addObject:view];
    [UIControl appendViewHierarchyForView:[view superview] inArray:views];
}

- (UIViewController*)findParentActivity{
    NSMutableArray* controllers = [NSMutableArray array];
    NSMutableArray* views = [NSMutableArray array];
    [UIViewController findControllersDisplayedInWidow:self.window controllers:controllers views:views];
    
    NSMutableArray* viewHierarchy = [NSMutableArray array];
    [UIControl appendViewHierarchyForView:self inArray:viewHierarchy];
    
    for(UIView* view in viewHierarchy){
        NSInteger index = [views indexOfObjectIdenticalTo:view];
        if(index != NSNotFound){
            UIViewController* viewController = [controllers objectAtIndex:index];
            return viewController;
        }
    }
    
    return nil;
}

@end



@implementation UIViewController (CKViewController)

- (void)registerToControllers:(NSMutableArray*)controllers views:(NSMutableArray*)views{
    [controllers addObject:self];
    [views addObject:self.view];
    
    if([self isKindOfClass:[UINavigationController class]]){
        UINavigationController* navigationController = (UINavigationController*)self;
        [navigationController.topViewController registerToControllers:controllers views:views];
    }
    else if ([self isKindOfClass:[UISplitViewController class]]) {
        UISplitViewController* splitViewController = (UISplitViewController*)self;
        for (UIViewController *controller in splitViewController.viewControllers) {
            [controller registerToControllers:controllers views:views];
        }
    }
    else if ([self isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)self;
        for (UIViewController *controller in tabBarController.viewControllers) {
            [controller registerToControllers:controllers views:views];
        }
    }
    else{
        Class UIPageViewControllerClass = NSClassFromString(@"UIPageViewController");
        if (UIPageViewControllerClass) {
            if ([self isKindOfClass:UIPageViewControllerClass]) {
                NSArray *viewController = [self performSelector:@selector(viewControllers)];
                for (UIViewController *controller in viewController) {
                    [controller registerToControllers:controllers views:views];
                }
            }
        }
        
        Class CKContainerViewControllerClass = NSClassFromString(@"CKContainerViewController");
        if(CKContainerViewControllerClass){
            if([self isKindOfClass:CKContainerViewControllerClass] && [self respondsToSelector:@selector(selectedViewController)]){
                UIViewController* selectedController = [self performSelector:@selector(selectedViewController)];
                [selectedController registerToControllers:controllers views:views];
            }
        }
        
        Class CKSplitViewControllerClass = NSClassFromString(@"CKSplitViewController");
        if(CKSplitViewControllerClass){
            if([self isKindOfClass:CKSplitViewControllerClass]){
                NSArray* viewControllers = [self performSelector:@selector(viewControllers)];
                for(UIViewController* viewController in viewControllers){
                    [viewController registerToControllers:controllers views:views];
                }
            }
        }
    }
    
    if(self.modalViewController){
        [self.modalViewController registerToControllers:controllers views:views];
    }
}

+ (void)findControllersDisplayedInWidow:(UIWindow*)window controllers:(NSMutableArray*)controllers views:(NSMutableArray*)views{
    UIViewController* controller = [window rootViewController];
    if (controller == nil) {
        NSArray *windowSubview = window.subviews;
        if (windowSubview.count != 0)
            controller = [[windowSubview objectAtIndex:0] valueForKey:@"_viewDelegate"];
    }
    
    [controller registerToControllers:controllers views:views];
    
    NSSet* popovers = [[CKPopoverManager sharedInstance]nonRetainedPopoverControllerValues];
    for(NSValue* v in popovers){
        CKPopoverController* popoverController = [v nonretainedObjectValue];
        [popoverController.contentViewController registerToControllers:controllers views:views];
    }
}

@end





@interface CKInlineDebuggerController()
@property(nonatomic,retain)CKWeakRef* viewControllerRef;
@property(nonatomic,readonly)UIViewController* viewController;
@property(nonatomic,assign,readwrite)CKInlineDebuggerControllerState state;
@property (nonatomic,retain) id debugModalController;
@property(nonatomic,retain)UIView* touchedView;
@property(nonatomic,retain)UIView* debuggingView;
@property(nonatomic,retain)UIView* debuggingHighlightView;
@property(nonatomic,retain)NSMutableArray* supperHighlightViews;
@property(nonatomic,retain)UILabel* highlightLabel;
@property(nonatomic,retain)NSMutableArray* possibleSuperViews;
@property(nonatomic,retain)NSMutableArray* customGestures;
@property(nonatomic,retain)UITapGestureRecognizer* mainGesture;
@property(nonatomic,retain)UIBarButtonItem* oldRightButtonItem;
@property(nonatomic,retain)UIBarButtonItem* oldLeftButtonItem;
@property(nonatomic,assign)BOOL started;
@property(nonatomic,retain) NSString* configCheckBindingContext;

- (void)highlightView:(UIView*)view;

@end

@implementation CKInlineDebuggerController
@synthesize viewControllerRef = _viewControllerRef;
@synthesize debugModalController = _debugModalController;
@synthesize debuggingView = _debuggingView;
@synthesize debuggingHighlightView = _debuggingHighlightView;
@synthesize supperHighlightViews = _supperHighlightViews;
@synthesize highlightLabel = _highlightLabel;
@synthesize possibleSuperViews = _possibleSuperViews;
@synthesize touchedView = _touchedView;
@synthesize customGestures = _customGestures;
@synthesize mainGesture = _mainGesture;
@synthesize oldRightButtonItem = _oldRightButtonItem;
@synthesize oldLeftButtonItem = _oldLeftButtonItem;
@synthesize state;
@synthesize viewController;
@synthesize started;

- (id)initWithViewController:(UIViewController*)theviewController{
    self = [super init];
    self.state = CKInlineDebuggerControllerStatePending;
    self.viewControllerRef = [CKWeakRef weakRefWithObject:theviewController];
    self.started = NO;
    
    __block CKInlineDebuggerController* bDebugger = self;
    self.configCheckBindingContext = [NSString stringWithFormat:@"<%p>_configurationCheck",self];
    [NSObject beginBindingsContext:self.configCheckBindingContext];
    [[CKConfiguration sharedInstance]bind:@"inlineDebuggerEnabled" withBlock:^(id value) {
        if([value boolValue] && !bDebugger.started){
            [bDebugger start];
        }else if(![value boolValue] && bDebugger.started){
            [bDebugger stop];
        }
    }];
    [NSObject endBindingsContext];
    
    return self;
}

- (void)updateConfig{
    
}

- (void)start{
    if([[CKConfiguration sharedInstance]inlineDebuggerEnabled]){
        self.started = YES;
        self.customGestures = [NSMutableArray array];
        
        self.mainGesture = [[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(twoTapGesture:)]autorelease];
        _mainGesture.numberOfTapsRequired = 2;
        [self.viewController.navigationController.navigationBar addGestureRecognizer:_mainGesture];
        
        if(self.state == CKInlineDebuggerControllerStateDebugging){
            self.oldRightButtonItem = self.viewController.navigationItem.rightBarButtonItem;
            self.oldLeftButtonItem = self.viewController.navigationItem.leftBarButtonItem;
            self.viewController.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]initWithTitle:_(@"Inspector") style:UIBarButtonItemStyleBordered target:self action:@selector(inspector:)]autorelease];
            self.viewController.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]initWithTitle:_(@"Documents") style:UIBarButtonItemStyleBordered target:self action:@selector(documents:)]autorelease];
            
            for(UIGestureRecognizer* gesture in self.customGestures){
                [self.viewController.view addGestureRecognizer:gesture];
            }
        }
    }
}

- (void)stop{
    [self.viewController.navigationController.navigationBar removeGestureRecognizer:self.mainGesture];
    for(UIGestureRecognizer* gesture in self.customGestures){
        [self.viewController.view removeGestureRecognizer:gesture];
    }

    if(self.state == CKInlineDebuggerControllerStateDebugging){
        self.viewController.navigationItem.rightBarButtonItem = self.oldRightButtonItem;
        self.viewController.navigationItem.leftBarButtonItem = self.oldLeftButtonItem;
        self.oldRightButtonItem = nil;
        self.oldLeftButtonItem = nil;
        self.state = CKInlineDebuggerControllerStatePending;
    }
    self.started = NO;
}

- (void)dealloc{
    [NSObject removeAllBindingsForContext:self.configCheckBindingContext];
    if(self.viewController){
        [self highlightView:nil];
        [self.viewController.navigationController.navigationBar removeGestureRecognizer:self.mainGesture];
    }
    [_viewControllerRef release];
    _viewControllerRef = nil;
    [_debugModalController release];
    _debugModalController = nil;
    [_debuggingHighlightView release];
    _debuggingHighlightView = nil;
    [_debuggingView release];
    _debuggingView = nil;
    [_supperHighlightViews release];
    _supperHighlightViews = nil;
    [_highlightLabel release];
    _highlightLabel = nil;
    [_possibleSuperViews release];
    _possibleSuperViews = nil;
    [_touchedView release];
    _touchedView = nil;
    [_customGestures release];
    _customGestures = nil;
    [_mainGesture release];
    _mainGesture = nil;
    [_oldRightButtonItem release];
    _oldRightButtonItem = nil;
    [_oldLeftButtonItem release];
    _oldLeftButtonItem = nil;
    [_configCheckBindingContext release];
    _configCheckBindingContext = nil;
    [super dealloc];
}

- (UIViewController*)viewController{
    return self.viewControllerRef.object;
}

/********************************* HIT TEST *******************************
 */

- (void)hitTest:(CGPoint)point currentOrigin:(CGPoint)origin inView:(UIView*)view stack:(NSMutableArray*)stack{
    if(view.hidden == YES || view.alpha == 0){
        return;
    }
    
    if(view == self.debuggingHighlightView
       || view == self.highlightLabel
       || ( _supperHighlightViews && [self.supperHighlightViews indexOfObjectIdenticalTo:view] != NSNotFound)){
    }
    else{
        if([view superview]){
            point = [view convertPoint:point fromView:[view superview]];
        }
        
        if([view pointInside:point withEvent:nil]){
            [stack insertObject:view atIndex:0];
            
            for(UIView* v in view.subviews){
                [self hitTest:point currentOrigin:origin inView:v stack:stack];
            }
        }
    }
}

- (void)hitTest:(CGPoint)point stack:(NSMutableArray*)stack{
    [self hitTest:point currentOrigin:CGPointMake(0,0) inView:self.viewController.view stack:stack];
}

- (UIView*)hitTest:(CGPoint)point{
    NSMutableArray* stack = [NSMutableArray array];
    [self hitTest:point stack:stack];
    return [stack count] > 0 ? [stack objectAtIndex:0] : nil;
}

- (BOOL)isView:(UIView*)superView supperViewOf:(UIView*)view{
    UIView* v = view;
    while(v){
        if(v == superView){
            return YES;
        }
        v = [v superview];
    }
    return NO;
}

/******************************** Debugger View Controller **************************
 */

- (void)presentInlineDebuggerForSubView:(UIView*)view fromParentController:(UIViewController*)controller{
    CKFormTableViewController* debugger = [[view findParentActivity] inlineDebuggerForSubView:view];
    
    debugger.title = [NSString stringWithFormat:@"%@ <%p>",[view class],view];
    UIBarButtonItem* close = [[[UIBarButtonItem alloc] initWithTitle:_(@"Done") style:UIBarButtonItemStyleBordered target:self action:@selector(closeDebug:)]autorelease];
    debugger.leftButton = close;
    UINavigationController* navc = [[[UINavigationController alloc]initWithRootViewController:debugger]autorelease];
    navc.modalPresentationStyle = UIModalPresentationPageSheet;
    
    self.debugModalController = debugger;
    
    [controller presentModalViewController:navc animated:YES];
}

- (void)presentInlineDebuggerForDocumentsfromParentController:(UIViewController*)controller{
    CKFormTableViewController* debugger = [[[CKFormTableViewController alloc]initWithStyle:UITableViewStylePlain] autorelease];
    debugger.name = @"CKInlineDebugger";
    
    __block CKFormTableViewController* bDebugger = debugger;
    
    //User Defaults
    NSArray* userDefaultsClasses = [NSObject allClassesKindOfClass:[CKUserDefaults class]];
    NSMutableSet* userDefaultInstances = [NSMutableSet set];
    for(Class c in userDefaultsClasses){
        [userDefaultInstances addObject:[c sharedInstance]];
    }
    
    NSMutableArray* userDefaultsCellControllers = [NSMutableArray array];
    for(id userDefault in userDefaultInstances){
        CKTableViewCellController* cell = [CKTableViewCellController cellControllerWithTitle:[[userDefault  class] description] action:^(CKTableViewCellController* controller){
            CKFormTableViewController* udDebugger = [[userDefault  class] inlineDebuggerForObject:userDefault];
            udDebugger.title = [[userDefault  class] description];
            [bDebugger.navigationController pushViewController:udDebugger animated:YES];
        }];
        [userDefaultsCellControllers addObject:cell];
    }
    CKFormSection* userDefaultsSection = [CKFormSection sectionWithCellControllers:userDefaultsCellControllers headerTitle:@"User Defaults"];
    
    
    //Documents
    NSArray* documentClasses = [NSObject allClassesKindOfClass:[CKDocument class]];
    NSMutableSet* documentInstances = [NSMutableSet set];
    for(Class c in documentClasses){
        [documentInstances addObject:[c sharedInstance]];
    }
    
    NSMutableArray* documentCellControllers = [NSMutableArray array];
    for(id document in documentInstances){
        CKTableViewCellController* cell = [CKTableViewCellController cellControllerWithTitle:[[document class] description] action:^(CKTableViewCellController* controller){
            CKFormTableViewController* udDebugger = [[document class] inlineDebuggerForObject:document];
            udDebugger.title = [[document  class] description];
            [bDebugger.navigationController pushViewController:udDebugger animated:YES];
        }];
        [documentCellControllers addObject:cell];
    }
    CKFormSection* documentSection = [CKFormSection sectionWithCellControllers:documentCellControllers headerTitle:@"Documents"];
    
    //Core Data
    CKTableViewCellController* storeExplorerCell = [CKTableViewCellController cellControllerWithTitle:@"CKStore explorer" action:^(CKTableViewCellController* controller){
        CKStoreExplorer* storeExplorer = [[[CKStoreExplorer alloc]init]autorelease];
        [bDebugger.navigationController pushViewController:storeExplorer animated:YES];
    }];
    CKFormSection* coreDataSection = [CKFormSection sectionWithCellControllers:[NSArray arrayWithObject:storeExplorerCell] headerTitle:@"Core Data"];
    [debugger addSections:[NSArray arrayWithObjects:userDefaultsSection,documentSection,coreDataSection,nil]];
    
    //Init
    debugger.title = @"Documents";
    UIBarButtonItem* close = [[[UIBarButtonItem alloc] initWithTitle:_(@"Done") style:UIBarButtonItemStyleBordered target:self action:@selector(closeDebug:)]autorelease];
    debugger.leftButton = close;
    UINavigationController* navc = [[[UINavigationController alloc]initWithRootViewController:debugger]autorelease];
    navc.modalPresentationStyle = UIModalPresentationPageSheet;
    
    self.debugModalController = debugger;
    
    [controller presentModalViewController:navc animated:YES];
}

- (void)closeDebug:(id)sender{
	[self.debugModalController dismissModalViewControllerAnimated:YES];
	self.debugModalController = nil;
}

/******************************** GESTURES *******************************
 */

- (void)computeTopViews:(NSMutableArray*)topViews inView:(UIView*)view{
    if([[view subviews]count] == 0){
        [topViews addObject:view];
    }
    else{
        for(UIView* v in [view subviews]){
            [self computeTopViews:topViews inView:v];
        }
    }
}

- (void)computePossibleSuperViewfromView:(UIView*)view{
    NSMutableArray* topViews = [NSMutableArray array];
    [topViews addObject:view];
    [self computeTopViews:topViews inView:[view superview]];
    self.possibleSuperViews = topViews;
}

- (void)highlightView:(UIView*)view{
    if(self.debuggingView != view){
        for(UIView* v in _supperHighlightViews){
            [v removeFromSuperview];
        }
        
        if(view == nil){
            self.debuggingView = nil;
            [_debuggingHighlightView removeFromSuperview];
            [_highlightLabel removeFromSuperview];
        }
        else{
            if(_debuggingHighlightView == nil){
                self.debuggingHighlightView = [[[UIView alloc]initWithFrame:view.bounds]autorelease];
                _debuggingHighlightView.backgroundColor = [UIColor redColor];
                _debuggingHighlightView.tag = CKInlineDebuggerControllerHighlightViewTag;
                _debuggingHighlightView.alpha = 0.4;
                _debuggingHighlightView.layer.borderWidth = 3;
                _debuggingHighlightView.layer.borderColor = [[UIColor redColor]CGColor];
                _debuggingHighlightView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            }
            
            self.debuggingView = view;
            _debuggingHighlightView.frame = view.bounds;
            [view addSubview:_debuggingHighlightView];
            
            [self computePossibleSuperViewfromView:view];
            
            if(_supperHighlightViews == nil){
                self.supperHighlightViews = [NSMutableArray array];
            }
            
            int i =0;
            for(UIView* v in self.possibleSuperViews){
                if(v != _highlightLabel){
                    if(i >= [_supperHighlightViews count]){
                        UIView* subViewHighlight = [[[UIView alloc]initWithFrame:v.bounds]autorelease];
                        subViewHighlight.backgroundColor = [UIColor clearColor];
                        subViewHighlight.layer.borderWidth = 2;
                        subViewHighlight.tag = CKInlineDebuggerControllerHighlightViewTag;
                        subViewHighlight.layer.borderColor = [[UIColor colorWithRed:((float)rand()/(float)RAND_MAX) 
                                                                             green:((float)rand()/(float)RAND_MAX) 
                                                                              blue:((float)rand()/(float)RAND_MAX)  
                                                                             alpha:1]CGColor];
                        subViewHighlight.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
                        [_supperHighlightViews addObject:subViewHighlight];
                    }
                    
                    UIView* hv = [_supperHighlightViews objectAtIndex:i];
                    hv.frame = v.bounds;
                    [v addSubview:hv];
                    ++i;
                }
            }
            
            if(_highlightLabel == nil){
                self.highlightLabel = [[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 10, 40)]autorelease];
                _highlightLabel.tag = CKInlineDebuggerControllerHighlightViewTag;
                _highlightLabel.layer.cornerRadius = 10;
                _highlightLabel.backgroundColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:0.6];
                _highlightLabel.textColor = [UIColor whiteColor];
                _highlightLabel.textAlignment = UITextAlignmentCenter;
                _highlightLabel.numberOfLines = 2;
            }
            
            [self beginBindingsContextByRemovingPreviousBindings];
            [view bind:@"frame" executeBlockImmediatly:YES withBlock:^(id value) {
                _highlightLabel.text = [NSString stringWithFormat:@"%@\n%@",[[view class]description],NSStringFromCGRect([view frame])];
                [_highlightLabel sizeToFit];
                
                _highlightLabel.width += 20;
                _highlightLabel.center = self.viewController.view.center;
                _highlightLabel.y = 5;
            }];
            [self endBindingsContext];
            
            [self.viewController.view addSubview:_highlightLabel];
        }
    }
}

- (void)updateGestureWithPoint:(CGPoint)point allowSuperView:(BOOL)allowSuperView{
    UIView* thetouchedView = [self hitTest:point];	
    if(thetouchedView == _debuggingHighlightView){
        thetouchedView = [_debuggingHighlightView superview];
    }
    
    if(thetouchedView != self.touchedView){
        [self highlightView:thetouchedView];
    }
    else{
        NSMutableArray* stack = [NSMutableArray array];
        [self hitTest:point stack:stack];
        
        UIView* touchedSuperView = self.debuggingView;
        for(UIView* v in self.possibleSuperViews){
            NSInteger index = [stack indexOfObjectIdenticalTo:v];
            if(index != NSNotFound){
                touchedSuperView = v;
                break;
            }
        }
        
        NSInteger index = [stack indexOfObjectIdenticalTo:touchedSuperView];
        if(index != NSNotFound){
            if(allowSuperView && touchedSuperView == self.debuggingView && index < [stack count] - 2){
                [self highlightView:[stack objectAtIndex:index + 1]];
            }
            else if(allowSuperView && touchedSuperView == self.debuggingView && index != NSNotFound){
                [self highlightView:[stack objectAtIndex:0]];
            }
            else if(!allowSuperView || touchedSuperView != self.debuggingView){
                [self highlightView:touchedSuperView];
            }
        }
        else{
            [self highlightView:thetouchedView];
        }
    }
    
    self.touchedView = thetouchedView;
}

- (void)tapGesture:(UILongPressGestureRecognizer *)recognizer{
    if(self.state == CKInlineDebuggerControllerStatePending
       || self.debuggingView == nil){
        return;
    }
    
    if(recognizer.state == UIGestureRecognizerStateRecognized){
        CGPoint point = [recognizer locationInView:self.viewController.view];
        [self updateGestureWithPoint:point allowSuperView:YES];
    }
}

- (void)twoTapGesture:(UILongPressGestureRecognizer *)recognizer{
    if(recognizer.state == UIGestureRecognizerStateRecognized){
        CGPoint point = [recognizer locationInView:self.viewController.view];
        UIView* touchedView = [self hitTest:point];	
        if(touchedView == _debuggingHighlightView){
            touchedView = [_debuggingHighlightView superview];
        }
        
        //Switch
        BOOL active = (self.state == CKInlineDebuggerControllerStateDebugging) ? NO: YES;
        [self setActive:active withView:touchedView];
    }
}


- (void)setActive:(BOOL)bo withView:(UIView*)touchedView{
    if(!bo){
        self.state = CKInlineDebuggerControllerStatePending;
        for(UIGestureRecognizer* gesture in self.customGestures){
            [self.viewController.view removeGestureRecognizer:gesture];
        }

        [self highlightView:nil];
        self.viewController.navigationItem.rightBarButtonItem = self.oldRightButtonItem;
        self.viewController.navigationItem.leftBarButtonItem = self.oldLeftButtonItem;
    }
    else{
        self.state = CKInlineDebuggerControllerStateDebugging;
        self.oldRightButtonItem = self.viewController.navigationItem.rightBarButtonItem;
        self.oldLeftButtonItem = self.viewController.navigationItem.leftBarButtonItem;
        self.viewController.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]initWithTitle:_(@"Inspector") style:UIBarButtonItemStyleBordered target:self action:@selector(inspector:)]autorelease];
        self.viewController.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]initWithTitle:_(@"Documents") style:UIBarButtonItemStyleBordered target:self action:@selector(documents:)]autorelease];
        
        UITapGestureRecognizer* tapGesture = [[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)]autorelease];
        tapGesture.numberOfTapsRequired = 1;
        [self.viewController.view addGestureRecognizer:tapGesture];
        [self.customGestures addObject:tapGesture];
        
        UILongPressGestureRecognizer* longGesture = [[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longGesture:)]autorelease];
        longGesture.allowableMovement = 10000;
        [self.viewController.view addGestureRecognizer:longGesture];
        [self.customGestures addObject:longGesture];
        
        [self highlightView:touchedView ? touchedView : self.viewController.view];
    }
}

- (void)longGesture:(UILongPressGestureRecognizer *)recognizer{
    if(self.state == CKInlineDebuggerControllerStatePending){
        return;
    }
    
    CGPoint point = [recognizer locationInView:self.viewController.view];
    [self updateGestureWithPoint:point allowSuperView:NO];
}

- (void)inspector:(id)sender{
    UINavigationController* myNavigationController = self.viewController.navigationController;
    UIViewController* topController = [myNavigationController topViewController];
    [self presentInlineDebuggerForSubView:self.debuggingView fromParentController:topController];
}

- (void)documents:(id)sender{
    UINavigationController* myNavigationController = self.viewController.navigationController;
    UIViewController* topController = [myNavigationController topViewController];
    [self presentInlineDebuggerForDocumentsfromParentController:topController];
}

@end
