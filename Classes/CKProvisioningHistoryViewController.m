//
//  CKProvisioningHistoryViewController.m
//  CloudKit
//
//  Created by Olivier Collet on 11-08-09.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKProvisioningHistoryViewController.h"
#import "CKDocumentArray.h"
#import "CKObjectProperty.h"
#import "CKNSValueTransformer+Additions.h"
#import "CKBundle.h"
#import "CKLocalization.h"

#define kCKProvisioningHistoryVersionViewTag 454301
#define kCKProvisioningHistoryDateViewTag 454302
#define kCKProvisioningHistoryRecommendedViewTag 454303

@implementation CKProvisioningHistoryViewController

+ (id)controllerWithProvisioningController:(CKProvisioningController *)provisioningController {

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
        versionlabel.tag = kCKProvisioningHistoryVersionViewTag;
        [controller.tableViewCell.contentView addSubview:versionlabel];
        UILabel* datelabel = [[[UILabel alloc]initWithFrame:CGRectMake(15, CGRectGetMaxY(versionlabel.frame)+5, 280, 30)] autorelease];
        datelabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        datelabel.tag = kCKProvisioningHistoryDateViewTag;
        [controller.tableViewCell.contentView addSubview:datelabel];
		UIView *recommendedView = [CKProvisioningController recommendedView];
		recommendedView.tag = kCKProvisioningHistoryRecommendedViewTag;
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
		UILabel* versionlabel = (UILabel*)[controller.tableViewCell.contentView viewWithTag:kCKProvisioningHistoryVersionViewTag];
        versionlabel.text = CKVersionStringForProductRelease(productRelease);
        UILabel* datelabel = (UILabel*)[controller.tableViewCell.contentView viewWithTag:kCKProvisioningHistoryDateViewTag];
        datelabel.text = [NSValueTransformer transformProperty:[CKObjectProperty propertyWithObject:productRelease keyPath:@"releaseDate"] toClass:[NSString class]];
		UIView *recommendedView = [controller.tableViewCell viewWithTag:kCKProvisioningHistoryRecommendedViewTag];
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
		[provisioningController displayProductRelease:productRelease parentController:controller.parentController];
		return (id)nil;
	}];
	[releaseCellDescriptor setFlags:CKItemViewFlagSelectable];
	
    NSString* bundleIdentifier = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
	CKDocumentArray *collection = [[[CKDocumentArray alloc] initWithFeedSource:[[CKProvisioningWebService sharedWebService] sourceForReleasesWithBundleIdentifier:bundleIdentifier]] autorelease];
	CKProvisioningHistoryViewController* tableViewController = [[[CKProvisioningHistoryViewController alloc]initWithCollection:collection mappings:mappings]autorelease];
	tableViewController.name = @"rigoloReleasesViewController";
	tableViewController.contentSizeForViewInPopover = CGSizeMake(320, 416);
	tableViewController.title = _(@"Versions");
	return tableViewController;
}

@end



