//
//  CKReusableViewController+Standard.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-25.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKReusableViewController+Standard.h"

@implementation CKReusableViewController (Standard)

+ (instancetype)controllerWithTitle:(NSString*)title action:(void(^)(CKStandardContentViewController* controller))action{
    return [CKStandardContentViewController controllerWithTitle:title action:action];
}

+ (instancetype)controllerWithTitle:(NSString*)title subtitle:(NSString*)subtitle action:(void(^)(CKStandardContentViewController* controller))action{
    return [CKStandardContentViewController controllerWithTitle:title subtitle:subtitle action:action];
}

+ (instancetype)controllerWithTitle:(NSString*)title imageURL:(NSURL*)imageURL action:(void(^)(CKStandardContentViewController* controller))action{
    return [CKStandardContentViewController controllerWithTitle:title imageURL:imageURL action:action];
}

+ (instancetype)controllerWithTitle:(NSString*)title subtitle:(NSString*)subtitle imageURL:(NSURL*)imageURL action:(void(^)(CKStandardContentViewController* controller))action{
    return [CKStandardContentViewController controllerWithTitle:title subtitle:subtitle imageURL:imageURL action:action];
}

+ (instancetype)controllerWithTitle:(NSString*)title defaultImageName:(NSString*)defaultImageName imageURL:(NSURL*)imageURL action:(void(^)(CKStandardContentViewController* controller))action{
    return [CKStandardContentViewController controllerWithTitle:title defaultImageName:defaultImageName imageURL:imageURL action:action];
}

+ (instancetype)controllerWithTitle:(NSString*)title subtitle:(NSString*)subtitle defaultImageName:(NSString*)defaultImageName imageURL:(NSURL*)imageURL action:(void(^)(CKStandardContentViewController* controller))action{
    return [CKStandardContentViewController controllerWithTitle:title subtitle:subtitle defaultImageName:defaultImageName imageURL:imageURL action:action];
}

+ (instancetype)controllerWithTitle:(NSString*)title imageName:(NSString*)imageName action:(void(^)(CKStandardContentViewController* controller))action{
    return [CKStandardContentViewController controllerWithTitle:title imageName:imageName action:action];
}

+ (instancetype)controllerWithTitle:(NSString*)title subtitle:(NSString*)subtitle imageName:(NSString*)imageName action:(void(^)(CKStandardContentViewController* controller))action{
    return [CKStandardContentViewController controllerWithTitle:title subtitle:subtitle imageName:imageName action:action];
}

@end
