//
//  CKReusableViewController+Standard.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-25.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKStandardContentViewController.h"

@interface CKReusableViewController (Standard)

/**
 */
+ (instancetype)controllerWithTitle:(NSString*)title action:(void(^)(CKStandardContentViewController* controller))action;

/**
 */
+ (instancetype)controllerWithTitle:(NSString*)title subtitle:(NSString*)subtitle action:(void(^)(CKStandardContentViewController* controller))action;

/**
 */
+ (instancetype)controllerWithTitle:(NSString*)title imageURL:(NSURL*)imageURL action:(void(^)(CKStandardContentViewController* controller))action;

/**
 */
+ (instancetype)controllerWithTitle:(NSString*)title subtitle:(NSString*)subtitle imageURL:(NSURL*)imageURL action:(void(^)(CKStandardContentViewController* controller))action;

/**
 */
+ (instancetype)controllerWithTitle:(NSString*)title defaultImageName:(NSString*)defaultImageName imageURL:(NSURL*)imageURL action:(void(^)(CKStandardContentViewController* controller))action;

/**
 */
+ (instancetype)controllerWithTitle:(NSString*)title subtitle:(NSString*)subtitle defaultImageName:(NSString*)defaultImageName imageURL:(NSURL*)imageURL action:(void(^)(CKStandardContentViewController* controller))action;

/**
 */
+ (instancetype)controllerWithTitle:(NSString*)title imageName:(NSString*)imageName action:(void(^)(CKStandardContentViewController* controller))action;

/**
 */
+ (instancetype)controllerWithTitle:(NSString*)title subtitle:(NSString*)subtitle imageName:(NSString*)imageName action:(void(^)(CKStandardContentViewController* controller))action;

@end
