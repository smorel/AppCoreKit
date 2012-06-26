//
//  Debug.h
//
//  Created by Sebastien Morel on 04/08/09.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

// CKDebugLog Macro

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 */
extern NSString* cleanString(NSString* str);

#ifdef DEBUG
  /**
   */
  #define CKDebugLog(s, ...) NSLog(@"<%p %@:(%d)> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, cleanString([NSString stringWithFormat:(s), ##__VA_ARGS__]))
#else
  #define CKDebugLog(s, ...)
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
