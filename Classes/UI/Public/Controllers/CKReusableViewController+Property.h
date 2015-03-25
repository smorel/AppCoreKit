//
//  CKReusableViewController+Property.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-25.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import <AppCoreKit/AppCoreKit.h>

@interface CKReusableViewController (Property)

/**
 */
+ (instancetype)controllerWithObject:(id)object keyPath:(NSString*)keyPath;

/**
 */
+ (instancetype)controllerWithObject:(id)object keyPath:(NSString*)keyPath readOnly:(BOOL)readOnly;

/**
 */
+ (instancetype)controllerWithProperty:(CKProperty*)property;

/**
 */
+ (instancetype)controllerWithProperty:(CKProperty*)property readOnly:(BOOL)readOnly;

@end
