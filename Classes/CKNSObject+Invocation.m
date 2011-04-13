//
//  CKNSObject+Invocation.m
//  CKWebRequest2
//
//  Created by Fred Brunel on 11-01-06.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKNSObject+Invocation.h"

@implementation NSObject (CKNSObjectInvocation)

- (void)delayedPerformSelector:(NSArray*)args{
	NSValue* selectorValue = [args objectAtIndex:0];
	SEL selector = [selectorValue pointerValue];
	[self performSelector:selector onThread:[NSThread currentThread] withObjects:[args subarrayWithRange:NSMakeRange(1, [args count] - 1 )] waitUntilDone:YES];
}

- (void)performSelector:(SEL)selector withObject:(id)arg withObject:(id)arg2 afterDelay:(NSTimeInterval)delay {
	[self performSelector:@selector(delayedPerformSelector:) withObject:[NSArray arrayWithObjects:[NSValue valueWithPointer:selector],arg, arg2, nil] afterDelay:delay];
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
