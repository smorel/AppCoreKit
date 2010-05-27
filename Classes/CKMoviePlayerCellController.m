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

@interface CKMoviePlayerCellController ()
@property (nonatomic, retain) MPMoviePlayerController *playerController;
@end

@implementation CKMoviePlayerCellController

@synthesize playerController = _playerController;

- (id)initWithContentURL:(NSURL *)url {
	if (self = [super init]) {
		self.playerController = [[[MPMoviePlayerController alloc] initWithContentURL:url] autorelease];
		self.playerController.controlStyle = MPMovieControlStyleEmbedded;
		self.selectable = NO;
	}
	return self;
}

- (void)dealloc {
	self.playerController = nil;
	[super dealloc];
}

//

- (CGFloat)heightForRow {
	return 300.0f;
}

- (void)cellDidAppear:(UITableViewCell *)cell {
	return;
}

- (void)cellDidDisappear {
	[self.playerController stop];
}

- (UITableViewCell *)loadCell {
	UITableViewCell *cell = [self cellWithStyle:UITableViewCellStyleDefault];
	
	self.playerController.view.frame = CGRectInset(cell.contentView.bounds, 10, 10);
	self.playerController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;;
	self.playerController.scalingMode = MPMovieScalingModeAspectFit;
	cell.backgroundColor = [UIColor blackColor];	
	[cell.contentView addSubview:self.playerController.view];
	
	return cell;
}

- (void)setupCell:(UITableViewCell *)cell {
	return;
}

@end
