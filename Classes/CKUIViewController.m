//
//  CKUIViewController.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-21.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKUIViewController.h"
#import "CKUIViewController+Style.h"
#import "CKStyleManager.h"
#import "CKDebug.h"
#include <execinfo.h>
#import "CKNSObject+Bindings.h"
#import "CKObject.h"
#import <QuartzCore/QuartzCore.h>
#import "CKFormTableViewController.h"
#import "CKVersion.h"
#import "CKStyle+Parsing.h"
#import "CKUIView+Style.h"

typedef enum CKDebugCheckState{
    CKDebugCheckState_none,
    CKDebugCheckState_NO,
    CKDebugCheckState_YES
}CKDebugCheckState;

static CKDebugCheckState CKDebugCheckForBlockCopyCurrentState = CKDebugCheckState_none;

@interface CKUIViewController()
@property(nonatomic,retain) NSString* navigationItemsBindingContext;
@property(nonatomic,retain) NSString* navigationTitleBindingContext;
@property(nonatomic,retain,readwrite) CKInlineDebuggerController* inlineDebuggerController;
@property(nonatomic,assign) BOOL styleHasBeenApplied;
@property (nonatomic, assign, readwrite) CKUIViewControllerState state;
@end

@implementation CKUIViewController

@synthesize name = _name;
@synthesize viewWillAppearBlock = _viewWillAppearBlock;
@synthesize viewWillAppearEndBlock = _viewWillAppearEndBlock;
@synthesize viewDidAppearBlock = _viewDidAppearBlock;
@synthesize viewWillDisappearBlock = _viewWillDisappearBlock;
@synthesize viewDidDisappearBlock = _viewDidDisappearBlock;
@synthesize orientationChangeBlock = _orientationChangeBlock;
@synthesize viewDidLoadBlock = _viewDidLoadBlock;
@synthesize viewDidUnloadBlock = _viewDidUnloadBlock;
@synthesize rightButton = _rightButton;
@synthesize leftButton = _leftButton;
@synthesize navigationItemsBindingContext = _navigationItemsBindingContext;
@synthesize navigationTitleBindingContext = _navigationTitleBindingContext;
@synthesize supportedInterfaceOrientations;
@synthesize inlineDebuggerController = _inlineDebuggerController;
@synthesize deallocBlock = _deallocBlock;
@synthesize styleHasBeenApplied;
@synthesize state;
@synthesize viewIsOnScreen;

- (void)supportedInterfaceOrientationsExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"CKInterfaceOrientation", 
                                               CKInterfaceOrientationPortrait,
                                               CKInterfaceOrientationLandscape,
                                               CKInterfaceOrientationAll);
}

- (void)stateExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"CKUIViewControllerState", 
                                               CKUIViewControllerStateNone,
                                               CKUIViewControllerStateWillAppear,
                                               CKUIViewControllerStateDidAppear,
                                               CKUIViewControllerStateWillDisappear,
                                               CKUIViewControllerStateDidDisappear,
                                               CKUIViewControllerStateDidUnload,
                                               CKUIViewControllerStateDidLoad);
}

- (void)postInit {	
    self.styleHasBeenApplied = NO;
    self.navigationItemsBindingContext = [NSString stringWithFormat:@"<%p>_navigationItems",self];
    self.navigationTitleBindingContext = [NSString stringWithFormat:@"<%p>_navigationTitle",self];
    self.supportedInterfaceOrientations = CKInterfaceOrientationAll;
}

- (id)init {
    self = [super init];
    if (self) {
        [self postInit];
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self postInit];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		[self postInit];
	}
	return self;
}

- (void)dealloc{
    [NSObject removeAllBindingsForContext:self.navigationItemsBindingContext];
    [NSObject removeAllBindingsForContext:self.navigationTitleBindingContext];
    [self clearBindingsContext];
    
    if(_deallocBlock){
        _deallocBlock(self);
    }
    
	[_name release];
    [_viewWillAppearBlock release];
    [_viewWillAppearEndBlock release];
    [_viewDidAppearBlock release];
    [_viewWillDisappearBlock release];
    [_viewDidDisappearBlock release];
    [_viewDidLoadBlock release];
    [_viewDidUnloadBlock release];
    [_rightButton release];
	_rightButton = nil;
	[_leftButton release];
	_leftButton = nil;
	[_navigationItemsBindingContext release];
	_navigationItemsBindingContext = nil;
	[_inlineDebuggerController release];
	_inlineDebuggerController = nil;
    [_deallocBlock release];
    _deallocBlock = nil;
    [_navigationTitleBindingContext release];
    _navigationTitleBindingContext = nil;
    [_orientationChangeBlock release];
    _orientationChangeBlock = nil;
    
	[super dealloc];
}

