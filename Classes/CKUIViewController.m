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

typedef enum CKDebugCheckState{
    CKDebugCheckState_none,
    CKDebugCheckState_NO,
    CKDebugCheckState_YES
}CKDebugCheckState;

static CKDebugCheckState CKDebugCheckForBlockCopyCurrentState = CKDebugCheckState_none;

@interface CKUIViewController()
@property(nonatomic,retain) NSString* navigationItemsBindingContext;
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
@synthesize viewDidLoadBlock = _viewDidLoadBlock;
@synthesize viewDidUnloadBlock = _viewDidUnloadBlock;
@synthesize rightButton = _rightButton;
@synthesize leftButton = _leftButton;
@synthesize navigationItemsBindingContext = _navigationItemsBindingContext;
@synthesize supportedInterfaceOrientations;
@synthesize inlineDebuggerController = _inlineDebuggerController;
@synthesize deallocBlock = _deallocBlock;
@synthesize styleHasBeenApplied;
@synthesize state;
@synthesize viewIsOnScreen;

- (void)supportedInterfaceOrientationsMetaData:(CKObjectPropertyMetaData*)metaData{
    metaData.enumDescriptor = CKEnumDefinition(@"CKInterfaceOrientation", 
                                               CKInterfaceOrientationPortrait,
                                               CKInterfaceOrientationLandscape,
                                               CKInterfaceOrientationAll);
}

- (void)stateMetaData:(CKObjectPropertyMetaData*)metaData{
    metaData.enumDescriptor = CKEnumDefinition(@"CKUIViewControllerState", 
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
    if(_deallocBlock){
        _deallocBlock(self);
    }
    
    [NSObject removeAllBindingsForContext:self.navigationItemsBindingContext];
    [self clearBindingsContext];
    
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
    
	[super dealloc];
}

+ (id)controller{
	return [[[[self class]alloc]init]autorelease];
}

#pragma mark - Style Management

- (void)applyStyleForLeftBarButtonItem{
    if(self.navigationItem.leftBarButtonItem){
        NSMutableDictionary* controllerStyle = [self controllerStyle];
        NSMutableDictionary* navControllerStyle = [controllerStyle styleForObject:self.navigationController  propertyName:@"navigationController"];
        NSMutableDictionary* navBarStyle = [navControllerStyle styleForObject:self.navigationController  propertyName:@"navigationBar"];
        
        NSMutableDictionary* barItemStyle = [navBarStyle styleForObject:self.navigationItem.leftBarButtonItem propertyName:@"leftBarButtonItem"];
        [self.navigationItem.leftBarButtonItem applyStyle:barItemStyle];
        
        //HACK for versions before 4.2 due to the fact that setting a custom view on a UIBarButtonItem after it has been set in the navigationItem do not work.
        if([CKOSVersion() floatValue]< 4.2){
            UIBarButtonItem* bu = self.navigationItem.leftBarButtonItem;
            self.navigationItem.leftBarButtonItem = nil;
            [self.navigationItem setLeftBarButtonItem:bu animated:YES];
        }
    }
}

- (void)applyStyleForRightBarButtonItem{
    if(self.navigationItem.rightBarButtonItem){
        NSMutableDictionary* controllerStyle = [self controllerStyle];
        NSMutableDictionary* navControllerStyle = [controllerStyle styleForObject:self.navigationController  propertyName:@"navigationController"];
        NSMutableDictionary* navBarStyle = [navControllerStyle styleForObject:self.navigationController  propertyName:@"navigationBar"];
        
        NSMutableDictionary* barItemStyle = [navBarStyle styleForObject:self.navigationItem.rightBarButtonItem propertyName:@"rightBarButtonItem"];
        [self.navigationItem.rightBarButtonItem applyStyle:barItemStyle];
        
        //HACK for versions before 4.2 due to the fact that setting a custom view on a UIBarButtonItem after it has been set in the navigationItem do not work.
        if([CKOSVersion() floatValue]< 4.2){
            UIBarButtonItem* bu = self.navigationItem.rightBarButtonItem;
            self.navigationItem.rightBarButtonItem = nil;
            [self.navigationItem setRightBarButtonItem:bu animated:YES];
        }
    }
}

- (void)applyStyleForBackBarButtonItem{
    if(self.navigationItem.backBarButtonItem){
        NSMutableDictionary* controllerStyle = [self controllerStyle];
        NSMutableDictionary* navControllerStyle = [controllerStyle styleForObject:self.navigationController  propertyName:@"navigationController"];
        NSMutableDictionary* navBarStyle = [navControllerStyle styleForObject:self.navigationController  propertyName:@"navigationBar"];
        
        NSMutableDictionary* barItemStyle = [navBarStyle styleForObject:self.navigationItem.backBarButtonItem propertyName:@"backBarButtonItem"];
        [self.navigationItem.backBarButtonItem applyStyle:barItemStyle];
        
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

- (void)applyStyleForTitleView{
    if(self.navigationItem.titleView){
        NSMutableDictionary* controllerStyle = [self controllerStyle];
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
            self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc]initWithTitle:previousController.title style:UIBarButtonItemStyleBordered target:self action:@selector(popViewController)]autorelease];
            [self.navigationItem.backBarButtonItem applyStyle:backBarItemStyle];

            self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
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
    
    [NSObject beginBindingsContext:self.navigationItemsBindingContext policy:CKBindingsContextPolicyRemovePreviousBindings];
    [self.navigationItem bind:@"leftBarButtonItem" target:self action:@selector(leftItemChanged:)];
    [self.navigationItem bind:@"rightBarButtonItem" target:self action:@selector(rightItemChanged:)];
    [self.navigationItem bind:@"backBarButtonItem" target:self action:@selector(backItemChanged:)];
    [self.navigationItem bind:@"titleView" target:self action:@selector(titleViewChanged:)];
    [NSObject endBindingsContext];
    
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


@end

