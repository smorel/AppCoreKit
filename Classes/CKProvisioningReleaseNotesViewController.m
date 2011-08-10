//
//  CKProvisioningReleaseNotesViewController.m
//  CloudKit
//
//  Created by Olivier Collet on 11-08-09.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKProvisioningReleaseNotesViewController.h"
#import "CKStyleManager.h"
#import "CKBundle.h"

#define kCKProvisioningReleaseNotesNotesViewTag 454201
#define kCKProvisioningReleaseNotesHeaderViewTag 454202
#define kCKProvisioningReleaseNotesVersionViewTag 454203

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
	notesView.tag = kCKProvisioningReleaseNotesNotesViewTag;
	notesView.editable = NO;
	notesView.backgroundColor = [UIColor colorWithPatternImage:[CKBundle imageForName:@"rigolo-notes-bg.png"]];
	notesView.font = [UIFont fontWithName:@"Noteworthy-Bold" size:17];
	notesView.text = self.productRelease.releaseNotes;
	[self.view addSubview:notesView];
	
	CKGradientView *headerView = [[[CKGradientView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50)] autorelease];
	headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	headerView.tag = kCKProvisioningReleaseNotesHeaderViewTag;
	[self.view addSubview:headerView];
	
	UILabel *versionLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, 0, headerView.bounds.size.width-20, headerView.bounds.size.height)] autorelease];
	versionLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	versionLabel.tag = kCKProvisioningReleaseNotesVersionViewTag;
	versionLabel.textAlignment = UITextAlignmentCenter;
	versionLabel.text = CKVersionStringForProductRelease(self.productRelease);
	[self.view addSubview:versionLabel];
	
	UIImageView *pageTears = [[[UIImageView alloc] initWithImage:[CKBundle imageForName:@"rigolo-notes-pagetears.png"]] autorelease];
	pageTears.frame = CGRectMake(0, 50, self.view.bounds.size.width, pageTears.bounds.size.height);
	pageTears.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[self.view addSubview:pageTears];
	
	[self applyStyle];
}

@end
