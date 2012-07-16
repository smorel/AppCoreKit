//
//  CKUIView+Factory.m
//  CloudKit
//
//  Created by Jean-Philippe Martin.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKUIView+Factory.h"

@implementation UIView (CKUIViewFactory)

+ (UIView *)titleViewForTitle:(NSString *)title withSubtitle:(NSString *)subtitle {
	UILabel *titleLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.textColor = [UIColor whiteColor];
	titleLabel.shadowColor = [UIColor blackColor];
	titleLabel.shadowOffset = CGSizeMake(0, -1);
	titleLabel.font = [UIFont boldSystemFontOfSize:((subtitle.length == 0) ? 20 : 17)];
	titleLabel.textAlignment = UITextAlignmentCenter;
	titleLabel.text = title;
	[titleLabel sizeToFit];
	
	UILabel *subtitleLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
	subtitleLabel.backgroundColor = [UIColor clearColor];
	subtitleLabel.textColor = [UIColor lightGrayColor];
	subtitleLabel.shadowColor = [UIColor blackColor];
	subtitleLabel.shadowOffset = CGSizeMake(0, -1);
	subtitleLabel.font = [UIFont boldSystemFontOfSize:13];
	subtitleLabel.textAlignment = UITextAlignmentCenter;
	subtitleLabel.text = subtitle;
	[subtitleLabel sizeToFit];
	
	CGFloat viewWidth = MAX(titleLabel.frame.size.width, subtitleLabel.frame.size.width);
	titleLabel.frame = CGRectMake(0, 0, viewWidth, ((subtitle.length == 0) ? 40 : titleLabel.frame.size.height));
	subtitleLabel.frame = CGRectMake(0, 22, viewWidth, subtitleLabel.frame.size.height);
	
	UIView *titleView = [[[UIView alloc] init] autorelease];
	titleView.backgroundColor = [UIColor clearColor];
	titleView.frame = CGRectMake(0, 0, viewWidth, 43);
	[titleView addSubview:titleLabel];
	if (subtitle.length > 0) [titleView addSubview:subtitleLabel];
	
	return titleView;
}

@end