+ (id)controller{
	return [[[[self class]alloc]init]autorelease];
}

#pragma mark - Style Management


- (void)observerNavigationChanges:(BOOL)bo{
    /*if(bo){
        [NSObject beginBindingsContext:self.navigationItemsBindingContext policy:CKBindingsContextPolicyRemovePreviousBindings];
        [self.navigationItem bind:@"leftBarButtonItem" target:self action:@selector(leftItemChanged:)];
        [self.navigationItem bind:@"rightBarButtonItem" target:self action:@selector(rightItemChanged:)];
        [self.navigationItem bind:@"backBarButtonItem" target:self action:@selector(backItemChanged:)];
        [self.navigationItem bind:@"titleView" target:self action:@selector(titleViewChanged:)];
        [NSObject endBindingsContext];
    }
    else{
        [NSObject removeAllBindingsForContext:self.navigationItemsBindingContext];
    }
    
    UIViewController* container = self;
    if([container respondsToSelector:@selector(containerViewController)]){
        container = [container performSelector:@selector(containerViewController)];
    }
    
    while(container){
        if([container isKindOfClass:[CKUIViewController class]]){
            [(CKUIViewController*)container observerNavigationChanges:bo];
        }
        if([container respondsToSelector:@selector(containerViewController)]){
            container = [container performSelector:@selector(containerViewController)];
        }
    }*/
}

- (void)applyStyleForLeftBarButtonItem{
    [self observerNavigationChanges:NO];
    if(self.navigationItem.leftBarButtonItem){
        NSMutableDictionary* controllerStyle = [self controllerStyle];
        NSMutableDictionary* navControllerStyle = [controllerStyle styleForObject:self.navigationController  propertyName:@"navigationController"];
        NSMutableDictionary* navBarStyle = [navControllerStyle styleForObject:self.navigationController  propertyName:@"navigationBar"];
        
        NSMutableDictionary* barItemStyle = [navBarStyle styleForObject:self.navigationItem.leftBarButtonItem propertyName:@"leftBarButtonItem"];
        
        //This weird steps are needed to avoid super views layout to be called when setting the styles !
        UIBarButtonItem* item = self.navigationItem.leftBarButtonItem;
        self.navigationItem.leftBarButtonItem = nil;
        [item applyStyle:barItemStyle];
        self.navigationItem.leftBarButtonItem = item;
        
        //HACK for versions before 4.2 due to the fact that setting a custom view on a UIBarButtonItem after it has been set in the navigationItem do not work.
        if([CKOSVersion() floatValue]< 4.2){
            UIBarButtonItem* bu = self.navigationItem.leftBarButtonItem;
            self.navigationItem.leftBarButtonItem = nil;
            [self.navigationItem setLeftBarButtonItem:bu animated:YES];
        }
    }
    [self observerNavigationChanges:YES];
}

- (void)applyStyleForRightBarButtonItem{
    [self observerNavigationChanges:NO];
    if(self.navigationItem.rightBarButtonItem){
        NSMutableDictionary* controllerStyle = [self controllerStyle];
        NSMutableDictionary* navControllerStyle = [controllerStyle styleForObject:self.navigationController  propertyName:@"navigationController"];
        NSMutableDictionary* navBarStyle = [navControllerStyle styleForObject:self.navigationController  propertyName:@"navigationBar"];
        
        NSMutableDictionary* barItemStyle = [navBarStyle styleForObject:self.navigationItem.rightBarButtonItem propertyName:@"rightBarButtonItem"];
        
        //This weird steps are needed to avoid super views layout to be called when setting the styles !
        UIBarButtonItem* item = self.navigationItem.rightBarButtonItem;
        
        self.navigationItem.rightBarButtonItem = nil;
        [item applyStyle:barItemStyle];
        self.navigationItem.rightBarButtonItem = item;
        
        //HACK for versions before 4.2 due to the fact that setting a custom view on a UIBarButtonItem after it has been set in the navigationItem do not work.
        if([CKOSVersion() floatValue]< 4.2){
            UIBarButtonItem* bu = self.navigationItem.rightBarButtonItem;
            self.navigationItem.rightBarButtonItem = nil;
            [self.navigationItem setRightBarButtonItem:bu animated:YES];
        }
    }
    [self observerNavigationChanges:YES];
}

