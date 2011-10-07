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

typedef enum CKDebugCheckForBlockCopyState{
    CKDebugCheckForBlockCopyState_none,
    CKDebugCheckForBlockCopyState_NO,
    CKDebugCheckForBlockCopyState_YES
}CKDebugCheckForBlockCopyState;

static CKDebugCheckForBlockCopyState CKDebugCheckForBlockCopyCurrentState = CKDebugCheckForBlockCopyState_none;

@interface CKUIViewController()
@property(nonatomic,retain)NSString* navigationItemsBindingContext;
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

- (void)supportedInterfaceOrientationsMetaData:(CKObjectPropertyMetaData*)metaData{
    metaData.enumDescriptor = CKEnumDefinition(@"CKInterfaceOrientation", 
                                               CKInterfaceOrientationPortrait,
                                               CKInterfaceOrientationLandscape,
                                               CKInterfaceOrientationAll);
}

- (void)postInit {	
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
	[super dealloc];
}


- (void)applyStyleForLeftBarButtonItem{
    if(self.navigationItem.leftBarButtonItem){
        NSMutableDictionary* controllerStyle = [[CKStyleManager defaultManager] styleForObject:self  propertyName:nil];
        NSMutableDictionary* navControllerStyle = [controllerStyle styleForObject:self.navigationController  propertyName:@"navigationController"];
        NSMutableDictionary* navBarStyle = [navControllerStyle styleForObject:self.navigationController  propertyName:@"navigationBar"];
        
        NSMutableDictionary* barItemStyle = [navBarStyle styleForObject:self.navigationItem.leftBarButtonItem propertyName:@"leftBarButtonItem"];
        [self.navigationItem.leftBarButtonItem applySubViewsStyle:barItemStyle appliedStack:[NSMutableSet set] delegate:nil];
    }
}

- (void)applyStyleForRightBarButtonItem{
    if(self.navigationItem.rightBarButtonItem){
        NSMutableDictionary* controllerStyle = [[CKStyleManager defaultManager] styleForObject:self  propertyName:nil];
        NSMutableDictionary* navControllerStyle = [controllerStyle styleForObject:self.navigationController  propertyName:@"navigationController"];
        NSMutableDictionary* navBarStyle = [navControllerStyle styleForObject:self.navigationController  propertyName:@"navigationBar"];
        
        NSMutableDictionary* barItemStyle = [navBarStyle styleForObject:self.navigationItem.rightBarButtonItem propertyName:@"rightBarButtonItem"];
        [self.navigationItem.rightBarButtonItem applySubViewsStyle:barItemStyle appliedStack:[NSMutableSet set] delegate:nil];
    }
}

- (void)leftItemChanged:(UIBarButtonItem*)item{
    [self applyStyleForLeftBarButtonItem];
}

- (void)rightItemChanged:(UIBarButtonItem*)item{
    [self applyStyleForRightBarButtonItem];
}

- (void)applyStyleForNavigation{
	NSMutableDictionary* controllerStyle = [[CKStyleManager defaultManager] styleForObject:self  propertyName:nil];
    NSMutableDictionary* navControllerStyle = [controllerStyle styleForObject:self.navigationController  propertyName:@"navigationController"];
    NSMutableDictionary* navBarStyle = [self.navigationController.navigationBar applyStyle:navControllerStyle propertyName:@"navigationBar"];
    /*NSMutableDictionary* toolbarBarStyle = */[self.navigationController.toolbar applyStyle:navControllerStyle propertyName:@"toolbar"];
    
	//NSMutableDictionary* toolbarBarStyle = [navControllerStyle styleForObject:self.navigationController.toolbar  propertyName:@"toolbar"];
	//NSMutableDictionary* navBarStyle = [navControllerStyle styleForObject:self.navigationController.navigationBar  propertyName:@"navigationBar"];

    if(self.navigationItem.leftBarButtonItem){
        NSMutableDictionary* barItemStyle = [navBarStyle styleForObject:self.navigationItem.leftBarButtonItem propertyName:@"leftBarButtonItem"];
        [self.navigationItem.leftBarButtonItem applySubViewsStyle:barItemStyle appliedStack:[NSMutableSet set] delegate:nil];
    }
    if(self.navigationItem.rightBarButtonItem){
        NSMutableDictionary* barItemStyle = [navBarStyle styleForObject:self.navigationItem.rightBarButtonItem propertyName:@"rightBarButtonItem"];
        [self.navigationItem.rightBarButtonItem applySubViewsStyle:barItemStyle appliedStack:[NSMutableSet set] delegate:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
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
    [self bind:@"navigationItem.leftBarButtonItem" target:self action:@selector(leftItemChanged:)];
    [self bind:@"navigationItem.rightBarButtonItem" target:self action:@selector(rightItemChanged:)];
    [NSObject endBindingsContext];
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
}

#pragma mark - View lifecycle

-(void) viewDidLoad{
	[super viewDidLoad];
    if(_viewDidLoadBlock){
        _viewDidLoadBlock(self);
    }
	[self applyStyle];
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
    if(CKDebugCheckForBlockCopyCurrentState == CKDebugCheckForBlockCopyState_none){
        BOOL bo = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CKDebugCheckForBlockCopy"]boolValue];
        CKDebugCheckForBlockCopyCurrentState = bo ? CKDebugCheckForBlockCopyState_YES : CKDebugCheckForBlockCopyState_NO;
    }
    
    if(CKDebugCheckForBlockCopyCurrentState != CKDebugCheckForBlockCopyState_YES)
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
