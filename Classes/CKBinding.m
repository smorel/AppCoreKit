//
//  CKBinding.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-18.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKBinding.h"

@interface CKBinding ()
@property(nonatomic,retain)  CKWeakRef* contextRef;
@end

@implementation CKBinding
@synthesize contextRef = _contextRef;
@synthesize context;
@synthesize contextOptions = _contextOptions;

- (void)bind{
    NSAssert(NO,@"Should be implemented in inherited class");
}

- (void)unbind{
    NSAssert(NO,@"Should be implemented in inherited class");
}

- (void)reset{
    [_contextRef release];
    _contextRef = nil;
    _contextOptions = 0;
}

- (id)context{
    return [_contextRef object];
}

- (void)setContext:(id)thecontext{
    __block CKBinding* bself = self;
    self.contextRef = [CKWeakRef weakRefWithObject:thecontext block:^(CKWeakRef *weakRef) {
        [bself unbind];
    }];
}

@end
