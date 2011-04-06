//
//  CKBindings.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-03-11.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//


typedef enum {
	CKBindingsContextPolicyAdd,
	CKBindingsContextPolicyRemovePreviousBindings
} CKBindingsContextPolicy;

@interface NSObject (CKBindings)

+ (NSString *)allBindingsDescription;

// Binding Context Management

+ (void)beginBindingsContext:(id)context;
+ (void)beginBindingsContext:(id)context policy:(CKBindingsContextPolicy)policy;
+ (void)endBindingsContext;
+ (void)removeAllBindingsForContext:(id)context;

- (void)removeAllBindings;
- (void)bind:(NSString *)keyPath toObject:(id)object withKeyPath:(NSString *)keyPath;
- (void)bind:(NSString *)keyPath withBlock:(void (^)(id value))block;
- (void)bind:(NSString *)keyPath target:(id)target action:(SEL)selector;

@end

//

@interface UIControl (CKBindings)

- (void)bindEvent:(UIControlEvents)controlEvents withBlock:(void (^)())block;
- (void)bindEvent:(UIControlEvents)controlEvents target:(id)target action:(SEL)selector;

@end

//

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