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
#import "CKModelObject.h"
#import <QuartzCore/QuartzCore.h>
#import "CKFormTableViewController.h"
#import "CKLocalization.h"
#import "CKInlineDebuggerController.h"

typedef enum CKDebugCheckState{
    CKDebugCheckState_none,
    CKDebugCheckState_NO,
    CKDebugCheckState_YES
}CKDebugCheckState;

static CKDebugCheckState CKDebugCheckForBlockCopyCurrentState = CKDebugCheckState_none;

@interface CKUIViewController()
@property(nonatomic,retain)NSString* navigationItemsBindingContext;
@property(nonatomic,retain)CKInlineDebuggerController* inlineDebuggerController;
@end

@implementation CKUIViewController

@synthesize name = _name;
@synthesize viewWillAppearBlock = _viewWillAppearBlock;
@synthesize viewDidAppearBlock = _viewDidAppearBlock;
@synthesize viewWillDisappearBlock = _viewWillDisappearBlock;
@synthesize viewDidDisappearBlock = _viewDidDisappearBlock;
@synthesize viewDidLoadBlock = _viewDidLoadBlock;
@synthesize viewDidUnloadBlock = _viewDidUnloadBlock;
@synthesize rightButton = _rightButton;
@synthesize leftButton = _leftButton;
@synthesize navigationItemsBindingContext = _navigationItemsBindingContext;
@synthesize supportedInterfaceOrientations;
@synthesize inlineDebuggerController = _inlineDebuggerController;

- (void)supportedInterfaceOrientationsMetaData:(CKObjectPropertyMetaData*)metaData{
    metaData.enumDescriptor = CKEnumDefinition(@"CKInterfaceOrientation", 
                                               CKInterfaceOrientationPortrait,
                                               CKInterfaceOrientationLandscape,
                                               CKInterfaceOrientationAll);
}

- (void)postInit {	
    self.navigationItemsBindingContext = [NSString stringWithFormat:@"<%p>_navigationItems",self];
    self.supportedInterfaceOrientations = CKInterfaceOrientationAll;
    self.inlineDebuggerController = [[[CKInlineDebuggerController alloc]initWithViewController:self]autorelease];
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
	[_name release];
    [_viewWillAppearBlock release];
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
    
	[super dealloc];
}


- (void)applyStyleForLeftBarButtonItem{
    if(self.navigationItem.leftBarButtonItem){
        NSMutableDictionary* controllerStyle = [[CKStyleManager defaultManager] styleForObject:self  propertyName:nil];
        NSMutableDictionary* navControllerStyle = [controllerStyle styleForObject:self.navigationController  propertyName:@"navigationController"];
        NSMutableDictionary* navBarStyle = [navControllerStyle styleForObject:self.navigationController  propertyName:@"navigationBar"];
        
        NSMutableDictionary* barItemStyle = [navBarStyle styleForObject:self.navigationItem.leftBarButtonItem propertyName:@"leftBarButtonItem"];
        [self.navigationItem.leftBarButtonItem applyStyle:barItemStyle];
    }
}

- (void)applyStyleForRightBarButtonItem{
    if(self.navigationItem.rightBarButtonItem){
        NSMutableDictionary* controllerStyle = [[CKStyleManager defaultManager] styleForObject:self  propertyName:nil];
        NSMutableDictionary* navControllerStyle = [controllerStyle styleForObject:self.navigationController  propertyName:@"navigationController"];
        NSMutableDictionary* navBarStyle = [navControllerStyle styleForObject:self.navigationController  propertyName:@"navigationBar"];
        
        NSMutableDictionary* barItemStyle = [navBarStyle styleForObject:self.navigationItem.rightBarButtonItem propertyName:@"rightBarButtonItem"];
        [self.navigationItem.rightBarButtonItem applyStyle:barItemStyle];
    }
}

- (void)applyStyleForBackBarButtonItem{
    if(self.navigationItem.backBarButtonItem){
        NSMutableDictionary* controllerStyle = [[CKStyleManager defaultManager] styleForObject:self  propertyName:nil];
        NSMutableDictionary* navControllerStyle = [controllerStyle styleForObject:self.navigationController  propertyName:@"navigationController"];
        NSMutableDictionary* navBarStyle = [navControllerStyle styleForObject:self.navigationController  propertyName:@"navigationBar"];
        
        NSMutableDictionary* barItemStyle = [navBarStyle styleForObject:self.navigationItem.backBarButtonItem propertyName:@"backBarButtonItem"];
        [self.navigationItem.backBarButtonItem applyStyle:barItemStyle];
    }
}

