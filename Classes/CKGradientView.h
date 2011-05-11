//
//  CKUIGradientView.h
//  GroupedTableStyled
//
//  Created by Olivier Collet on 11-04-07.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKRoundedCornerView.h"


@interface CKGradientViewUpdater : NSObject{
	UIView* _view;
}
@property(nonatomic,assign)UIView* view;
- (id)initWithView:(UIView*)view;
@end


@interface CKGradientView : CKRoundedCornerView {
	NSArray *_gradientColors;
	NSArray *_gradientColorLocations;
	UIImage *_image;
	UIColor* _borderColor;
	CGFloat _borderWidth;
	
	CKGradientViewUpdater* _updater;
}

@property (nonatomic, retain) NSArray *gradientColors;
@property (nonatomic, retain) NSArray *gradientColorLocations;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) UIColor *borderColor;
@property (nonatomic, assign) CGFloat borderWidth;

@end
