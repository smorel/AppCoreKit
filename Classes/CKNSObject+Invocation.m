//
//  CKNSObject+Invocation.m
//  CKWebRequest2
//
//  Created by Fred Brunel on 11-01-06.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKNSObject+Invocation.h"

@implementation NSObject (CKNSObjectInvocation)

// FIXME: Hides the framework method.
- (void)performSelectorOnMainThread:(SEL)selector withObject:(id)arg  waitUntilDone:(BOOL)wait {
	[self performSelector:selector onThread:[NSThread mainThread] withObjects:[NSArray arrayWithObjects:arg, nil] waitUntilDone:wait];
}

- (void)performSelectorOnMainThread:(SEL)selector withObject:(id)arg withObject:(id)arg2 waitUntilDone:(BOOL)wait {
	[self performSelector:selector onThread:[NSThread mainThread] withObjects:[NSArray arrayWithObjects:arg, arg2, nil] waitUntilDone:wait];
}

- (void)performSelectorOnMainThread:(SEL)selector withObject:(id)arg withObject:(id)arg2 withObject:(id)arg3 waitUntilDone:(BOOL)wait {
	[self performSelector:selector onThread:[NSThread mainThread] withObjects:[NSArray arrayWithObjects:arg, arg2, arg3, nil] waitUntilDone:wait];
}

- (void)performSelector:(SEL)selector onThread:(NSThread *)thread withObjects:(NSArray *)args waitUntilDone:(BOOL)wait {
    if ([self respondsToSelector:selector]) {
        NSMethodSignature *signature = [self methodSignatureForSelector:selector];
        if (signature) {
			NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
			
			[invocation setTarget:self];
			[invocation setSelector:selector];
				
			if (args) {
				NSInteger i = 2;
				for (NSObject *object in args) {
					[invocation setArgument:&object atIndex:i++];
				}
			}
				
			[invocation retainArguments];

			[invocation performSelector:@selector(invoke)
							   onThread:thread
							 withObject:nil
						  waitUntilDone:wait];
		}
	}
}

@end
