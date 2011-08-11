//
//  CKProvisioningReleaseViewController.m
//  CloudKit
//
//  Created by Olivier Collet on 11-08-09.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKProvisioningReleaseViewController.h"
#import "CKProvisioningReleaseNotesViewController.h"
#import "CKNSValueTransformer+Additions.h"
#import "CKObjectProperty.h"
#import "CKVersion.h"
#import "CKBundle.h"
#import "CKLocalization.h"

#import <QuartzCore/QuartzCore.h>

#define kCKProvisioningReleaseIconViewTag 454101
#define kCKProvisioningReleaseRecommendedViewTag 454102
#define kCKProvisioningReleaseAppNameViewTag 454103
#define kCKProvisioningReleaseVersionViewTag 454104
#define kCKProvisioningReleaseDateViewTag 454105
#define kCKProvisioningReleaseCurrentVersionViewTag 454106
#define kCKProvisioningReleaseInstallButtonTag 454107


@interface CKProvisioningController()
@property(nonatomic,retain) NSMutableArray* items;
@end

@interface CKProvisioningReleaseControllerButton : UIButton {
    id _userInfo;
}
@property(nonatomic,retain)id userInfo;
@end

@implementation CKProvisioningReleaseControllerButton
@synthesize userInfo = _userInfo;
@end

//

@implementation CKProvisioningReleaseViewController

