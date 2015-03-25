//
//  UIView+Highlight.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-25.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 */
@interface UIView (Highlight)

/**
 */
@property(nonatomic,retain) UIColor* highlightedBackgroundColor;

/*
 */
@property(nonatomic,getter=isHighlighted) BOOL highlighted;

@end
