//
//  CKProvisioningSettingsController.m
//  CloudKit
//
//  Created by Olivier Collet on 11-08-09.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKProvisioningSettingsController.h"
#import "CKProvisioningReleaseNotesViewController.h"
#import "CKObjectProperty.h"
#import "CKNSNumberPropertyCellController.h"
#import "CKVersion.h"
#import "CKBundle.h"
#import "CKLocalization.h"

#import <QuartzCore/QuartzCore.h>

#define kCKProvisioningSettingsIconViewTag 454001
#define kCKProvisioningSettingsAppNameViewTag 454002
#define kCKProvisioningSettingsVersionViewTag 454003
#define kCKProvisioningSettingsUpdateButtonTag 454004

@interface CKProvisioningController()
@property(nonatomic,retain) NSMutableArray* items;
@end

@interface CKProvisioningSettingsControllerButton : UIButton {
    id _userInfo;
}
@property(nonatomic,retain)id userInfo;
@end

@implementation CKProvisioningSettingsControllerButton
@synthesize userInfo = _userInfo;
@end

//

@interface CKProvisioningSettingsController ()
@property (nonatomic,retain) CKProvisioningController *provisioningController;
- (void)setupTable;
@end

//

@implementation CKProvisioningSettingsController

@synthesize provisioningController = _provisioningController;

- (void)postInit {
	[super postInit];
	self.style = UITableViewStylePlain;
	self.contentSizeForViewInPopover = CGSizeMake(320, 416);
	self.hidesBottomBarWhenPushed = YES;
	self.name = @"rigoloSettingsViewController";
    self.title = _(@"Wireless Updates");
}

- (id)initWithProvisioningController:(CKProvisioningController *)provisioningController {
	self = [super init];
	if (self) {
		self.provisioningController = provisioningController;
		[self setupTable];
	}
	return self;
}

+ (id)controllerWithProvisioningController:(CKProvisioningController *)provisioningController {
	return [[[CKProvisioningSettingsController alloc] initWithProvisioningController:provisioningController] autorelease];
}

- (void)dealloc {
	self.provisioningController = nil;
	[super dealloc];
}

// Setup Table

