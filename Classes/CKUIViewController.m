//
//  CKUIViewController.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-21.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKUIViewController.h"
#import "CKUIViewController+Style.h"
#import "CKDebug.h"
#include <execinfo.h>

typedef enum CKDebugCheckForBlockCopyState{
    CKDebugCheckForBlockCopyState_none,
    CKDebugCheckForBlockCopyState_NO,
    CKDebugCheckForBlockCopyState_YES
}CKDebugCheckForBlockCopyState;

static CKDebugCheckForBlockCopyState CKDebugCheckForBlockCopyCurrentState = CKDebugCheckForBlockCopyState_none;

@implementation CKUIViewController
@synthesize name = _name;
@synthesize viewWillAppearBlock = _viewWillAppearBlock;
@synthesize viewDidAppearBlock = _viewDidAppearBlock;
@synthesize viewWillDisappearBlock = _viewWillDisappearBlock;
@synthesize viewDidDisappearBlock = _viewDidDisappearBlock;
@synthesize viewDidLoadBlock = _viewDidLoadBlock;
@synthesize viewDidUnloadBlock = _viewDidUnloadBlock;

- (void)postInit {	
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
	[_name release];
    [_viewWillAppearBlock release];
    [_viewDidAppearBlock release];
    [_viewWillDisappearBlock release];
    [_viewDidDisappearBlock release];
    [_viewDidLoadBlock release];
    [_viewDidUnloadBlock release];
	[super dealloc];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(_viewWillAppearBlock){
        _viewWillAppearBlock(self,animated);
    }
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
	return YES;
}

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

@end
