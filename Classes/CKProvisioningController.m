//
//  CKProvisioningController.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-07-06.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKProvisioningController.h"
#import "CKLocalization.h"
#import "CKAlertView.h"
#import "CKFormTableViewController.h"
#import "CKNSNumberPropertyCellController.h"
#import "CKObjectPropertyArrayCollection.h"
#import "CKNSValueTransformer+Additions.h"
#import "CKNSDictionary+TableViewAttributes.h"
#import "CKProvisioningWebService.h"
#import "CKStyleManager.h"
#import "CKBundle.h"
#import "CKVersion.h"
#import "CKDebug.h"
#import "CKObjectProperty.h"

#import <QuartzCore/QuartzCore.h>

NSString *CKVersionStringForProductRelease(CKProductRelease *productRelease) {
	return [NSString stringWithFormat:_(@"Version %@ (%@)"), productRelease.versionNumber, productRelease.buildNumber];
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

// CKProvisioningReleaseNotesViewController

@interface CKProvisioningReleaseNotesViewController : UIViewController {
	NSString* _name;
}

@property (nonatomic,retain) CKProductRelease *productRelease;
@property (nonatomic,retain) NSString *name;

+ (CKProvisioningReleaseNotesViewController *)controllerWithProductRelease:(CKProductRelease *)productRelease;

@end

// CKRigoloDefaultBehaviour

@interface CKProvisioningController()

- (void)checkForNewProductRelease;
- (void)listAllProductReleases;
- (void)detailsForProductRelease:(NSString*)version;
- (void)presentController:(CKObjectTableViewController *)controller;
- (void)displayProductRelease:(CKProductRelease*)productRelease parentController:(UIViewController*)parentController;
- (void)displayProductReleases:(NSArray*)productReleases;

- (CKFormTableViewController *)controllerForSettings;
- (CKObjectTableViewController *)controllerForProductReleases;
- (CKFormTableViewController *)controllerForProductRelease:(CKProductRelease *)productRelease;
- (UIView *)recommendedView;

@property(nonatomic,retain) NSMutableArray* items;

@end

@implementation CKProvisioningController
@synthesize items = _items;
@synthesize parentViewController = _parentViewController;
@synthesize popoverController = _popoverController;

- (id)initWithParentViewController:(UIViewController*)controller{
    self = [super init];
	if (self) {
		self.items = [NSMutableArray array];
		self.parentViewController = controller;
		[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
		[[CKStyleManager defaultManager] loadContentOfFileNamed:@"CKProvisioningController"];
	}
    return self;
}

- (void)dealloc{
    [_items release]; _items = nil;
    [_parentViewController release]; _parentViewController = nil;
	[_popoverController release]; _popoverController = nil;
    [super dealloc];
}

- (void)onBecomeActive:(NSNotification*)notif{
    [self checkForNewProductRelease];
}

#pragma mark - Updates

- (void)fetchAndDisplayAllProductReleaseAsModal{
    [self listAllProductReleases];
}

- (void)checkForNewProductRelease{
    NSString* buildNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString* bundleIdentifier = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    
    [[CKProvisioningWebService sharedWebService]checkForNewProductReleaseWithBundleIdentifier:bundleIdentifier 
                                                                               version:buildNumber
     
                                                                               completion:^(BOOL upToDate,NSString* version){
                                                                                if(!upToDate){
                                                                                    NSString* title = _(@"New Version Available");
                                                                                    NSString* message = [NSString stringWithFormat:_(@"Build (%@)"),version];
                                                                                    CKAlertView* alertView = [[[CKAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:_(@"Cancel") otherButtonTitles:(@"Details"),nil]autorelease];
                                                                                    alertView.object = [NSDictionary dictionaryWithObjectsAndKeys:version,@"version", nil];
                                                                                    [alertView show];
                                                                                }
                                                                               }
     
                                                                               failure:^(NSError* error){
                                                                               }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    CKAlertView* ckAlertView = (CKAlertView*)alertView;
    switch(buttonIndex){
        case 1:{
            NSString* version = [ckAlertView.object objectForKey:@"version"];
            [self detailsForProductRelease:version];
            break;
        }
    }
}

- (void)install:(id)sender{
	if ([sender respondsToSelector:@selector(userInfo)]) {
		CKProductRelease* productRelease = (CKProductRelease*)[sender userInfo];
		[[UIApplication sharedApplication]openURL:productRelease.provisioningURL];
	}
}

#pragma mark - Presentation

- (void)presentController:(CKObjectTableViewController *)controller {
	UIViewController* rootController = self.parentViewController;
	NSAssert(rootController != nil,@"You must initialize the controller with a parentViewController");
	if(rootController.modalViewController == nil){
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
			[self.popoverController presentPopoverFromRect:CGRectMake(0, -10, rootController.view.bounds.size.width, 10) inView:rootController.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		}
		else {
			controller.leftButton = [[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
																					  target:self 
																					  action:@selector(dismissModal:)] autorelease];
			[rootController presentModalViewController:navController animated:YES];
		}
	}
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
    [rootController dismissModalViewControllerAnimated:YES];
}

- (void)dismissPopover:(id)sender {
	[self.popoverController dismissPopoverAnimated:YES];
}

#pragma mark - Settings ViewController

- (CKFormTableViewController *)controllerForSettings {
	__block CKProvisioningController* bself = self;
	CKProductRelease *productRelease = [[[CKProductRelease alloc] init] autorelease];
	productRelease.buildNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
	productRelease.versionNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	
    CKFormTableViewController* formController = [[[CKFormTableViewController alloc]init]autorelease];
	formController.contentSizeForViewInPopover = CGSizeMake(320, 416);
	formController.name = @"rigoloSettingsViewController";
    formController.title = @"Rigolo Settings";
	
	// Header
	CKFormCellDescriptor* headerCellDescriptor = [CKFormCellDescriptor cellDescriptorWithValue:productRelease controllerClass:[CKTableViewCellController class]];
    [headerCellDescriptor setCreateBlock:^id(id value) {
        CKTableViewCellController* controller = (CKTableViewCellController*)value;
        controller.name = @"rigoloSettingsHeaderCell";
        controller.cellStyle = CKTableViewCellStyleDefault;
        return (id)nil;
    }];
    [headerCellDescriptor setInitBlock:^id(id value) {
        CKTableViewCellController* controller = (CKTableViewCellController*)value;
        controller.tableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
		UIImageView *iconImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 57, 57)] autorelease];
		iconImageView.tag = 10000;
		iconImageView.clipsToBounds = YES;
		iconImageView.layer.cornerRadius = 10;
		[controller.tableViewCell.contentView addSubview:iconImageView];
        UILabel* appNamelabel = [[[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(iconImageView.frame)+10, 10, controller.tableViewCell.contentView.bounds.size.width - CGRectGetMaxX(iconImageView.frame) - 20, CGRectGetMaxY(iconImageView.bounds))]autorelease];
        appNamelabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        appNamelabel.tag = 10001;
        [controller.tableViewCell.contentView addSubview:appNamelabel];
        UILabel* currentVersionLabel = [[[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(controller.tableViewCell.contentView.bounds)-40, controller.tableViewCell.contentView.bounds.size.width - 20, 30)]autorelease];
        currentVersionLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        currentVersionLabel.tag = 10004;
		currentVersionLabel.textAlignment = UITextAlignmentCenter;
        [controller.tableViewCell.contentView addSubview:currentVersionLabel];
        return (id)nil; 
    }];
    [headerCellDescriptor setSetupBlock:^id(id value) {
        CKTableViewCellController* controller = (CKTableViewCellController*)value;
        CKProductRelease* productRelease = (CKProductRelease*)controller.value;
		UIImageView *iconImageView = (UIImageView *)[controller.tableViewCell.contentView viewWithTag:10000];
		iconImageView.image = [UIImage imageNamed:@"Icon.png"];
        UILabel* appNamelabel = (UILabel*)[controller.tableViewCell.contentView viewWithTag:10001];
        appNamelabel.text = productRelease.applicationName;
        UILabel* currentVersionLabel = (UILabel*)[controller.tableViewCell.contentView viewWithTag:10004];
        currentVersionLabel.text = [NSString stringWithFormat:@"You are currently running version %@", CKApplicationVersion()];
        return (id)nil; 
    }];
    [headerCellDescriptor setSizeBlock:^id(id value) {
        NSDictionary* params = (NSDictionary*)value;
        CGSize tableViewSize = [params bounds];
        return [NSValue valueWithCGSize:CGSizeMake(tableViewSize.width, 115)]; 
    }];
	[headerCellDescriptor setFlags:CKItemViewFlagNone];
	
	// Update
	CKFormCellDescriptor* updateCellDescriptor = [CKFormCellDescriptor cellDescriptorWithValue:productRelease controllerClass:[CKTableViewCellController class]];
    [updateCellDescriptor setCreateBlock:^id(id value) {
        CKTableViewCellController* controller = (CKTableViewCellController*)value;
        controller.name = @"rigoloSettingsUpdateCell";
        controller.cellStyle = CKTableViewCellStyleDefault;
        return (id)nil;
    }];
    [updateCellDescriptor setInitBlock:^id(id value) {
        CKTableViewCellController* controller = (CKTableViewCellController*)value;
        controller.tableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
		CKProvisioningControllerButton* installButton = [[[CKProvisioningControllerButton alloc] initWithFrame:CGRectMake(10, 20, controller.tableViewCell.contentView.bounds.size.width-20, 90)] autorelease];
		installButton.tag = 10000;
		installButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
		[installButton setTitle:@"Check for Updates" forState:UIControlStateNormal];
		[installButton setBackgroundImage:[[CKBundle imageForName:@"rigolo-btn-blue.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:20] forState:UIControlStateNormal];
		[installButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
		[installButton addTarget:bself action:@selector(install:) forControlEvents:UIControlEventTouchUpInside];
		[controller.tableViewCell.contentView addSubview:installButton];
        return (id)nil; 
    }];
    [updateCellDescriptor setSizeBlock:^id(id value) {
        NSDictionary* params = (NSDictionary*)value;
        CGSize tableViewSize = [params bounds];
        return [NSValue valueWithCGSize:CGSizeMake(tableViewSize.width, 120)];
    }];
	[updateCellDescriptor setFlags:CKItemViewFlagNone];
	
	// Check Automatically
//	CKFormCellDescriptor* checkAutoCellDescriptor = [CKFormCellDescriptor cellDescriptorWithValue:[CKObjectProperty propertyWithObject:[NSUserDefaults standardUserDefaults] keyPath:@"CheckRigolo"]  controllerClass:[CKNSNumberPropertyCellController class]];
//    [checkAutoCellDescriptor setCreateBlock:^id(id value) {
//        CKTableViewCellController* controller = (CKTableViewCellController*)value;
//        controller.name = @"rigoloSettingsCheckAutoCell";
//        controller.cellStyle = CKTableViewCellStyleDefault;
//        return (id)nil;
//    }];
//    [checkAutoCellDescriptor setInitBlock:^id(id value) {
//        CKTableViewCellController* controller = (CKTableViewCellController*)value;
//        controller.tableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
//		controller.tableViewCell.textLabel.text = _(@"Check Automatically");
//        return (id)nil; 
//    }];
//    [checkAutoCellDescriptor setSizeBlock:^id(id value) {
//        NSDictionary* params = (NSDictionary*)value;
//        CGSize tableViewSize = [params bounds];
//        return [NSValue valueWithCGSize:CGSizeMake(tableViewSize.width, 55)];
//    }];
//	[checkAutoCellDescriptor setFlags:CKItemViewFlagNone];
	
	// Release Notes
    CKFormCellDescriptor* releaseNotesCellDescriptor = [CKFormCellDescriptor cellDescriptorWithValue:productRelease controllerClass:[CKTableViewCellController class]];
    [releaseNotesCellDescriptor setCreateBlock:^id(id value) {
        CKTableViewCellController* controller = (CKTableViewCellController*)value;
        controller.name = @"rigoloReleaseNotesCell";
        controller.cellStyle = CKTableViewCellStyleDefault;
        return (id)nil;
    }];
	[releaseNotesCellDescriptor setInitBlock:^id(id value) {
        CKTableViewCellController* controller = (CKTableViewCellController*)value;
		controller.tableViewCell.accessoryView = [[[UIImageView alloc] initWithImage:[CKBundle imageForName:@"rigolo-cell-disclosure.png"]] autorelease];
        return (id)nil;
	}];
    [releaseNotesCellDescriptor setSetupBlock:^id(id value) {
        CKTableViewCellController* controller = (CKTableViewCellController*)value;
		controller.tableViewCell.textLabel.text = @"Release Notes";
		controller.tableViewCell.imageView.image = [CKBundle imageForName:@"rigolo-release-notes-icon.png"];
        return (id)nil; 
    }];
    [releaseNotesCellDescriptor setSizeBlock:^id(id value) {
        NSDictionary* params = (NSDictionary*)value;
        CGSize tableViewSize = [params bounds];
        return [NSValue valueWithCGSize:CGSizeMake(tableViewSize.width, 65)];
    }];
	[releaseNotesCellDescriptor setSelectionBlock:^id(id value) {
        CKTableViewCellController* controller = (CKTableViewCellController*)value;
        CKProductRelease* productRelease = (CKProductRelease*)controller.value;
		[formController.navigationController pushViewController:[CKProvisioningReleaseNotesViewController controllerWithProductRelease:productRelease] animated:YES];
        return (id)nil; 
	}];
	[releaseNotesCellDescriptor setFlags:CKItemViewFlagSelectable];
	
	// Release History
    CKFormCellDescriptor* releaseHistoryCellDescriptor = [CKFormCellDescriptor cellDescriptorWithValue:productRelease controllerClass:[CKTableViewCellController class]];
    [releaseHistoryCellDescriptor setCreateBlock:^id(id value) {
        CKTableViewCellController* controller = (CKTableViewCellController*)value;
        controller.name = @"rigoloReleaseHistoryCell";
        controller.cellStyle = CKTableViewCellStyleDefault;
        return (id)nil; 
    }];
	[releaseHistoryCellDescriptor setInitBlock:^id(id value) {
        CKTableViewCellController* controller = (CKTableViewCellController*)value;
		controller.tableViewCell.accessoryView = [[[UIImageView alloc] initWithImage:[CKBundle imageForName:@"rigolo-cell-disclosure.png"]] autorelease];
        return (id)nil;
	}];
    [releaseHistoryCellDescriptor setSetupBlock:^id(id value) {
        CKTableViewCellController* controller = (CKTableViewCellController*)value;
		controller.tableViewCell.textLabel.text = @"Release History";
		controller.tableViewCell.imageView.image = [CKBundle imageForName:@"rigolo-release-history-icon.png"];
        return (id)nil; 
    }];
    [releaseHistoryCellDescriptor setSizeBlock:^id(id value) {
        NSDictionary* params = (NSDictionary*)value;
        CGSize tableViewSize = [params bounds];
        return [NSValue valueWithCGSize:CGSizeMake(tableViewSize.width, 65)];
    }];
	[releaseHistoryCellDescriptor setSelectionBlock:^id(id value) {
		CKObjectTableViewController *controller = [bself controllerForProductReleases];
		[formController.navigationController pushViewController:controller animated:YES];
		NSString* bundleIdentifier = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
		[[CKProvisioningWebService sharedWebService]listAllProductReleasesWithBundleIdentifier:bundleIdentifier 
		 
																					completion:^(NSArray* productReleases){
																						[bself.items removeAllObjects];
																						[bself.items addObjectsFromArray:productReleases];
																						[controller reload];
																					}
		 
																					   failure:^(NSError* error){
																					   }];
		return (id)nil;
	}];
	[releaseHistoryCellDescriptor setFlags:CKItemViewFlagSelectable];
	
    [formController addSectionWithCellDescriptors:[NSArray arrayWithObjects:headerCellDescriptor,updateCellDescriptor,releaseNotesCellDescriptor,releaseHistoryCellDescriptor,nil]];
	return formController;
}

#pragma mark - Release Details ViewController

- (CKFormTableViewController *)controllerForProductRelease:(CKProductRelease *)productRelease {
	__block CKProvisioningController* bself = self;

    CKFormTableViewController* formController = [[[CKFormTableViewController alloc]init]autorelease];
	formController.contentSizeForViewInPopover = CGSizeMake(320, 416);
    formController.title = CKVersionStringForProductRelease(productRelease);
	formController.name = @"rigoloReleaseDetailViewController";

	// Header
	CKFormCellDescriptor* headerCellDescriptor = [CKFormCellDescriptor cellDescriptorWithValue:productRelease controllerClass:[CKTableViewCellController class]];
    [headerCellDescriptor setCreateBlock:^id(id value) {
        CKTableViewCellController* controller = (CKTableViewCellController*)value;
        controller.name = @"rigoloReleaseDetailsHeaderCell";
        controller.cellStyle = CKTableViewCellStyleDefault;
        return (id)nil;
    }];
    [headerCellDescriptor setInitBlock:^id(id value) {
        CKTableViewCellController* controller = (CKTableViewCellController*)value;
        controller.tableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
		UIImageView *iconImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 57, 57)] autorelease];
		iconImageView.tag = 10000;
		iconImageView.clipsToBounds = YES;
		iconImageView.layer.cornerRadius = 10;
		[controller.tableViewCell.contentView addSubview:iconImageView];
		UIView *recommendedView = [self recommendedView];
		recommendedView.tag = 10005;
		CGRect frame = recommendedView.frame;
		frame.origin.x = controller.tableViewCell.contentView.bounds.size.width - recommendedView.bounds.size.width - 5;
		frame.origin.y = 5;
		recommendedView.frame = frame;
		[controller.tableViewCell.contentView addSubview:recommendedView];
        UILabel* appNamelabel = [[[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(iconImageView.frame)+10, 10, controller.tableViewCell.contentView.bounds.size.width - CGRectGetMaxX(iconImageView.frame) - 20, CGRectGetMaxY(iconImageView.bounds))]autorelease];
        appNamelabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        appNamelabel.tag = 10001;
        [controller.tableViewCell.contentView addSubview:appNamelabel];
        UILabel* versionlabel = [[[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(iconImageView.frame)+10, (controller.tableViewCell.contentView.bounds.size.width - 30) /2, 30)]autorelease];
        versionlabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
        versionlabel.tag = 10002;
        [controller.tableViewCell.contentView addSubview:versionlabel];
        UILabel* datelabel = [[[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(versionlabel.frame)+10, CGRectGetMaxY(iconImageView.frame)+10, (controller.tableViewCell.contentView.bounds.size.width - 30) /2, 30)]autorelease];
        datelabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
        datelabel.tag = 10003;
		datelabel.textAlignment = UITextAlignmentRight;
        [controller.tableViewCell.contentView addSubview:datelabel];
        UILabel* currentVersionLabel = [[[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(versionlabel.frame)+20, controller.tableViewCell.contentView.bounds.size.width - 20, 30)]autorelease];
        currentVersionLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        currentVersionLabel.tag = 10004;
		currentVersionLabel.textAlignment = UITextAlignmentCenter;
        [controller.tableViewCell.contentView addSubview:currentVersionLabel];
        return (id)nil; 
    }];
    [headerCellDescriptor setSetupBlock:^id(id value) {
        CKTableViewCellController* controller = (CKTableViewCellController*)value;
        CKProductRelease* productRelease = (CKProductRelease*)controller.value;
		UIView *recommendedView = [controller.tableViewCell.contentView viewWithTag:10005];
		recommendedView.hidden = !productRelease.recommended;
		UIImageView *iconImageView = (UIImageView *)[controller.tableViewCell.contentView viewWithTag:10000];
		iconImageView.image = [UIImage imageNamed:@"Icon.png"];
        UILabel* appNamelabel = (UILabel*)[controller.tableViewCell.contentView viewWithTag:10001];
        appNamelabel.text = productRelease.applicationName;
        UILabel* versionlabel = (UILabel*)[controller.tableViewCell.contentView viewWithTag:10002];
        versionlabel.text = CKVersionStringForProductRelease(productRelease);
        UILabel* datelabel = (UILabel*)[controller.tableViewCell.contentView viewWithTag:10003];
        datelabel.text = [NSValueTransformer transformProperty:[CKObjectProperty propertyWithObject:productRelease keyPath:@"releaseDate"] toClass:[NSString class]];
        UILabel* currentVersionLabel = (UILabel*)[controller.tableViewCell.contentView viewWithTag:10004];
        currentVersionLabel.text = [NSString stringWithFormat:@"You are currently running version %@", CKApplicationVersion()];
        return (id)nil; 
    }];
    [headerCellDescriptor setSizeBlock:^id(id value) {
        NSDictionary* params = (NSDictionary*)value;
        CGSize tableViewSize = [params bounds];
        return [NSValue valueWithCGSize:CGSizeMake(tableViewSize.width, 160)]; 
    }];
	[headerCellDescriptor setFlags:CKItemViewFlagNone];
	
	// Install
	CKFormCellDescriptor* installCellDescriptor = [CKFormCellDescriptor cellDescriptorWithValue:productRelease controllerClass:[CKTableViewCellController class]];
    [installCellDescriptor setCreateBlock:^id(id value) {
        CKTableViewCellController* controller = (CKTableViewCellController*)value;
        controller.name = @"rigoloReleaseDetailsInstallCell";
        controller.cellStyle = CKTableViewCellStyleDefault;
        return (id)nil;
    }];
    [installCellDescriptor setInitBlock:^id(id value) {
        CKTableViewCellController* controller = (CKTableViewCellController*)value;
        controller.tableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
		CKProvisioningControllerButton* installButton = [[[CKProvisioningControllerButton alloc] initWithFrame:CGRectInset(controller.tableViewCell.contentView.bounds, 10, 20)] autorelease];
		installButton.tag = 10000;
		installButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[installButton setTitle:@"INSTALL" forState:UIControlStateNormal];
		[installButton setTitle:@"INSTALLED" forState:UIControlStateDisabled];
		[installButton setBackgroundImage:[[CKBundle imageForName:@"rigolo-btn-green.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:20] forState:UIControlStateNormal];
		[installButton setBackgroundImage:[[CKBundle imageForName:@"rigolo-btn-disabled.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:20] forState:UIControlStateDisabled];
		[installButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
		[installButton addTarget:bself action:@selector(install:) forControlEvents:UIControlEventTouchUpInside];
		[controller.tableViewCell.contentView addSubview:installButton];
        return (id)nil; 
    }];
    [installCellDescriptor setSetupBlock:^id(id value) {
        CKTableViewCellController* controller = (CKTableViewCellController*)value;
        CKProductRelease* productRelease = (CKProductRelease*)controller.value;
		CKProvisioningControllerButton *installButton = (CKProvisioningControllerButton *)[controller.tableViewCell.contentView viewWithTag:10000];
		installButton.enabled = ([productRelease.buildNumber isEqualToString:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]] == NO);
		installButton.userInfo = productRelease;
        return (id)nil; 
    }];
    [installCellDescriptor setSizeBlock:^id(id value) {
        NSDictionary* params = (NSDictionary*)value;
        CGSize tableViewSize = [params bounds];
        return [NSValue valueWithCGSize:CGSizeMake(tableViewSize.width, 130)];
    }];
	[installCellDescriptor setFlags:CKItemViewFlagNone];
	
	// Release Notes
    CKFormCellDescriptor* releaseNotesCellDescriptor = [CKFormCellDescriptor cellDescriptorWithValue:productRelease controllerClass:[CKTableViewCellController class]];
    [releaseNotesCellDescriptor setCreateBlock:^id(id value) {
        CKTableViewCellController* controller = (CKTableViewCellController*)value;
        controller.name = @"rigoloReleaseNotesCell";
        controller.cellStyle = CKTableViewCellStyleDefault;
        return (id)nil;
    }];
	[releaseNotesCellDescriptor setInitBlock:^id(id value) {
        CKTableViewCellController* controller = (CKTableViewCellController*)value;
		controller.tableViewCell.accessoryView = [[[UIImageView alloc] initWithImage:[CKBundle imageForName:@"rigolo-cell-disclosure.png"]] autorelease];
        return (id)nil;
	}];
    [releaseNotesCellDescriptor setSetupBlock:^id(id value) {
        CKTableViewCellController* controller = (CKTableViewCellController*)value;
		controller.tableViewCell.textLabel.text = @"Release Notes";
		controller.tableViewCell.imageView.image = [CKBundle imageForName:@"rigolo-release-notes-icon.png"];
        return (id)nil; 
    }];
    [releaseNotesCellDescriptor setSizeBlock:^id(id value) {
        NSDictionary* params = (NSDictionary*)value;
        CGSize tableViewSize = [params bounds];
        return [NSValue valueWithCGSize:CGSizeMake(tableViewSize.width, 65)];
    }];
	[releaseNotesCellDescriptor setSelectionBlock:^id(id value) {
        CKTableViewCellController* controller = (CKTableViewCellController*)value;
        CKProductRelease* productRelease = (CKProductRelease*)controller.value;
		[formController.navigationController pushViewController:[CKProvisioningReleaseNotesViewController controllerWithProductRelease:productRelease] animated:YES];
        return (id)nil; 
	}];
	[releaseNotesCellDescriptor setFlags:CKItemViewFlagSelectable];
	
	// Release History
    CKFormCellDescriptor* releaseHistoryCellDescriptor = [CKFormCellDescriptor cellDescriptorWithValue:productRelease controllerClass:[CKTableViewCellController class]];
    [releaseHistoryCellDescriptor setCreateBlock:^id(id value) {
        CKTableViewCellController* controller = (CKTableViewCellController*)value;
        controller.name = @"rigoloReleaseHistoryCell";
        controller.cellStyle = CKTableViewCellStyleDefault;
        return (id)nil;
    }];
	[releaseHistoryCellDescriptor setInitBlock:^id(id value) {
        CKTableViewCellController* controller = (CKTableViewCellController*)value;
		controller.tableViewCell.accessoryView = [[[UIImageView alloc] initWithImage:[CKBundle imageForName:@"rigolo-cell-disclosure.png"]] autorelease];
        return (id)nil;
	}];
    [releaseHistoryCellDescriptor setSetupBlock:^id(id value) {
        CKTableViewCellController* controller = (CKTableViewCellController*)value;
		controller.tableViewCell.textLabel.text = @"Release History";
		controller.tableViewCell.imageView.image = [CKBundle imageForName:@"rigolo-release-history-icon.png"];
        return (id)nil; 
    }];
    [releaseHistoryCellDescriptor setSizeBlock:^id(id value) {
        NSDictionary* params = (NSDictionary*)value;
        CGSize tableViewSize = [params bounds];
        return [NSValue valueWithCGSize:CGSizeMake(tableViewSize.width, 65)];
    }];
	[releaseHistoryCellDescriptor setSelectionBlock:^id(id value) {
		CKObjectTableViewController *controller = [bself controllerForProductReleases];
		[formController.navigationController pushViewController:controller animated:YES];
		NSString* bundleIdentifier = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
		[[CKProvisioningWebService sharedWebService]listAllProductReleasesWithBundleIdentifier:bundleIdentifier 
		 
																					completion:^(NSArray* productReleases){
																						[bself.items removeAllObjects];
																						[bself.items addObjectsFromArray:productReleases];
																						[controller reload];
																					}
		 
																					   failure:^(NSError* error){
																					   }];
		return (id)nil;
	}];
	[releaseHistoryCellDescriptor setFlags:CKItemViewFlagSelectable];
	
    [formController addSectionWithCellDescriptors:[NSArray arrayWithObjects:headerCellDescriptor,installCellDescriptor,releaseNotesCellDescriptor,releaseHistoryCellDescriptor,nil]];
	return formController;
}

#pragma mark - Release History ViewController

- (CKObjectTableViewController *)controllerForProductReleases {
	__block CKProvisioningController *bself = self;
	NSMutableArray* mappings = [NSMutableArray array];
	CKObjectViewControllerFactoryItem* releaseCellDescriptor = [mappings mapControllerClass:[CKTableViewCellController class] withObjectClass:[CKProductRelease class]];
	[releaseCellDescriptor setCreateBlock:^id(id value) {
		CKTableViewCellController* controller = (CKTableViewCellController*)value;
		controller.name = @"rigoloReleaseListCell";
		controller.cellStyle = CKTableViewCellStyleSubtitle;
		return (id)nil;
	}];
	[releaseCellDescriptor setInitBlock:^id(id value) {
        CKTableViewCellController* controller = (CKTableViewCellController*)value;
        UILabel* versionlabel = [[[UILabel alloc]initWithFrame:CGRectMake(15, 15, 200, 30)]autorelease];
        versionlabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        versionlabel.tag = 10000;
        [controller.tableViewCell.contentView addSubview:versionlabel];
        UILabel* datelabel = [[[UILabel alloc]initWithFrame:CGRectMake(15, CGRectGetMaxY(versionlabel.frame)+5, 280, 30)] autorelease];
        datelabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        datelabel.tag = 10001;
        [controller.tableViewCell.contentView addSubview:datelabel];
		UIView *recommendedView = [self recommendedView];
		recommendedView.tag = 10005;
		CGRect frame = recommendedView.frame;
		frame.origin.x = CGRectGetMaxX(controller.tableViewCell.bounds) - CGRectGetMaxX(recommendedView.bounds) - 5;
		frame.origin.y = (CGRectGetMaxY(controller.tableViewCell.bounds) - CGRectGetMaxY(recommendedView.bounds)) / 2;
		recommendedView.frame = CGRectIntegral(frame);
		recommendedView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
		[controller.tableViewCell.contentView addSubview:recommendedView];
        return (id)nil;
	}];
	[releaseCellDescriptor setSetupBlock:^id(id value) {
		CKTableViewCellController* controller = (CKTableViewCellController*)value;
		CKProductRelease* productRelease = (CKProductRelease*)controller.value;
		UILabel* versionlabel = (UILabel*)[controller.tableViewCell.contentView viewWithTag:10000];
        versionlabel.text = CKVersionStringForProductRelease(productRelease);
        UILabel* datelabel = (UILabel*)[controller.tableViewCell.contentView viewWithTag:10001];
        datelabel.text = [NSValueTransformer transformProperty:[CKObjectProperty propertyWithObject:productRelease keyPath:@"releaseDate"] toClass:[NSString class]];
		UIView *recommendedView = [controller.tableViewCell viewWithTag:10005];
		recommendedView.hidden = !productRelease.recommended;
		controller.tableViewCell.accessoryView = productRelease.recommended ? nil : [[[UIImageView alloc] initWithImage:[CKBundle imageForName:@"rigolo-cell-disclosure.png"]] autorelease];
		return (id)nil; 
	}];
    [releaseCellDescriptor setSizeBlock:^id(id value) {
        NSDictionary* params = (NSDictionary*)value;
        CGSize tableViewSize = [params bounds];
        return [NSValue valueWithCGSize:CGSizeMake(tableViewSize.width, 90)];
    }];
	[releaseCellDescriptor setSelectionBlock:^id(id value) {
		CKTableViewCellController* controller = (CKTableViewCellController*)value;
		CKProductRelease* productRelease = (CKProductRelease*)controller.value;
		[bself displayProductRelease:productRelease parentController:controller.parentController];
		return (id)nil;
	}];
	[releaseCellDescriptor setFlags:CKItemViewFlagSelectable];
	
    NSString* bundleIdentifier = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
	CKDocumentArray *collection = [[[CKDocumentArray alloc] initWithFeedSource:[[CKProvisioningWebService sharedWebService] sourceForReleasesWithBundleIdentifier:bundleIdentifier]] autorelease];
	CKObjectTableViewController* tableViewController = [[[CKObjectTableViewController alloc]initWithCollection:collection mappings:mappings]autorelease];
	tableViewController.name = @"rigoloReleasesViewController";
	tableViewController.contentSizeForViewInPopover = CGSizeMake(320, 416);
	tableViewController.title = _(@"Versions");
	return tableViewController;
}

- (UIView *)recommendedView {
	UIView *view = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
	
	UILabel* recommendedLabel = [[[UILabel alloc]initWithFrame:CGRectZero]autorelease];
	recommendedLabel.textAlignment = UITextAlignmentRight;
	recommendedLabel.text = _(@"Recommended");
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

#pragma mark -
#pragma mark - Release Notes ViewController

@implementation CKProvisioningReleaseNotesViewController

@synthesize productRelease = _productRelease;
@synthesize name = _name;

+ (CKProvisioningReleaseNotesViewController *)controllerWithProductRelease:(CKProductRelease *)productRelease {
	CKProvisioningReleaseNotesViewController *controller = [[[CKProvisioningReleaseNotesViewController alloc] init] autorelease];
	controller.productRelease = productRelease;
	controller.contentSizeForViewInPopover = CGSizeMake(320, 416);
	return controller;
}

- (void)dealloc {
	self.productRelease = nil;
	[_name release];
	_name = nil;
	
	[super dealloc];
}

- (void)viewDidLoad {
	[super viewDidLoad];

	UITextView *notesView = [[[UITextView alloc] initWithFrame:CGRectMake(0, 50, self.view.bounds.size.width, self.view.bounds.size.height - 50)] autorelease];
	notesView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	notesView.tag = 10003;
	notesView.editable = NO;
	notesView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"rigolo-notes-bg.png"]];
	notesView.font = [UIFont fontWithName:@"Noteworthy-Bold" size:17];
	notesView.text = [NSString stringWithFormat:@"%@ %@", self.productRelease.releaseNotes, self.productRelease.releaseNotes];
	[self.view addSubview:notesView];
	
	CKGradientView *headerView = [[[CKGradientView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50)] autorelease];
	headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	headerView.tag = 10000;
	[self.view addSubview:headerView];

	UILabel *versionLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, 0, headerView.bounds.size.width-20, headerView.bounds.size.height)] autorelease];
	versionLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	versionLabel.tag = 10001;
	versionLabel.textAlignment = UITextAlignmentCenter;
	versionLabel.text = CKVersionStringForProductRelease(self.productRelease);
	[self.view addSubview:versionLabel];

	UIImageView *pageTears = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rigolo-notes-pagetears.png"]] autorelease];
	pageTears.frame = CGRectMake(0, 50, self.view.bounds.size.width, pageTears.bounds.size.height);
	pageTears.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[self.view addSubview:pageTears];

	[self applyStyle];
}

@end
