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

+ (void)appendViewHierarchyForView:(UIView*)view indentString:(NSString *)indentString inString:(NSMutableString*)str{
	if (indentString == nil) indentString = @"";
	NSString *viewDescription = NSStringFromClass([view class]);
    
    if(view.backgroundColor){
        NSString* systemColor = [view valueForKey:@"backgroundColorSystemColorName"];
        if(!systemColor){
            const CGFloat *comps = CGColorGetComponents([view.backgroundColor CGColor]);
            const CGFloat alpha = CGColorGetAlpha([view.backgroundColor CGColor]);
            [str appendFormat:@"%@+- %@(tag:%d,bck:%g %g %g %g)\n",  
                indentString, viewDescription, view.tag, comps[0],comps[1],comps[2],alpha];
        }
        else{
            [str appendFormat:@"%@+- %@(tag:%d,bck:%@)\n",  
                indentString, viewDescription, view.tag, systemColor];
        }
    }
    else{
        [str appendFormat:@"%@+- %@(tag:%d)\n",  
                indentString, viewDescription, view.tag];
    }

	if (view.subviews) {
		NSArray *siblings = view.superview.subviews;
		if (([siblings count] > 1) && ([siblings indexOfObject:self] < ([siblings count] - 1))) {
			indentString = [indentString stringByAppendingString:@"| "];
		}
		else {
			indentString = [indentString stringByAppendingString:@"  "];
		}
	}

	for (UIView *subview in view.subviews) {
		[UIView appendViewHierarchyForView:subview indentString:indentString inString:str];
	}
}

- (void)printViewHierarchy {
    printf("%s",[[self viewHierarchy]UTF8String]);
}

- (NSString*)viewHierarchy{
    NSMutableString* str = [NSMutableString string];
    [UIView appendViewHierarchyForView:self indentString:nil inString:str];
    return str;
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
