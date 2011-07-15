//
//  CKProvisioningController.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-07-06.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

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
- (void)fetchAndDisplayAllProductReleaseAsModal;

@end
