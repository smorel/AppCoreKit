//
//  CKProvisioningController.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-07-06.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKProvisioningController.h"
#import "CKProvisioningSettingsController.h"
#import "CKProvisioningHistoryViewController.h"
#import "CKProvisioningReleaseViewController.h"
#import "CKProvisioningReleaseNotesViewController.h"
#import "CKLocalization.h"
#import "CKAlertView.h"
#import "CKNSNumberPropertyCellController.h"
#import "CKObjectPropertyArrayCollection.h"
#import "CKNSValueTransformer+Additions.h"
#import "CKNSDictionary+TableViewAttributes.h"
#import "CKStyleManager.h"
#import "CKBundle.h"
#import "CKVersion.h"
#import "CKObjectProperty.h"
#import "CKNSObject+Bindings.h"
#import "CKDebug.h"
#import <QuartzCore/QuartzCore.h>

#define kCKProvisioningRecommendedViewTag 94554901


@implementation CKProvisioningUserDefaults
@synthesize autoCheck;

- (void)postInit{
    [super postInit];
    self.autoCheck = YES;
}

@end

NSString *CKVersionStringForProductRelease(CKProductRelease *productRelease) {
	return [NSString stringWithFormat:_(@"RIGOLO_Version %@ (%@)"), productRelease.versionNumber, productRelease.buildNumber];
}

// CKRigoloDefaultBehaviourBarButtonItem

@interface CKProvisioningControllerBarButtonItem : UIBarButtonItem{
    id _userInfo;
}
@property(nonatomic,retain)id userInfo;
@end

@implementation CKProvisioningControllerBarButtonItem
@synthesize userInfo = _userInfo;
@end

@interface CKProvisioningControllerButton : UIButton{
    id _userInfo;
}
@property(nonatomic,retain)id userInfo;
@end

@implementation CKProvisioningControllerButton
@synthesize userInfo = _userInfo;
@end

// CKRigoloDefaultBehaviour

@interface CKProvisioningController()

- (void)checkForNewProductRelease;
- (void)listAllProductReleases;
- (void)detailsForProductRelease:(NSString*)version;
- (void)presentController:(CKObjectTableViewController *)controller;
- (void)displayProductReleases:(NSArray*)productReleases;

+ (UIView *)recommendedView;

@property(nonatomic,retain) NSMutableArray* items;
@property(nonatomic,retain) UIViewController* modalParentViewController;
@end

@implementation CKProvisioningController
@synthesize items = _items;
@synthesize parentViewController = _parentViewController;
@synthesize popoverController = _popoverController;
@synthesize modalParentViewController;

