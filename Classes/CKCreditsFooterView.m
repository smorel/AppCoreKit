//
//  CKCreditsFooterView.m
//  CloudKit
//
//  Created by Olivier Collet on 10-09-08.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKCreditsFooterView.h"
#import "CKUIColorAdditions.h"
#import "CKBundle.h"
#import "CKLocalization.h"

@implementation CKCreditsFooterView


- (id)initWithTitle:(NSString *)title {
    if ((self = [super initWithFrame:CGRectMake(0, 0, 320, (title ? 100 :60))])) {
		CGFloat yOffset = 0;
		if (title) {
			UILabel *titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 25)] autorelease];
			titleLabel.backgroundColor = [UIColor clearColor];
			titleLabel.font = [UIFont systemFontOfSize:17];
			titleLabel.textColor = [UIColor colorWithRGBValue:0x4c566c];
			titleLabel.shadowColor = [UIColor whiteColor];
			titleLabel.shadowOffset = CGSizeMake(0, 1);
			titleLabel.textAlignment = UITextAlignmentCenter;
			titleLabel.text = title;
			[self addSubview:titleLabel];
			
			yOffset = 45;
		}
		
		UIImageView *wherecloudLogo = [[[UIImageView alloc] initWithImage:[CKBundle imageForName:@"CKCreditsFooterViewWCLogo.png"]] autorelease];
		wherecloudLogo.center = self.center;
		CGRect logoFrame = wherecloudLogo.frame;
		logoFrame.origin.y = yOffset;
		wherecloudLogo.frame = logoFrame;
		[self addSubview:wherecloudLogo];

		UILabel *wherecloudLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(wherecloudLogo.frame) + 5, 320, 25)] autorelease];
		wherecloudLabel.backgroundColor = [UIColor clearColor];
		wherecloudLabel.font = [UIFont systemFontOfSize:17];
		wherecloudLabel.textColor = [UIColor colorWithRGBValue:0x4c566c];
		wherecloudLabel.shadowColor = [UIColor whiteColor];
		wherecloudLabel.shadowOffset = CGSizeMake(0, 1);
		wherecloudLabel.textAlignment = UITextAlignmentCenter;
		wherecloudLabel.text = _(@"Beautifully crafted by WhereCloud Inc.");
		[self addSubview:wherecloudLabel];
	}
    return self;
}

+ (id)creditsViewWithTitle:(NSString *)title {
	return [[[CKCreditsFooterView alloc] initWithTitle:title] autorelease];
}

- (void)dealloc {
    [super dealloc];
}


@end
