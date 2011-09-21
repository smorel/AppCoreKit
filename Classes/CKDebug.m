//
//  Debug.h
//
//  Created by Olivier Collet on 11-07-14.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKDebug.h"
#include <execinfo.h>

#pragma mark - UIView

NSString* cleanString(NSString* str){
    NSString* str1 = [str stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    return [str1 stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
}

@implementation UIView (CKDebug)

- (void)printViewHierarchyWithIndentString:(NSString *)indentString {
	if (indentString == nil) indentString = @"";
	NSString *viewDescription = NSStringFromClass([self class]);
	printf("%s+- %s (tag:%d)\n", [indentString UTF8String], [viewDescription UTF8String], self.tag);

	if (self.subviews) {
		NSArray *siblings = self.superview.subviews;
		if (([siblings count] > 1) && ([siblings indexOfObject:self] < ([siblings count] - 1))) {
			indentString = [indentString stringByAppendingString:@"| "];
		}
		else {
			indentString = [indentString stringByAppendingString:@"  "];
		}
	}

	for (UIView *subview in self.subviews) {
		[subview printViewHierarchyWithIndentString:indentString];
	}
}

- (void)printViewHierarchy {
	[self printViewHierarchyWithIndentString:nil];
}

@end

#pragma mark - CallStack

NSString* CKDebugGetCallStack() {
	NSString* string = @"";
	void *frames[128];
	int len = backtrace(frames, 128);
	char **symbols = backtrace_symbols(frames, len);
	for (int i = 0; i < len; ++i) {
		string = [string stringByAppendingFormat:@"%s\n", symbols[i]];
	}
	free(symbols);
	return string;
}

void CKDebugPrintCallStack() {
	printf("%s",[CKDebugGetCallStack() UTF8String]);
}