- (void)applyStyleForBackBarButtonItem{
    [self observerNavigationChanges:NO];
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
    
    [self observerNavigationChanges:YES];
}

- (void)applyStyleForTitleView{
    [self observerNavigationChanges:NO];
    if(self.navigationItem.titleView){
        NSMutableDictionary* controllerStyle = [self controllerStyle];
        NSMutableDictionary* navControllerStyle = [controllerStyle styleForObject:self.navigationController  propertyName:@"navigationController"];
        NSMutableDictionary* navBarStyle = [navControllerStyle styleForObject:self.navigationController  propertyName:@"navigationBar"];
        
        //This weird steps are needed to avoid super views layout to be called when setting the styles !
        UIView* view = self.navigationItem.titleView;
        self.navigationItem.titleView = nil;
        [view applyStyle:navBarStyle propertyName:@"titleView"];
        self.navigationItem.titleView = view;
    }
    
    [self observerNavigationChanges:YES];
}

- (void)leftItemChanged:(UIBarButtonItem*)item{
    if(self.navigationItem.backBarButtonItem == self.navigationItem.leftBarButtonItem){
        [self applyStyleForBackBarButtonItem];
    }
    else{
        [self applyStyleForLeftBarButtonItem];
    }
}

- (void)rightItemChanged:(UIBarButtonItem*)item{
    [self applyStyleForRightBarButtonItem];
}

- (void)backItemChanged:(UIBarButtonItem*)item{
    [self applyStyleForBackBarButtonItem];
}

- (void)titleViewChanged:(UIBarButtonItem*)item{
    [self applyStyleForTitleView];
}

