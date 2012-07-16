//
//  CKOverlayView+Factory.m
//  CloudKit
//
//  Created by Olivier Collet.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKOverlayView+Factory.h"
#import "CKConstants.h"


@implementation CKOverlayView (CKOverlayViewFactory)

+ (id)overlayViewWithView:(UIView *)view text:(NSString *)text {
	CKOverlayView *overlayView = [[[CKOverlayView alloc] initWithFrame:CGRectMake(0, 0, 160, 160)] autorelease];
	overlayView.cornerRadius = 10;

	UILabel *textLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 140, 14)] autorelease];
	textLabel.font = [UIFont boldSystemFontOfSize:15];
	textLabel.backgroundColor = [UIColor clearColor];
	textLabel.textColor = [UIColor whiteColor];
	textLabel.textAlignment = UITextAlignmentCenter;
	textLabel.text = text;
	[textLabel sizeToFit];

	UIView *contentView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 140, 140)] autorelease];
	contentView.backgroundColor = [UIColor clearColor];
	contentView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;

	view.center = contentView.center;
	textLabel.center = contentView.center;
	view.frame = CGRectIntegral(CGRectOffset(view.frame, 0, (text) ? -10 : 0));
	textLabel.frame = CGRectIntegral(CGRectOffset(textLabel.frame, 0, view.frame.size.height/2 + 10));

	[contentView addSubview:view];
	if (text) [contentView addSubview:textLabel];
	
	contentView.center = overlayView.contentView.center;
	[overlayView.contentView addSubview:contentView];

	return overlayView;
}

+ (id)loadingOverlayWithText:(NSString *)text {
	UIActivityIndicatorView *spinner = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
	spinner.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	[spinner startAnimating];
	
	return [CKOverlayView overlayViewWithView:spinner text:text];
}

+ (id)overlayViewWithImage:(UIImage *)image text:(NSString *)text {	
	return [CKOverlayView overlayViewWithView:[[[UIImageView alloc] initWithImage:image] autorelease] text:text];
}

@end
