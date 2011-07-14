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
#import "CKObjectPropertyArrayCollection.h"
#import "CKNSValueTransformer+Additions.h"
#import "CKNSDictionary+TableViewAttributes.h"
#import "CKProvisioningWebService.h"
#import "CKStyleManager.h"
#import "CKBundle.h"
#import "CKVersion.h"

#import <QuartzCore/QuartzCore.h>

//CKRigoloDefaultBehaviourBarButtonItem

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


//CKRigoloDefaultBehaviour

@interface CKProvisioningController()

- (void)checkForNewProductRelease;
- (void)listAllProductReleases;
- (void)detailsForProductRelease:(NSString*)version;
- (void)displayProductRelease:(CKProductRelease*)productRelease parentController:(UIViewController*)parentController;
- (void)displayProductReleases:(NSArray*)productReleases;

- (CKObjectTableViewController *)controllerForProductReleases;
- (CKFormTableViewController *)controllerForProductRelease:(CKProductRelease *)productRelease;

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
		[[CKStyleManager defaultManager] loadContentOfFileNamed:[CKBundle pathForStylesheet:@"CKProvisioningController"]];
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
        UIViewController* rootController = self.parentViewController;
        NSAssert(rootController != nil,@"You must initialize the controller with a parentViewController");
        if(rootController.modalViewController == nil){
            UINavigationController* navController = [[[UINavigationController alloc]initWithRootViewController:formController]autorelease];
			if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
				formController.leftButton = [[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
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
				formController.leftButton = [[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
																						  target:self 
																						  action:@selector(dismissModal:)] autorelease];
				[rootController presentModalViewController:navController animated:YES];
			}
        }
    }
    else{
        [parentController.navigationController pushViewController:formController animated:YES];
    }
	formController.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	formController.tableView.scrollEnabled = NO;
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

#pragma mark - ViewController Creation

