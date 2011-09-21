//
//  CKBinding.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-18.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKBinding.h"


@implementation CKBinding
@synthesize context = _context;

- (void)bind{
    NSAssert(NO,@"Should be implemented in inherited class");
}

- (void)unbind{
    NSAssert(NO,@"Should be implemented in inherited class");
}

- (void)reset{
    NSAssert(NO,@"Should be implemented in inherited class");
}


@end
