//
//  CKMoviePlayerCellController.m
//  CloudKit
//
//  Created by Fred Brunel on 10-05-27.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKMoviePlayerCellController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200

CGRect __CGRectCenter(CGRect rect, CGRect target) {
	return CGRectMake((target.size.width / 2) - (rect.size.width / 2), 
					  (target.size.height / 2) - (rect.size.height / 2), 
					  rect.size.width, rect.size.height);
}

@interface CKMoviePlayerCellController ()
@property (nonatomic, retain) MPMoviePlayerController *playerController;
@end

@implementation CKMoviePlayerCellController

@synthesize playerController = _playerController;

- (id)initWithContentURL:(NSURL *)url {
	if (self = [super init]) {
		self.playerController = [[[MPMoviePlayerController alloc] initWithContentURL:url] autorelease];
		self.playerController.controlStyle = MPMovieControlStyleEmbedded;
	}
	return self;
}

- (void)postInit{
    [super postInit];
    self.flags = CKItemViewFlagNone;
}

- (void)dealloc {
	[self.playerController stop];
	self.playerController = nil;
	[super dealloc];
}

//

- (CGFloat)heightForRow {
	return 300.0f;
}

- (void)cellDidAppear:(UITableViewCell *)cell {
	[super cellDidAppear:cell];
	return;
}

- (void)cellDidDisappear {
	[self.playerController stop];
}

- (void)initTableViewCell:(UITableViewCell*)cell{
	self.playerController.view.frame = CGRectInset(cell.contentView.bounds, 10, 10);
	self.playerController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;;
	self.playerController.scalingMode = MPMovieScalingModeAspectFit;
	cell.backgroundColor = [UIColor blackColor];
	
	UIActivityIndicatorView *spinner = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
	[spinner startAnimating];
	spinner.center = cell.contentView.center;
	spinner.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	
	[cell.contentView addSubview:spinner];
	[cell.contentView addSubview:self.playerController.view];
}

- (void)setupCell:(UITableViewCell *)cell {
	[super setupCell:cell];
	return;
}

@end

#endif