+ (id)controllerWithProvisioningController:(CKProvisioningController *)provisioningController forProductRelease:(CKProductRelease *)productRelease {
	CKProvisioningReleaseViewController* formController = [[[CKProvisioningReleaseViewController alloc]initWithStyle:UITableViewStylePlain]autorelease];
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
		iconImageView.tag = kCKProvisioningReleaseIconViewTag;
		iconImageView.clipsToBounds = YES;
		iconImageView.layer.cornerRadius = 10;
		[controller.tableViewCell.contentView addSubview:iconImageView];
		UIView *recommendedView = [CKProvisioningController recommendedView];
		recommendedView.tag = kCKProvisioningReleaseRecommendedViewTag;
		CGRect frame = recommendedView.frame;
		frame.origin.x = controller.tableViewCell.contentView.bounds.size.width - recommendedView.bounds.size.width - 5;
		frame.origin.y = 5;
		recommendedView.frame = frame;
		[controller.tableViewCell.contentView addSubview:recommendedView];
        UILabel* appNamelabel = [[[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(iconImageView.frame)+10, 10, controller.tableViewCell.contentView.bounds.size.width - CGRectGetMaxX(iconImageView.frame) - 20, CGRectGetMaxY(iconImageView.bounds))]autorelease];
        appNamelabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        appNamelabel.tag = kCKProvisioningReleaseAppNameViewTag;
        [controller.tableViewCell.contentView addSubview:appNamelabel];
        UILabel* versionlabel = [[[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(iconImageView.frame)+10, (controller.tableViewCell.contentView.bounds.size.width - 30) /2, 30)]autorelease];
        versionlabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
        versionlabel.tag = kCKProvisioningReleaseVersionViewTag;
        [controller.tableViewCell.contentView addSubview:versionlabel];
        UILabel* datelabel = [[[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(versionlabel.frame)+10, CGRectGetMaxY(iconImageView.frame)+10, (controller.tableViewCell.contentView.bounds.size.width - 30) /2, 30)]autorelease];
        datelabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
        datelabel.tag = kCKProvisioningReleaseDateViewTag;
		datelabel.textAlignment = UITextAlignmentRight;
        [controller.tableViewCell.contentView addSubview:datelabel];
        UILabel* currentVersionLabel = [[[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(versionlabel.frame)+20, controller.tableViewCell.contentView.bounds.size.width - 20, 30)]autorelease];
        currentVersionLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        currentVersionLabel.tag = kCKProvisioningReleaseCurrentVersionViewTag;
		currentVersionLabel.textAlignment = UITextAlignmentCenter;
        [controller.tableViewCell.contentView addSubview:currentVersionLabel];
        return (id)nil; 
    }];
    [headerCellDescriptor setSetupBlock:^id(id value) {
        CKTableViewCellController* controller = (CKTableViewCellController*)value;
        CKProductRelease* productRelease = (CKProductRelease*)controller.value;
		UIView *recommendedView = [controller.tableViewCell.contentView viewWithTag:kCKProvisioningReleaseRecommendedViewTag];
		recommendedView.hidden = !productRelease.recommended;
		UIImageView *iconImageView = (UIImageView *)[controller.tableViewCell.contentView viewWithTag:kCKProvisioningReleaseIconViewTag];
		iconImageView.image = [UIImage imageNamed:@"Icon.png"];
        UILabel* appNamelabel = (UILabel*)[controller.tableViewCell.contentView viewWithTag:kCKProvisioningReleaseAppNameViewTag];
        appNamelabel.text = productRelease.applicationName;
        UILabel* versionlabel = (UILabel*)[controller.tableViewCell.contentView viewWithTag:kCKProvisioningReleaseVersionViewTag];
        versionlabel.text = CKVersionStringForProductRelease(productRelease);
        UILabel* datelabel = (UILabel*)[controller.tableViewCell.contentView viewWithTag:kCKProvisioningReleaseDateViewTag];
        datelabel.text = [NSValueTransformer transformProperty:[CKObjectProperty propertyWithObject:productRelease keyPath:@"releaseDate"] toClass:[NSString class]];
        UILabel* currentVersionLabel = (UILabel*)[controller.tableViewCell.contentView viewWithTag:kCKProvisioningReleaseCurrentVersionViewTag];
        currentVersionLabel.text = [NSString stringWithFormat:_(@"RIGOLO_You are currently running version %@"), CKApplicationVersion()];
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
		CKProvisioningReleaseControllerButton* installButton = [[[CKProvisioningReleaseControllerButton alloc] initWithFrame:CGRectInset(controller.tableViewCell.contentView.bounds, 10, 20)] autorelease];
		installButton.tag = kCKProvisioningReleaseInstallButtonTag;
		installButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[installButton setTitle:_(@"RIGOLO_INSTALL") forState:UIControlStateNormal];
		[installButton setTitle:_(@"RIGOLO_INSTALLED") forState:UIControlStateDisabled];
		[installButton setBackgroundImage:[[CKBundle imageForName:@"rigolo-btn-green.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:20] forState:UIControlStateNormal];
		[installButton setBackgroundImage:[[CKBundle imageForName:@"rigolo-btn-disabled.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:20] forState:UIControlStateDisabled];
		[installButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
		[installButton addTarget:provisioningController action:@selector(install:) forControlEvents:UIControlEventTouchUpInside];
		[controller.tableViewCell.contentView addSubview:installButton];
        return (id)nil; 
    }];
    [installCellDescriptor setSetupBlock:^id(id value) {
        CKTableViewCellController* controller = (CKTableViewCellController*)value;
        CKProductRelease* productRelease = (CKProductRelease*)controller.value;
		CKProvisioningReleaseControllerButton *installButton = (CKProvisioningReleaseControllerButton *)[controller.tableViewCell.contentView viewWithTag:kCKProvisioningReleaseInstallButtonTag];
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
		controller.tableViewCell.textLabel.text = _(@"RIGOLO_Release Notes");
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
		controller.tableViewCell.textLabel.text = _(@"RIGOLO_Release History");
		controller.tableViewCell.imageView.image = [CKBundle imageForName:@"rigolo-release-history-icon.png"];
        return (id)nil; 
    }];
    [releaseHistoryCellDescriptor setSizeBlock:^id(id value) {
        NSDictionary* params = (NSDictionary*)value;
        CGSize tableViewSize = [params bounds];
        return [NSValue valueWithCGSize:CGSizeMake(tableViewSize.width, 65)];
    }];
	[releaseHistoryCellDescriptor setSelectionBlock:^id(id value) {
		CKObjectTableViewController *controller = [provisioningController controllerForProductReleases];
		[formController.navigationController pushViewController:controller animated:YES];
		NSString* bundleIdentifier = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
		[[CKProvisioningWebService sharedWebService]listAllProductReleasesWithBundleIdentifier:bundleIdentifier 
		 
																					completion:^(NSArray* productReleases){
																						[provisioningController.items removeAllObjects];
																						[provisioningController.items addObjectsFromArray:productReleases];
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

@end