- (void)popViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)applyStyleForNavigation{
    [self observerNavigationChanges:NO];
    
    //disable animations in case frames are set in stylesheets and currently in animation...
    [CATransaction begin];
    [CATransaction 
     setValue: [NSNumber numberWithBool: YES]
     forKey: kCATransactionDisableActions];


    NSMutableDictionary* controllerStyle = nil;
    if(!self.styleHasBeenApplied){
        controllerStyle = [self applyStyle];
        self.styleHasBeenApplied = YES;
    }
    else{
        controllerStyle = [self controllerStyle];
    }
    
    NSMutableDictionary* navControllerStyle = [controllerStyle styleForObject:self.navigationController  propertyName:@"navigationController"];
    NSMutableDictionary* navBarStyle = [self.navigationController.navigationBar applyStyle:navControllerStyle propertyName:@"navigationBar"];
    [self.navigationController.toolbar applyStyle:navControllerStyle propertyName:@"toolbar"];
    
    UIViewController* topStackController = self;
    if(self.navigationItem.leftBarButtonItem 
       && self.navigationItem.leftBarButtonItem != self.navigationItem.backBarButtonItem){
        NSMutableDictionary* barItemStyle = [navBarStyle styleForObject:self.navigationItem.leftBarButtonItem propertyName:@"leftBarButtonItem"];
        
        //This weird steps are needed to avoid super views layout to be called when setting the styles !
        UIBarButtonItem* item = self.navigationItem.leftBarButtonItem;
        self.navigationItem.leftBarButtonItem = nil;
        [item applyStyle:barItemStyle];
        self.navigationItem.leftBarButtonItem = item;
    }
    
    //Back button
    if(self.navigationItem.hidesBackButton){
        self.navigationItem.backBarButtonItem = self.navigationItem.leftBarButtonItem = nil;
    }
    else if(self.navigationItem.backBarButtonItem){
        NSMutableDictionary* backBarItemStyle = [navBarStyle styleForObject:self.navigationItem.backBarButtonItem propertyName:@"backBarButtonItem"];
        
        //This weird steps are needed to avoid super views layout to be called when setting the styles !
        UIBarButtonItem* item = self.navigationItem.backBarButtonItem;
        self.navigationItem.backBarButtonItem = nil;
        [item applyStyle:backBarItemStyle];
        self.navigationItem.backBarButtonItem = item;
    }
    else if(!self.navigationItem.leftBarButtonItem && [self.navigationController.viewControllers lastObject] == topStackController){
        NSMutableDictionary* backBarItemStyle = [navBarStyle styleForObject:self.navigationItem.backBarButtonItem propertyName:@"backBarButtonItem"];
        if(backBarItemStyle && ![backBarItemStyle isEmpty] && [self.navigationController.viewControllers count] > 1){
            UIViewController* previousController = [self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count] - 2];
            self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc]initWithTitle:previousController.title style:UIBarButtonItemStyleBordered target:self action:@selector(popViewController)]autorelease];
            
            //This weird steps are needed to avoid super views layout to be called when setting the styles !
            UIBarButtonItem* item = self.navigationItem.backBarButtonItem;
            self.navigationItem.backBarButtonItem = nil;
            self.navigationItem.leftBarButtonItem = nil;
            [item applyStyle:backBarItemStyle];
            self.navigationItem.backBarButtonItem = item;
            
            self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
        }
    }
    
    if(self.navigationItem.rightBarButtonItem){
        NSMutableDictionary* barItemStyle = [navBarStyle styleForObject:self.navigationItem.rightBarButtonItem propertyName:@"rightBarButtonItem"];
        
        //This weird steps are needed to avoid super views layout to be called when setting the styles !
        UIBarButtonItem* item = self.navigationItem.rightBarButtonItem;
        self.navigationItem.rightBarButtonItem = nil;
        [item applyStyle:barItemStyle];
        self.navigationItem.rightBarButtonItem = item;
    }
    
    if(self.navigationItem.titleView){
        //This weird steps are needed to avoid super views layout to be called when setting the styles !
        UIView* view = self.navigationItem.titleView;
        self.navigationItem.titleView = nil;
        [view applyStyle:navBarStyle propertyName:@"titleView"];
        self.navigationItem.titleView = view;
        
        if([view isKindOfClass:[UILabel class]]){
            [NSObject beginBindingsContext:_navigationTitleBindingContext policy:CKBindingsContextPolicyRemovePreviousBindings];
            [self bind:@"title" withBlock:^(id value) {
                UILabel* label = (UILabel*)view;
                label.text = [value isKindOfClass:[NSString class]] ? value : nil;
                [label sizeToFit];
            }];
            [NSObject endBindingsContext];
        }
    }else{
        UILabel* label = [[[UILabel alloc]init]autorelease];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
        label.text = self.title;
        
        self.navigationItem.titleView = label;
        [label applyStyle:navBarStyle propertyName:@"titleView"];
        
        [label sizeToFit];
        
        [NSObject beginBindingsContext:_navigationTitleBindingContext policy:CKBindingsContextPolicyRemovePreviousBindings];
        [self bind:@"title" withBlock:^(id value) {
            label.text = [value isKindOfClass:[NSString class]] ? value : nil;
            [label sizeToFit];
        }];
        [NSObject endBindingsContext];
    }
    
    [CATransaction commit];
    
    
    [self observerNavigationChanges:YES];
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated{
    self.state = CKUIViewControllerStateWillAppear;
    if(_viewWillAppearBlock){
        _viewWillAppearBlock(self,animated);
    }
    
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
    
    [self observerNavigationChanges:YES];
    
    [super viewWillAppear:animated];
    
    if(_viewWillAppearEndBlock){
        _viewWillAppearEndBlock(self,animated);
    }
    
    [self.inlineDebuggerController start];
}

- (void)viewWillDisappear:(BOOL)animated{
    self.state = CKUIViewControllerStateWillDisappear;
    [super viewWillDisappear:animated];
    if(_viewWillDisappearBlock){
        _viewWillDisappearBlock(self,animated);
    }
}

