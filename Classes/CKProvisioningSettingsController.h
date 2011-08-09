//
//  CKProvisioningSettingsController.h
//  CloudKit
//
//  Created by Olivier Collet on 11-08-09.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKFormTableViewController.h"
#import "CKProvisioningController.h"

@interface CKProvisioningSettingsController : CKFormTableViewController

- (id)initWithProvisioningController:(CKProvisioningController *)provisioningController;
+ (id)controllerWithProvisioningController:(CKProvisioningController *)provisioningController;

@end
