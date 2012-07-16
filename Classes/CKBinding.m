//
//  CKBinding.m
//  CloudKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKBinding.h"
#import "CKBindingsManager.h"
#import "CKWeakRef.h"


@implementation CKBinding
@synthesize context = _context;
@synthesize contextOptions = _contextOptions;

- (void)bind{
    NSAssert(NO,@"Should be implemented in inherited class");
}

- (void)unbind{
    NSAssert(NO,@"Should be implemented in inherited class");
}


- (void)reset{
    _context = nil;
    _contextOptions = 0;
}

@end
