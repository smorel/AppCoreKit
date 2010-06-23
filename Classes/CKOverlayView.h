//
//  CKOverlayView.h
//  BubbleView
//
//  Created by Olivier Collet on 10-06-20.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CKOverlayView : UIView {
	UIView *_contentView;
	UILabel *_textLabel;

	NSUInteger _cornerRadius;

	CGFloat _shadowSize;
	CGFloat _shadowOffsetX;
	CGFloat _shadowOffsetY;
}

@property (nonatomic, retain) UIView *contentView;
@property (nonatomic, readonly, retain) UILabel *textLabel;
@property (nonatomic, assign) NSUInteger cornerRadius;
@property (nonatomic, assign) CGFloat shadowSize;
@property (nonatomic, assign) CGFloat shadowOffsetX;
@property (nonatomic, assign) CGFloat shadowOffsetY;

- (void)presentInView:(UIView *)parentView animated:(BOOL)animated;
- (void)dismiss:(BOOL)animated;

- (CGPathRef)getPath;

@end
