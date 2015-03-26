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
/// @name Accessing the Container Controller
///-----------------------------------

/**
*/
@property(nonatomic,retain) NSString* name;


/**
 */
@property (nonatomic,assign) UIViewController *containerViewController;

/** returns the container controller of the specified class in the container hierarchy.
 returns nil if no container controller matching the specified type;
 */
- (UIViewController*)containerViewControllerOfClass:(Class)type;

/** returns the container controller conforms to the specified protocol in the container hierarchy.
 returns nil if no container controller conforming to the specified protocol;
 */
- (UIViewController*)containerViewControllerConformsToProtocol:(Protocol*)protocol;

@end
