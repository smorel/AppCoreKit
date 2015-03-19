//
//  UIViewController+CKLayout.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-06-26.
//  Copyright (c) 2013 Wherecloud. All rights reserved.
//

#import "CKLayoutBoxProtocol.h"
#import "CKLayoutBox.h"

/**
 */
@interface UIViewController () <CKLayoutBoxProtocol>
@end


/**
 */
@interface UIViewController (CKContainerViewController)

///-----------------------------------
/// @name Accessing the Container Controller=
///-----------------------------------

/**
 */
@property (nonatomic,assign) UIViewController *containerViewController;

@end
