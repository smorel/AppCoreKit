//
//  CKProvisioningReleaseNotesViewController.h
//  CloudKit
//
//  Created by Olivier Collet on 11-08-09.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKProvisioningController.h"

@interface CKProvisioningReleaseNotesViewController : UIViewController {
	NSString* _name;
}

@property (nonatomic,retain) CKProductRelease *productRelease;
@property (nonatomic,retain) NSString *name;

+ (CKProvisioningReleaseNotesViewController *)controllerWithProductRelease:(CKProductRelease *)productRelease;

@end
