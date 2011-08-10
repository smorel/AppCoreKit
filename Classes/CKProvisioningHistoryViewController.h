//
//  CKProvisioningHistoryViewController.h
//  CloudKit
//
//  Created by Olivier Collet on 11-08-09.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKObjectTableViewController.h"
#import "CKProvisioningController.h"

@interface CKProvisioningHistoryViewController : CKObjectTableViewController

+ (id)controllerWithProvisioningController:(CKProvisioningController *)provisioningController;

@end
