//
//  CKCreditsFooterView.m
//  CloudKit
//
//  Created by Olivier Collet on 10-09-08.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKCreditsFooterView.h"
#import "CKUIColor+Additions.h"
#import "CKLocalization.h"

@interface UIImageView (CKCreditsView)

+ (UIImageView *)imageViewWithImageNamed:(NSString *)imageName;

@end

@implementation UIImageView (CKCreditsView)

+ (UIImageView *)imageViewWithImageNamed:(NSString *)imageName {
	return [[[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]] autorelease];
}

@end

//

@interface CKCreditsFooterView ()

- (id)initWithStyle:(CKCreditsViewStyle)style;

@property (nonatomic, assign) CKCreditsViewStyle style;
@property (nonatomic, assign) BOOL displayingFrontPlate;
@property (nonatomic, retain) UIImageView *titleView;
@property (nonatomic, retain) UIImageView *plateView;
@property (nonatomic, retain) UIImageView *plateBackView;
@property (nonatomic, retain) UILabel *versionLabel;

@end

//

@implementation CKCreditsFooterView

@synthesize style = _style;
@synthesize displayingFrontPlate = _displayingFrontPlate;
@synthesize titleView = _titleView;
@synthesize plateView = _plateView;
@synthesize plateBackView = _plateBackView;
@synthesize versionLabel = _versionLabel;


- (id)initWithStyle:(CKCreditsViewStyle)style {
	self = [super init];
	if (self) {
		self.style = style;
		self.backgroundColor = [UIColor clearColor];
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.displayingFrontPlate = YES;

		CGFloat topMargin = 5;
		CGFloat titlePlateMargin = 2;
		CGFloat plateVersionMargin = 5;
		
		NSString *versionNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
		NSString *buildNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];		
		NSString *appVersion = [NSString stringWithFormat:@"Version %@ (%@)", versionNumber, buildNumber];	
		
		self.plateView = nil;
		switch (self.style) {
			case CKCreditsViewStyleDark:
				self.titleView = [UIImageView imageViewWithImageNamed:@"wc-appsignature-type-dark-craftedby.png"];
				self.plateView = [UIImageView imageViewWithImageNamed:@"wc-appsignature-dark-front.png"];
				break;
				
			default:
				self.titleView = [UIImageView imageViewWithImageNamed:@"wc-appsignature-type-light-craftedby.png"];
				self.plateView = [UIImageView imageViewWithImageNamed:@"wc-appsignature-light-front.png"];
				break;
		}

		self.versionLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
		_versionLabel.backgroundColor = [UIColor clearColor];
		_versionLabel.textAlignment = UITextAlignmentCenter;
		_versionLabel.font = [UIFont systemFontOfSize:14];
		_versionLabel.text = appVersion;
		_versionLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		[_versionLabel sizeToFit];
        
        switch (style) {
            case CKCreditsViewStyleDark:
                _versionLabel.textColor = [UIColor colorWithRGBValue:0xa4a4a4];
                _versionLabel.shadowOffset = CGSizeMake(0, 1);
                _versionLabel.shadowColor = [UIColor colorWithRGBValue:0x000000];
                break;
                
            case CKCreditsViewStyleLight:
                _versionLabel.textColor = [UIColor colorWithRGBValue:0x4c566c];
                _versionLabel.shadowOffset = CGSizeMake(0, 1);
                _versionLabel.shadowColor = [UIColor colorWithRGBValue:0xffffff];
                break;
        }
		
		UIView *plateContainerView = [[[UIView alloc] initWithFrame:self.plateView.frame] autorelease];
		[plateContainerView addSubview:self.plateView];

		CGFloat height = topMargin + CGRectGetMaxY(self.titleView.bounds) + titlePlateMargin + CGRectGetMaxY(self.plateView.bounds) + plateVersionMargin + 18;
		self.frame = CGRectMake(0, 0, 320, height);

		CGFloat titleViewOffsetX = roundf((CGRectGetMaxX(self.bounds) - CGRectGetMaxX(self.titleView.bounds)) / 2);
		self.titleView.frame = CGRectOffset(self.titleView.frame, titleViewOffsetX, topMargin);
		self.titleView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		
		CGFloat plateViewOffsetX = roundf((CGRectGetMaxX(self.bounds) - CGRectGetMaxX(plateContainerView.bounds)) / 2);
		CGFloat plateViewOffsetY = roundf(CGRectGetMaxY(self.titleView.frame) + titlePlateMargin);
		plateContainerView.frame = CGRectOffset(plateContainerView.frame, plateViewOffsetX, plateViewOffsetY);
		plateContainerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		
		CGFloat versionLabelOffsetX = roundf((CGRectGetMaxX(self.bounds) - CGRectGetMaxX(_versionLabel.bounds)) / 2);
		CGFloat versionLabelOffsetY = roundf(CGRectGetMaxY(plateContainerView.frame) + plateVersionMargin);
		_versionLabel.frame = CGRectOffset(_versionLabel.frame, versionLabelOffsetX, versionLabelOffsetY);
		
		[self addSubview:self.titleView];
		[self addSubview:plateContainerView];
		[self addSubview:_versionLabel];
		
		/*
		UISwipeGestureRecognizer *leftSwipeGesture = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftSwipeGesture:)] autorelease];
		leftSwipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
		[self addGestureRecognizer:leftSwipeGesture];
		UISwipeGestureRecognizer *rightSwipeGesture = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightSwipeGesture:)] autorelease];
		rightSwipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
		[self addGestureRecognizer:rightSwipeGesture];
		 */
	}
	return self;
}

+ (id)creditsViewWithStyle:(CKCreditsViewStyle)style {
	return [[[CKCreditsFooterView alloc] initWithStyle:style] autorelease];
}

- (void)dealloc {
	self.titleView = nil;
	self.plateView = nil;
	self.plateBackView = nil;
	self.versionLabel = nil;
	[super dealloc];
}

- (UIImageView *)plateBackView {
	if (_plateBackView == nil) {
		switch(_style) {
			case CKCreditsViewStyleDark:
				_plateBackView = [[UIImageView imageViewWithImageNamed:@"wc-appsignature-dark-back.png"] retain];
				break;
				
			default:
				_plateBackView = [[UIImageView imageViewWithImageNamed:@"wc-appsignature-light-back.png"] retain];
				break;
		}
		_plateBackView.frame = CGRectOffset(_plateBackView.frame, self.plateView.frame.origin.x, self.plateView.frame.origin.y);
	}
	return _plateBackView;
}

- (void)togglePlateWithDirection:(UISwipeGestureRecognizerDirection)direction {
	[UIView transitionFromView:(_displayingFrontPlate ? self.plateView : self.plateBackView)
						toView:(_displayingFrontPlate ? self.plateBackView : self.plateView)
					  duration:0.4
					   options:((direction & UISwipeGestureRecognizerDirectionRight) ? UIViewAnimationOptionTransitionFlipFromLeft : UIViewAnimationOptionTransitionFlipFromRight)
					completion:^(BOOL finished) {
						_displayingFrontPlate = !_displayingFrontPlate;
					}];
}

- (void)handleLeftSwipeGesture:(UISwipeGestureRecognizer *)gesture { [self togglePlateWithDirection:UISwipeGestureRecognizerDirectionLeft]; }
- (void)handleRightSwipeGesture:(UISwipeGestureRecognizer *)gesture { [self togglePlateWithDirection:UISwipeGestureRecognizerDirectionRight]; }

@end
