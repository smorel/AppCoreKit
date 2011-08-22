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
	[super dealloc];
}

#pragma mark - View lifecycle

-(void) viewDidLoad{
	[super viewDidLoad];
	[self applyStyle];
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
