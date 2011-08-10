//
//  CKProvisioningController.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-07-06.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CKProvisioningWebService.h"
#import "CKUserDefaults.h"
#import "CKFormTableViewController.h"

NSString *CKVersionStringForProductRelease(CKProductRelease *productRelease);

@interface CKProvisioningUserDefaults : CKUserDefaults{}
@property (nonatomic,assign)BOOL autoCheck;
@end

/** 
 TODO
 */
@interface CKProvisioningController : NSObject <UIPopoverControllerDelegate, UIAlertViewDelegate> {
    NSMutableArray* _items;
    UIViewController* _parentViewController;
	UIPopoverController *_popoverController;
}
@property(nonatomic,retain) UIViewController* parentViewController;
@property(nonatomic,retain) UIPopoverController *popoverController;

- (id)initWithParentViewController:(UIViewController*)controller;

- (CKFormTableViewController *)controllerForSettings;
- (CKObjectTableViewController *)controllerForProductReleases;
- (CKFormTableViewController *)controllerForProductRelease:(CKProductRelease *)productRelease;

- (void)presentSettingsControllerInViewController:(UIViewController*)controller fromBarButtonItem:(UIBarButtonItem*)barButtonItem;
- (void)displayProductRelease:(CKProductRelease*)productRelease parentController:(UIViewController*)parentController;

+ (UIView *)recommendedView;

@end
