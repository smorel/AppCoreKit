//
//  CKBinding.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKBinding.h"
#import "CKBindingsManager.h"
#import "CKWeakRef.h"
#import "CKDebug.h"


@implementation CKBinding{
    CKBindingsContextOptions _contextOptions;
}

@synthesize context = _context;
@synthesize contextOptions = _contextOptions;

- (void)bind{
    CKAssert(NO,@"Should be implemented in inherited class");
}

- (void)unbind{
    CKAssert(NO,@"Should be implemented in inherited class");
}


- (void)reset{
    _context = nil;
    _contextOptions = 0;
}

@end
