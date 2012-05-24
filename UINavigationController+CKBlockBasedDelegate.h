//
//  UINavigationController+CKBlockBasedDelegate.h
//  VoyageARabais
//
//  Created by Martin Dufort on 12-05-15.
//  Copyright (c) 2012 WhereCloud Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^UINavigationControllerBlock)(UINavigationController* navigationController,UIViewController* controller, BOOL animated);

@interface UINavigationController (CKBlockBasedDelegate)<UINavigationControllerDelegate>
@property(nonatomic,copy) UINavigationControllerBlock didPushViewControllerBlock;
@property(nonatomic,copy) UINavigationControllerBlock didPopViewControllerBlock;
@property(nonatomic,copy) UINavigationControllerBlock willPushViewControllerBlock;
@property(nonatomic,copy) UINavigationControllerBlock willPopViewControllerBlock;
@end