- (void)applyStyleForTitleView{
    if(self.navigationItem.titleView){
        NSMutableDictionary* controllerStyle = [[CKStyleManager defaultManager] styleForObject:self  propertyName:nil];
        NSMutableDictionary* navControllerStyle = [controllerStyle styleForObject:self.navigationController  propertyName:@"navigationController"];
        NSMutableDictionary* navBarStyle = [navControllerStyle styleForObject:self.navigationController  propertyName:@"navigationBar"];
        
        [self.navigationItem.titleView applyStyle:navBarStyle propertyName:@"titleView"];
    }
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
    //disable animations in case frames are set in stylesheets and currently in animation...
    [CATransaction begin];
    [CATransaction 
     setValue: [NSNumber numberWithBool: YES]
     forKey: kCATransactionDisableActions];
    
	NSMutableDictionary* controllerStyle = [[CKStyleManager defaultManager] styleForObject:self  propertyName:nil];
    NSMutableDictionary* navControllerStyle = [controllerStyle styleForObject:self.navigationController  propertyName:@"navigationController"];
    NSMutableDictionary* navBarStyle = [self.navigationController.navigationBar applyStyle:navControllerStyle propertyName:@"navigationBar"];
    [self.navigationController.toolbar applyStyle:navControllerStyle propertyName:@"toolbar"];
    
    UIViewController* topStackController = self;
    if(self.navigationItem.leftBarButtonItem 
       && self.navigationItem.leftBarButtonItem != self.navigationItem.backBarButtonItem){
        NSMutableDictionary* barItemStyle = [navBarStyle styleForObject:self.navigationItem.leftBarButtonItem propertyName:@"leftBarButtonItem"];
        [self.navigationItem.leftBarButtonItem applyStyle:barItemStyle];
    }
    
    if(self.navigationItem.backBarButtonItem){
        NSMutableDictionary* backBarItemStyle = [navBarStyle styleForObject:self.navigationItem.backBarButtonItem propertyName:@"backBarButtonItem"];
        [self.navigationItem.backBarButtonItem applyStyle:backBarItemStyle];
    }
    else if(!self.navigationItem.leftBarButtonItem && [self.navigationController.viewControllers lastObject] == topStackController){
        NSMutableDictionary* backBarItemStyle = [navBarStyle styleForObject:self.navigationItem.backBarButtonItem propertyName:@"backBarButtonItem"];
        if(backBarItemStyle && ![backBarItemStyle isEmpty] && [self.navigationController.viewControllers count] > 1){
            UIViewController* previousController = [self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count] - 2];
            self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]initWithTitle:previousController.title style:UIBarButtonItemStyleBordered target:self action:@selector(popViewController)]autorelease];
            [self.navigationItem.leftBarButtonItem applyStyle:backBarItemStyle];
            self.navigationItem.backBarButtonItem = self.navigationItem.leftBarButtonItem;
        }
    }
    
    if(self.navigationItem.rightBarButtonItem){
        NSMutableDictionary* barItemStyle = [navBarStyle styleForObject:self.navigationItem.rightBarButtonItem propertyName:@"rightBarButtonItem"];
        [self.navigationItem.rightBarButtonItem applyStyle:barItemStyle];
    }
    
    if(self.navigationItem.titleView){
        [self.navigationItem.titleView applyStyle:navBarStyle propertyName:@"titleView"];
    }
    
    [CATransaction commit];
}

- (void)viewWillAppear:(BOOL)animated{
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
    
    
    [NSObject beginBindingsContext:self.navigationItemsBindingContext policy:CKBindingsContextPolicyRemovePreviousBindings];
    [self.navigationItem bind:@"leftBarButtonItem" target:self action:@selector(leftItemChanged:)];
    [self.navigationItem bind:@"rightBarButtonItem" target:self action:@selector(rightItemChanged:)];
    [self.navigationItem bind:@"backBarButtonItem" target:self action:@selector(backItemChanged:)];
    [self.navigationItem bind:@"titleView" target:self action:@selector(titleViewChanged:)];
    [NSObject endBindingsContext];
    
    [super viewWillAppear:animated];
    
    [self.inlineDebuggerController start];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if(_viewWillDisappearBlock){
        _viewWillDisappearBlock(self,animated);
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(_viewDidAppearBlock){
        _viewDidAppearBlock(self,animated);
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if(_viewDidDisappearBlock){
        _viewDidDisappearBlock(self,animated);
    }
    [NSObject removeAllBindingsForContext:self.navigationItemsBindingContext];
    [self.inlineDebuggerController stop];
}

#pragma mark - View lifecycle

-(void) viewDidLoad{
	[super viewDidLoad];
    if(_viewDidLoadBlock){
        _viewDidLoadBlock(self);
    }
    
    
    //disable animations in case frames are set in stylesheets and currently in animation (ex : controller created when showing a container controller) ...
    [CATransaction begin];
    [CATransaction 
     setValue: [NSNumber numberWithBool: YES]
     forKey: kCATransactionDisableActions];
    
	[self applyStyle];
    
    [CATransaction commit];
}

-(void) viewDidUnload{
	[super viewDidUnload];
    if(_viewDidUnloadBlock){
        _viewDidUnloadBlock(self);
    }
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


@end