- (id)initWithParentViewController:(UIViewController*)controller{
    self = [super init];
	if (self) {
		self.items = [NSMutableArray array];
		self.parentViewController = controller;
        
        //Init autocheck notifications
        if([[CKProvisioningUserDefaults sharedInstance]autoCheck]){
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        }
        
        [self beginBindingsContextByRemovingPreviousBindings];
        [[CKProvisioningUserDefaults sharedInstance] bind:@"autoCheck" withBlock:^(id value) {
            if([[CKProvisioningUserDefaults sharedInstance] autoCheck]){
                [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
            }
            else{
				[[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
            }
        }];
        [self endBindingsContext];
        
		[[CKStyleManager defaultManager] loadContentOfFileNamed:@"CKProvisioningController"];
	}
    return self;
}

- (void)dealloc{
    [_items release]; _items = nil;
    [_parentViewController release]; _parentViewController = nil;
	[_popoverController release]; _popoverController = nil;
	[self.modalParentViewController release]; self.modalParentViewController = nil;
    [super dealloc];
}

- (void)onBecomeActive:(NSNotification*)notif{
	[self checkForNewProductRelease];
}

#pragma mark - Updates

- (void)fetchAndDisplayAllProductReleaseAsModal{
    [self listAllProductReleases];
}

- (void)checkUpdate:(id)sender{
    [self checkForNewProductRelease];
}

- (void)checkForNewProductRelease{
    NSString* buildNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString* bundleIdentifier = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    
    [[CKProvisioningWebService sharedWebService]checkForNewProductReleaseWithBundleIdentifier:bundleIdentifier 
                                                                               version:buildNumber
     
                                                                               completion:^(BOOL upToDate,NSString* version){
                                                                                if(!upToDate){
                                                                                    NSString* title = _(@"RIGOLO_Wireless Update");
                                                                                    NSString* message = [NSString stringWithFormat:_(@"RIGOLO_A new release of the product is available\nVersion (%@)"),version];
                                                                                    
                                                                                    CKAlertView* alertView = [[[CKAlertView alloc]initWithTitle:title message:message]autorelease];
                                                                                    [alertView addButtonWithTitle:_(@"RIGOLO_Details") action:^(void){
                                                                                        [self detailsForProductRelease:version];
                                                                                    }];
                                                                                    [alertView addButtonWithTitle:_(@"RIGOLO_Settings") action:^(void){
                                                                                        [self presentController:[self controllerForSettings]];
                                                                                    }];
                                                                                    [alertView addButtonWithTitle:_(@"RIGOLO_Cancel") action:nil];
                                                                                    [alertView show];
                                                                                }
                                                                               }
     
                                                                               failure:^(NSError* error){
                                                                               }];
}

- (void)install:(id)sender{
	if ([sender respondsToSelector:@selector(userInfo)]) {
		CKProductRelease* productRelease = (CKProductRelease*)[sender userInfo];
		BOOL result = [[UIApplication sharedApplication]openURL:productRelease.provisioningURL];
        if(result == NO){
            NSString* title = _(@"RIGOLO_Installation failed");
            NSString* message = [NSString stringWithFormat:_(@"RIGOLO_Cannot install %@ %@(%@).\nUnable to open URL : %@"),productRelease.applicationName,productRelease.versionNumber,productRelease.buildNumber,productRelease.provisioningURL];
            CKAlertView* alertView = [[[CKAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:_(@"RIGOLO_OK") otherButtonTitles:nil]autorelease];
            [alertView show];
        }
	}
}

#pragma mark - Presentation

- (void)presentController:(CKObjectTableViewController *)controller inViewController:(UIViewController *)rootController fromBarButtonItem:(UIBarButtonItem *)barButtonItem {
//	NSAssert(rootController != nil,@"You must initialize the controller with a parentViewController");
	if(rootController.modalViewController == nil
       && ![self.popoverController isPopoverVisible] ){
		UINavigationController* navController = [[[UINavigationController alloc]initWithRootViewController:controller]autorelease];
		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
			controller.leftButton = [[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
																				  target:self 
																				  action:@selector(dismissPopover:)] autorelease];
			if (self.popoverController) {
				[self.popoverController dismissPopoverAnimated:YES];
			}
			self.popoverController = [[[UIPopoverController alloc] initWithContentViewController:navController] autorelease];
			self.popoverController.delegate = self;
			
			if (barButtonItem) {
				[self.popoverController presentPopoverFromBarButtonItem:barButtonItem
											   permittedArrowDirections:UIPopoverArrowDirectionAny
															   animated:YES];
			}
			else {
				[self.popoverController presentPopoverFromRect:CGRectMake(0, -10, rootController.view.bounds.size.width, 10)
														inView:rootController.view
									  permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
			}
		}
		else {
			controller.leftButton = [[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
																					  target:self 
																					  action:@selector(dismissModal:)] autorelease];
			[rootController presentModalViewController:navController animated:YES];
			self.modalParentViewController = rootController;
		}
	}
    else{
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            UINavigationController* navController = (UINavigationController*)self.popoverController.contentViewController;
            [navController pushViewController:controller animated:YES];
        }
        else{
            [rootController.modalViewController.navigationController pushViewController:controller animated:YES];
        }
    }
}

- (void)presentController:(CKObjectTableViewController *)controller inViewController:(UIViewController *)rootController {
	[self presentController:controller inViewController:rootController fromBarButtonItem:nil];
}

- (void)presentController:(CKObjectTableViewController *)controller {
	[self presentController:controller inViewController:self.parentViewController];
}

- (void)displayProductReleases:(NSArray*)productReleases {
    UIViewController* rootController =  self.parentViewController;
    NSAssert(rootController != nil,@"You must initialize the controller with a parentViewController");
    if(rootController.modalViewController == nil){
        [self.items addObjectsFromArray:productReleases];
        
        CKObjectTableViewController *tableViewController = [self controllerForProductReleases];
        
        UINavigationController* navController = [[[UINavigationController alloc]initWithRootViewController:tableViewController]autorelease];
        tableViewController.leftButton = [[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissModal:)] autorelease];
        [rootController presentModalViewController:navController animated:YES];
    }
}

- (void)displayProductRelease:(CKProductRelease*)productRelease parentController:(UIViewController*)parentController{
	CKObjectTableViewController *formController = [self controllerForProductRelease:productRelease];

    if(parentController == nil){
		[self presentController:formController];
    }
    else{
        [parentController.navigationController pushViewController:formController animated:YES];
    }
}

- (void)detailsForProductRelease:(NSString*)version{
    /* DEBUG
     [self presentController:[self controllerForSettings]];
    return;
     */
    
    NSString* bundleIdentifier = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    [[CKProvisioningWebService sharedWebService]detailsForProductReleaseWithBundleIdentifier:bundleIdentifier
                                                                                     version:version 
     
                                                                                     completion:^(CKProductRelease* productRelease){
                                                                                         [self displayProductRelease:productRelease parentController:nil];
                                                                                     }
     
                                                                                     failure:^(NSError* error){
                                                                                     }];
}

- (void)listAllProductReleases{
    NSString* bundleIdentifier = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    [[CKProvisioningWebService sharedWebService]listAllProductReleasesWithBundleIdentifier:bundleIdentifier 
     
                                                                            completion:^(NSArray* productReleases){
																				[self.items removeAllObjects];
                                                                                [self displayProductReleases:productReleases];
                                                                            }
     
                                                                            failure:^(NSError* error){
                                                                            }];
    
}

- (void)dismissModal:(id)sender{
    UIViewController* rootController =  self.parentViewController;
    NSAssert(rootController != nil,@"You must initialize the controller with a parentViewController");
	if (self.modalParentViewController) {
		[self.modalParentViewController dismissModalViewControllerAnimated:YES];
		self.modalParentViewController = nil;
	} else
		[rootController dismissModalViewControllerAnimated:YES];
}

- (void)dismissPopover:(id)sender {
	[self.popoverController dismissPopoverAnimated:YES];
}

#pragma mark - ViewControllers & View Factory

// Settings
- (CKFormTableViewController *)controllerForSettings {
	return [CKProvisioningSettingsController controllerWithProvisioningController:self];
}

- (void)presentSettingsControllerInViewController:(UIViewController*)controller fromBarButtonItem:(UIBarButtonItem*)barButtonItem {
	if (self.popoverController && self.popoverController.isPopoverVisible) {
		[self.popoverController dismissPopoverAnimated:YES];
	} else {
		[self presentController:[self controllerForSettings] inViewController:controller fromBarButtonItem:barButtonItem];	
	}
}

// Release History
- (CKObjectTableViewController *)controllerForProductReleases {
	return [CKProvisioningHistoryViewController controllerWithProvisioningController:self];
}

// Release Details
- (CKFormTableViewController *)controllerForProductRelease:(CKProductRelease *)productRelease {
	return [CKProvisioningReleaseViewController controllerWithProvisioningController:self forProductRelease:productRelease];
}

// Recommended View
+ (UIView *)recommendedView {
	UIView *view = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
	view.tag = kCKProvisioningRecommendedViewTag;
	
	UILabel* recommendedLabel = [[[UILabel alloc]initWithFrame:CGRectZero]autorelease];
	recommendedLabel.textAlignment = UITextAlignmentRight;
	recommendedLabel.text = _(@"RIGOLO_Recommended");
	[recommendedLabel sizeToFit];
	[view addSubview:recommendedLabel];

	UIImageView *recommendedBadge = [[[UIImageView alloc] initWithImage:[CKBundle imageForName:@"rigolo-recommended-badge.png"]] autorelease];
	recommendedBadge.frame = CGRectOffset(recommendedBadge.frame, CGRectGetMaxX(recommendedLabel.frame) + 5,0);
	[view addSubview:recommendedBadge];
	
	CGRect frame = recommendedLabel.frame;
	frame.size.height = recommendedBadge.bounds.size.height;
	recommendedLabel.frame = frame;

	view.frame = CGRectMake(0, 0, CGRectGetMaxX(recommendedBadge.frame), CGRectGetMaxY(recommendedBadge.bounds));

	return view;
}

#pragma mark - UIPopoverController Delegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	[_popoverController release]; _popoverController = nil;
}

@end
