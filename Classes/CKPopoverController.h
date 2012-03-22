//
//  CKPopoverController.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-10.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class CKPopoverController;
typedef void(^CKPopoverControllerDismissBlock)(CKPopoverController* popover);

/** 
 CKPopoverController is an autonomous version of UIPopoverController that will retain itself when presented and autorelease itself when dismissed. This avoid client code to retain the popover while it is displayed. It is also registered on interface orientation change and can optionally dismiss itsel automatically.
 CKPopoverController also provides some helpers to add the contentViewController in navigation controller at init.
 */
@interface CKPopoverController : UIPopoverController<UIPopoverControllerDelegate> {}

//default value is YES
@property (nonatomic,assign)BOOL autoDismissOnInterfaceOrientation;

@property (nonatomic,copy) CKPopoverControllerDismissBlock didDismissPopoverBlock;

- (id)initWithContentViewController:(UIViewController *)viewController;
- (id)initWithContentViewController:(UIViewController *)viewController contentSize:(CGSize)contentSize;
- (id)initWithContentViewController:(UIViewController *)viewController inNavigationController:(BOOL)navigationController;
- (id)initWithContentViewController:(UIViewController *)viewController contentSize:(CGSize)contentSize inNavigationController:(BOOL)navigationController;

//private
- (void)postInit;

@end
