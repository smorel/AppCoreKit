//
//  CKUIGradientView.h
//  GroupedTableStyled
//
//  Created by Olivier Collet on 11-04-07.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKRoundedCornerView.h"


@interface CKGradientView : CKRoundedCornerView {
	NSArray *_gradientColors;
	NSArray *_gradientColorLocations;
	UIImage *_image;
}

@property (nonatomic, retain) NSArray *gradientColors;
@property (nonatomic, retain) NSArray *gradientColorLocations;
@property (nonatomic, retain) UIImage *image;

@end
