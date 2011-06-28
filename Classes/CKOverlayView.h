//
//  CKOverlayView.h
//  BubbleView
//
//  Created by Olivier Collet on 10-06-20.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


/** TODO
 */
@interface CKOverlayView : UIView {
	UIView *_contentView;
	UILabel *_textLabel;

	NSUInteger _cornerRadius;

	CGFloat _shadowSize;
	CGFloat _shadowOffsetX;
	CGFloat _shadowOffsetY;
	
	BOOL _disableUserInteraction;
}

@property (nonatomic, retain) UIView *contentView;
@property (nonatomic, readonly, retain) UILabel *textLabel;
@property (nonatomic, assign) NSUInteger cornerRadius;
@property (nonatomic, assign) CGFloat shadowSize;
@property (nonatomic, assign) CGFloat shadowOffsetX;
@property (nonatomic, assign) CGFloat shadowOffsetY;
@property (nonatomic, assign) BOOL disableUserInteraction;

- (void)presentInView:(UIView *)parentView animated:(BOOL)animated;
- (void)presentInView:(UIView *)parentView animated:(BOOL)animated withDelay:(NSTimeInterval)delay;
- (void)dismiss:(BOOL)animated;

@end
