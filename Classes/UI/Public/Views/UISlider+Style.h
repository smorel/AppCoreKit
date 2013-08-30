//
//  UISlider+Style.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-07-31.
//  Copyright (c) 2013 Sebastien Morel. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface UISlider (Style)

@property(nonatomic,retain) UIImage* defaultThumbImage;
@property(nonatomic,retain) UIImage* selectedThumbImage;
@property(nonatomic,retain) UIImage* disabledThumbImage;
@property(nonatomic,retain) UIImage* highlightedThumbImage;

@property(nonatomic,retain) UIImage* defaultMinimumTrackImage;
@property(nonatomic,retain) UIImage* selectedMinimumTrackImage;
@property(nonatomic,retain) UIImage* disabledMinimumTrackImage;
@property(nonatomic,retain) UIImage* highlightedMinimumTrackImage;

@property(nonatomic,retain) UIImage* defaultMaximumTrackImage;
@property(nonatomic,retain) UIImage* selectedMaximumTrackImage;
@property(nonatomic,retain) UIImage* disabledMaximumTrackImage;
@property(nonatomic,retain) UIImage* highlightedMaximumTrackImage;

@end