- (void)setupTable {
	__block CKProvisioningSettingsController *bself = self;

	CKProductRelease *productRelease = [[[CKProductRelease alloc] init] autorelease];
	productRelease.buildNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
	productRelease.versionNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];

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
		iconImageView.tag = kCKProvisioningSettingsIconViewTag;
		iconImageView.clipsToBounds = YES;
		iconImageView.layer.cornerRadius = 10;
		[controller.tableViewCell.contentView addSubview:iconImageView];
        UILabel* appNamelabel = [[[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(iconImageView.frame)+10, 10, controller.tableViewCell.contentView.bounds.size.width - CGRectGetMaxX(iconImageView.frame) - 20, CGRectGetMaxY(iconImageView.bounds))]autorelease];
        appNamelabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        appNamelabel.tag = kCKProvisioningSettingsAppNameViewTag;
        [controller.tableViewCell.contentView addSubview:appNamelabel];
        UILabel* currentVersionLabel = [[[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(controller.tableViewCell.contentView.bounds)-40, controller.tableViewCell.contentView.bounds.size.width - 20, 30)]autorelease];
        currentVersionLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        currentVersionLabel.tag = kCKProvisioningSettingsVersionViewTag;
		currentVersionLabel.textAlignment = UITextAlignmentCenter;
        [controller.tableViewCell.contentView addSubview:currentVersionLabel];
        return (id)nil; 
    }];
    [headerCellDescriptor setSetupBlock:^id(id value) {
        CKTableViewCellController* controller = (CKTableViewCellController*)value;
        CKProductRelease* productRelease = (CKProductRelease*)controller.value;
		UIImageView *iconImageView = (UIImageView *)[controller.tableViewCell.contentView viewWithTag:kCKProvisioningSettingsIconViewTag];
		iconImageView.image = [UIImage imageNamed:@"Icon.png"];
        UILabel* appNamelabel = (UILabel*)[controller.tableViewCell.contentView viewWithTag:kCKProvisioningSettingsAppNameViewTag];
        appNamelabel.text = productRelease.applicationName;
        UILabel* currentVersionLabel = (UILabel*)[controller.tableViewCell.contentView viewWithTag:kCKProvisioningSettingsVersionViewTag];
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
		CKProvisioningSettingsControllerButton* installButton = [[[CKProvisioningSettingsControllerButton alloc] initWithFrame:CGRectMake(10, 20, controller.tableViewCell.contentView.bounds.size.width-20, 90)] autorelease];
		installButton.tag = kCKProvisioningSettingsUpdateButtonTag;
		installButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
		[installButton setTitle:_(@"Check for Updates") forState:UIControlStateNormal];
		[installButton setBackgroundImage:[[CKBundle imageForName:@"rigolo-btn-blue.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:20] forState:UIControlStateNormal];
		[installButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
		[installButton addTarget:self.provisioningController action:@selector(checkUpdate:) forControlEvents:UIControlEventTouchUpInside];
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
	CKFormCellDescriptor* checkAutoCellDescriptor = [CKFormCellDescriptor cellDescriptorWithValue:[CKObjectProperty propertyWithObject:[CKProvisioningUserDefaults sharedInstance] keyPath:@"autoCheck"]  controllerClass:[CKNSNumberPropertyCellController class]];
    [checkAutoCellDescriptor setCreateBlock:^id(id value) {
        CKTableViewCellController* controller = (CKTableViewCellController*)value;
        controller.name = @"rigoloSettingsCheckAutoCell";
        controller.cellStyle = CKTableViewCellStyleDefault;
        return (id)nil;
    }];
    [checkAutoCellDescriptor setInitBlock:^id(id value) {
        CKTableViewCellController* controller = (CKTableViewCellController*)value;
        controller.tableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
		controller.tableViewCell.textLabel.text = _(@"Check Automatically");
        return (id)nil; 
    }];
    [checkAutoCellDescriptor setSizeBlock:^id(id value) {
        NSDictionary* params = (NSDictionary*)value;
        CGSize tableViewSize = [params bounds];
        return [NSValue valueWithCGSize:CGSizeMake(tableViewSize.width, 55)];
    }];
	[checkAutoCellDescriptor setFlags:CKItemViewFlagNone];
	
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
		controller.tableViewCell.textLabel.text = _(@"Release Notes");
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
		[bself.navigationController pushViewController:[CKProvisioningReleaseNotesViewController controllerWithProductRelease:productRelease] animated:YES];
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
		controller.tableViewCell.textLabel.text = _(@"Release History");
		controller.tableViewCell.imageView.image = [CKBundle imageForName:@"rigolo-release-history-icon.png"];
        return (id)nil; 
    }];
    [releaseHistoryCellDescriptor setSizeBlock:^id(id value) {
        NSDictionary* params = (NSDictionary*)value;
        CGSize tableViewSize = [params bounds];
        return [NSValue valueWithCGSize:CGSizeMake(tableViewSize.width, 65)];
    }];
	[releaseHistoryCellDescriptor setSelectionBlock:^id(id value) {
		CKObjectTableViewController *controller = [self.provisioningController controllerForProductReleases];
		[bself.navigationController pushViewController:controller animated:YES];
		NSString* bundleIdentifier = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
		[[CKProvisioningWebService sharedWebService]listAllProductReleasesWithBundleIdentifier:bundleIdentifier 
		 
																					completion:^(NSArray* productReleases){
																						[self.provisioningController.items removeAllObjects];
																						[self.provisioningController.items addObjectsFromArray:productReleases];
																						[controller reload];
																					}
		 
																					   failure:^(NSError* error){
																					   }];
		return (id)nil;
	}];
	[releaseHistoryCellDescriptor setFlags:CKItemViewFlagSelectable];
	
    [self addSectionWithCellDescriptors:[NSArray arrayWithObjects:headerCellDescriptor,updateCellDescriptor,checkAutoCellDescriptor,releaseNotesCellDescriptor,releaseHistoryCellDescriptor,nil]];	
}

@end