- (void)viewDidAppear:(BOOL)animated{
    self.state = CKUIViewControllerStateDidAppear;
    [super viewDidAppear:animated];
    if(_viewDidAppearBlock){
        _viewDidAppearBlock(self,animated);
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    self.state = CKUIViewControllerStateDidDisappear;
    [super viewDidDisappear:animated];
    if(_viewDidDisappearBlock){
        _viewDidDisappearBlock(self,animated);
    }
    [NSObject removeAllBindingsForContext:self.navigationItemsBindingContext];
    [NSObject removeAllBindingsForContext:self.navigationTitleBindingContext];
    [self.inlineDebuggerController stop];
}

-(void) viewDidLoad{
    self.state = CKUIViewControllerStateDidLoad;
	[super viewDidLoad];
    if(_viewDidLoadBlock){
        _viewDidLoadBlock(self);
    }
    self.styleHasBeenApplied = NO;
    
    //As this value needs to be set before viewWillAppear we force to set it here
    NSMutableDictionary* controllerStyle = [self controllerStyle];
    if([controllerStyle containsObjectForKey:@"contentSizeForViewInPopover"]){
        self.contentSizeForViewInPopover = [controllerStyle cgSizeForKey:@"contentSizeForViewInPopover"];
    }
    
    self.inlineDebuggerController = [[[CKInlineDebuggerController alloc]initWithViewController:self]autorelease];
}

-(void) viewDidUnload{
    self.state = CKUIViewControllerStateDidUnload;
	[super viewDidUnload];
    if(_viewDidUnloadBlock){
        _viewDidUnloadBlock(self);
    }
    
    [_inlineDebuggerController release];
    _inlineDebuggerController = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if(UIInterfaceOrientationIsPortrait(interfaceOrientation)
       && (self.supportedInterfaceOrientations & CKInterfaceOrientationPortrait))
        return YES;
    if(UIInterfaceOrientationIsLandscape(interfaceOrientation)
       && (self.supportedInterfaceOrientations & CKInterfaceOrientationLandscape))
        return YES;
    return NO;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    if(_orientationChangeBlock){
        _orientationChangeBlock(self,toInterfaceOrientation);
    }
    
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    NSMutableDictionary* viewStyle = [[self controllerStyle]styleForObject:self.view  propertyName:@"view"];
    [[self.view class] applyStyle:viewStyle toView:self.view appliedStack:nil delegate:nil];//Apply only on view and not hierarchy !
    
    [self applyStyleForNavigation];
}

- (BOOL)viewIsOnScreen{
    return (self.state & CKUIViewControllerStateWillAppear) || (self.state & CKUIViewControllerStateDidAppear);
}

#pragma mark - Buttons Management

- (void)setLeftButton:(UIBarButtonItem *)theleftButton{
    [_leftButton release];
    _leftButton = [theleftButton retain];
    if(self.viewIsOnScreen){
        [self.navigationItem setLeftBarButtonItem:theleftButton animated:YES];
        [self applyStyleForLeftBarButtonItem];
        
            //HACK for versions before 4.2 due to the fact that setting a custom view on a UIBarButtonItem after it has been set in the navigationItem do not work.
        if([CKOSVersion() floatValue]< 4.2){
            self.navigationItem.leftBarButtonItem = nil;
            [self.navigationItem setLeftBarButtonItem:theleftButton animated:YES];
        }
    }
}

- (void)setRightButton:(UIBarButtonItem *)theRightButton{
    [_rightButton release];
    _rightButton = [theRightButton retain];
    if(self.viewIsOnScreen){
        [self.navigationItem setRightBarButtonItem:theRightButton animated:YES];
        [self applyStyleForRightBarButtonItem];
        
            //HACK for versions before 4.2 due to the fact that setting a custom view on a UIBarButtonItem after it has been set in the navigationItem do not work.
        if([CKOSVersion() floatValue]< 4.2){
            self.navigationItem.rightBarButtonItem = nil;
            [self.navigationItem setRightBarButtonItem:theRightButton animated:YES];
        }
    }
}


#ifdef DEBUG
- (void)CheckForBlockCopy{
    if(CKDebugCheckForBlockCopyCurrentState == CKDebugCheckState_none){
        BOOL bo = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CKDebugCheckForBlockCopy"]boolValue];
        CKDebugCheckForBlockCopyCurrentState = bo ? CKDebugCheckState_YES : CKDebugCheckState_NO;
    }
    
    if(CKDebugCheckForBlockCopyCurrentState != CKDebugCheckState_YES)
        return;
    
    void *frames[128];
    int len = backtrace(frames, 128);
    char **symbols = backtrace_symbols(frames, len);
    for (int i = 0; i < len; ++i) {
        NSString* string = [NSString stringWithUTF8String:symbols[i]];
        NSRange range = [string rangeOfString:@"__copy_helper_block_"];
        if(range.location != NSNotFound){
            NSAssert(NO,@"You are retaining an object in a block copy !\nPlease define a variable with __block %@* bYourVar = yourVar; outside the scope of the block and use bYourVar in your block instead of yourVar.",[self class]);
        }
    }
    free(symbols);
}


- (id)retain{
    [self CheckForBlockCopy];
    return [super retain];
}
#endif



- (void)setEditing:(BOOL)editing{
    [self willChangeValueForKey:@"editing"];
    [super setEditing:editing];
    [self didChangeValueForKey:@"editing"];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated{
    [self willChangeValueForKey:@"editing"];
    [super setEditing:editing animated:animated];
    [self didChangeValueForKey:@"editing"];
}

@end