- (CKFormTableViewController *)controllerForProductRelease:(CKProductRelease *)productRelease {
	__block CKProvisioningController* bself = self;

    CKFormTableViewController* formController = [[[CKFormTableViewController alloc]init]autorelease];
	formController.contentSizeForViewInPopover = CGSizeMake(320, 416);
	NSString *versionString = [NSString stringWithFormat:_(@"Version %@ (%@)"), productRelease.versionNumber, productRelease.buildNumber];
    formController.title = versionString;

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
		UIImageView *recommendedBadge = [[[UIImageView alloc] initWithImage:[CKBundle imageForName:@"rigolo-recommended-badge.png"]] autorelease];
		recommendedBadge.tag = 10006;
		recommendedBadge.frame = CGRectOffset(recommendedBadge.frame, controller.tableViewCell.contentView.bounds.size.width - 5 - CGRectGetMaxX(recommendedBadge.bounds), 5);
		[controller.tableViewCell.contentView addSubview:recommendedBadge];
        UILabel* recommendedLabel = [[[UILabel alloc]initWithFrame:CGRectZero]autorelease];
        recommendedLabel.tag = 10005;
		recommendedLabel.textAlignment = UITextAlignmentRight;
		recommendedLabel.text = @"Recommended";
		[recommendedLabel sizeToFit];
		recommendedLabel.frame = CGRectMake(CGRectGetMinX(recommendedBadge.frame) - 5 - CGRectGetMaxX(recommendedLabel.bounds), CGRectGetMinY(recommendedBadge.frame), recommendedLabel.bounds.size.width, recommendedBadge.bounds.size.height);
		recommendedLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		[controller.tableViewCell.contentView addSubview:recommendedLabel];
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
		UILabel *recommendedLabel = (UILabel *)[controller.tableViewCell.contentView viewWithTag:10005];
		UIImageView *recommendedBadge = (UIImageView *)[controller.tableViewCell.contentView viewWithTag:10006];
		recommendedLabel.hidden = recommendedBadge.hidden = !productRelease.recommended;
		UIImageView *iconImageView = (UIImageView *)[controller.tableViewCell.contentView viewWithTag:10000];
		iconImageView.image = [UIImage imageNamed:@"Icon.png"];
        UILabel* appNamelabel = (UILabel*)[controller.tableViewCell.contentView viewWithTag:10001];
        appNamelabel.text = productRelease.applicationName;
        UILabel* versionlabel = (UILabel*)[controller.tableViewCell.contentView viewWithTag:10002];
        versionlabel.text = versionString;
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
	
	// Release Notes
    CKFormCellDescriptor* releaseNotesCellDescriptor = [CKFormCellDescriptor cellDescriptorWithValue:productRelease controllerClass:[CKTableViewCellController class]];
    [releaseNotesCellDescriptor setCreateBlock:^id(id value) {
        CKTableViewCellController* controller = (CKTableViewCellController*)value;
        controller.name = @"rigoloReleaseDetailsReleaseNotesCell";
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
	
	// Release History
    CKFormCellDescriptor* releaseHistoryCellDescriptor = [CKFormCellDescriptor cellDescriptorWithValue:productRelease controllerClass:[CKTableViewCellController class]];
    [releaseHistoryCellDescriptor setCreateBlock:^id(id value) {
        CKTableViewCellController* controller = (CKTableViewCellController*)value;
        controller.name = @"rigoloReleaseDetailsReleaseHistoryCell";
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
	
    [formController addSectionWithCellDescriptors:[NSArray arrayWithObjects:headerCellDescriptor,installCellDescriptor,releaseNotesCellDescriptor,releaseHistoryCellDescriptor,nil]];
	return formController;
}

- (CKObjectTableViewController *)controllerForProductReleases {
	NSMutableArray* mappings = [NSMutableArray array];
	CKObjectViewControllerFactoryItem* releaseCellDescriptor = [mappings mapControllerClass:[CKTableViewCellController class] withObjectClass:[CKProductRelease class]];
	[releaseCellDescriptor setCreateBlock:^id(id value) {
		CKTableViewCellController* controller = (CKTableViewCellController*)value;
		controller.name = @"rigoloCell";
		controller.cellStyle = CKTableViewCellStyleSubtitle;
		return (id)nil; 
	}];
	[releaseCellDescriptor setInitBlock:^id(id value) {
		CKTableViewCellController* controller = (CKTableViewCellController*)value;
		controller.tableViewCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		controller.tableViewCell.selectionStyle = UITableViewCellSelectionStyleBlue;
		return (id)nil; 
	}];
	[releaseCellDescriptor setSetupBlock:^id(id value) {
		CKTableViewCellController* controller = (CKTableViewCellController*)value;
		CKProductRelease* productRelease = (CKProductRelease*)controller.value;
		controller.tableViewCell.textLabel.text = [NSString stringWithFormat:@"%@ (%@) %@",productRelease.applicationName,productRelease.buildNumber,(productRelease.recommended ? @"RECOMMANDED" : @"")];
		controller.tableViewCell.detailTextLabel.text = [NSValueTransformer transformProperty:[CKObjectProperty propertyWithObject:productRelease keyPath:@"releaseDate"] toClass:[NSString class]];
		
		return (id)nil; 
		
	}];
	[releaseCellDescriptor setSelectionBlock:^id(id value) {
		CKTableViewCellController* controller = (CKTableViewCellController*)value;
		CKProductRelease* productRelease = (CKProductRelease*)controller.value;
		[self displayProductRelease:productRelease parentController:controller.parentController];
		return (id)nil;
	}];
	[releaseCellDescriptor setFlags:CKItemViewFlagSelectable];
	
	CKObjectPropertyArrayCollection* collection = [CKObjectPropertyArrayCollection collectionWithArrayProperty:[CKObjectProperty propertyWithObject:self keyPath:@"items"]];
	CKObjectTableViewController* tableViewController = [[[CKObjectTableViewController alloc]initWithCollection:collection mappings:mappings]autorelease];
	tableViewController.contentSizeForViewInPopover = CGSizeMake(320, 416);
	tableViewController.title = _(@"Versions");
	return tableViewController;
}

#pragma mark - UIPopoverController Delegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	[_popoverController release]; _popoverController = nil;
}

@end
