//
//  Debug.h
//
//  Created by Sebastien Morel.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

// CKDebugLog Macro

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifdef __cplusplus
extern "C" {
#endif
    
/**
 */
extern NSString* cleanString(NSString* str);
    
#ifdef __cplusplus
}
#endif

#ifdef DEBUG
    #define CKDebugLog(s, ...) NSLog(@"<%p %@:(%d)> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, cleanString([NSString stringWithFormat:(s), ##__VA_ARGS__]))
    #define CKAssert(condition, desc, ...) NSAssert(condition,desc,##__VA_ARGS__)
#else
    #define CKDebugLog(s, ...)
    #define CKAssert(condition, desc, ...)
#endif



// UIView
/**
 */
@interface UIView (CKDebug)

///-----------------------------------
/// @name Debugging view hierarchy
///-----------------------------------

/**
 */
- (void)printViewHierarchy;

/**
 */
- (NSString*)viewHierarchy;

@end

// CallStack
/**
 */
NSString* CKDebugGetCallStack();

/**
 */
void CKDebugPrintCallStack();
