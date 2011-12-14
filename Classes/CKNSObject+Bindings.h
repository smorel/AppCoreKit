//
//  CKBindings.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-03-11.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


/** TODO
 */
typedef enum CKBindingsContextPolicy{
	CKBindingsContextPolicyAdd,
	CKBindingsContextPolicyRemovePreviousBindings
} CKBindingsContextPolicy;

typedef enum CKBindingsContextOptions{
	CKBindingsContextPerformOnMainThread           = 1 << 0,
	CKBindingsContextPerformOnCurrentThread        = 1 << 2,
    CKBindingsContextWaitUntilDone                 = 1 << 4
} CKBindingsContextOptions;


/** TODO
 */
@interface NSObject (CKBindings)

+ (NSString *)allBindingsDescription;

+ (void)validateCurrentBindingsContext;

// Binding Context Management

+ (void)beginBindingsContext:(id)context;
+ (void)beginBindingsContext:(id)context policy:(CKBindingsContextPolicy)policy;

+ (void)beginBindingsContext:(id)context options:(CKBindingsContextOptions)options;
+ (void)beginBindingsContext:(id)context policy:(CKBindingsContextPolicy)policy options:(CKBindingsContextOptions)options;

+ (void)endBindingsContext;
+ (void)removeAllBindingsForContext:(id)context;

- (void)bind:(NSString *)keyPath toObject:(id)object withKeyPath:(NSString *)keyPath;
- (void)bind:(NSString *)keyPath withBlock:(void (^)(id value))block;
- (void)bind:(NSString *)keyPath target:(id)target action:(SEL)selector;

- (void)beginBindingsContextByKeepingPreviousBindings;
- (void)beginBindingsContextByRemovingPreviousBindings;
- (void)beginBindingsContextByKeepingPreviousBindingsWithOptions:(CKBindingsContextOptions)options;
- (void)beginBindingsContextByRemovingPreviousBindingsWithOptions:(CKBindingsContextOptions)options;

- (void)endBindingsContext;
- (void)clearBindingsContext;

@end

//



/** TODO
 */
@interface UIControl (CKBindings)

- (void)bindEvent:(UIControlEvents)controlEvents withBlock:(void (^)())block;
- (void)bindEvent:(UIControlEvents)controlEvents target:(id)target action:(SEL)selector;

@end

//


/** TODO
 */
@interface NSNotificationCenter (CKBindings)

- (void)bindNotificationName:(NSString *)notification object:(id)notificationSender withBlock:(void (^)(NSNotification *notification))block;
- (void)bindNotificationName:(NSString *)notification withBlock:(void (^)(NSNotification *notification))block;

- (void)bindNotificationName:(NSString *)notification object:(id)notificationSender target:(id)target action:(SEL)selector;
- (void)bindNotificationName:(NSString *)notification target:(id)target action:(SEL)selector;


+ (void)bindNotificationName:(NSString *)notification object:(id)notificationSender withBlock:(void (^)(NSNotification *notification))block;
+ (void)bindNotificationName:(NSString *)notification withBlock:(void (^)(NSNotification *notification))block;

+ (void)bindNotificationName:(NSString *)notification object:(id)notificationSender target:(id)target action:(SEL)selector;
+ (void)bindNotificationName:(NSString *)notification target:(id)target action:(SEL)selector;

@end