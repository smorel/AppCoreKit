//
//  CKProvisioningReleaseViewController.h
//  CloudKit
//
//  Created by Olivier Collet on 11-08-09.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKFormTableViewController.h"
#import "CKProvisioningController.h"

@interface CKProvisioningReleaseViewController : CKFormTableViewController

+ (id)controllerWithProvisioningController:(CKProvisioningController *)provisioningController forProductRelease:(CKProductRelease *)productRelease;

@end
