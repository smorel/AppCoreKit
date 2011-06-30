//
//  CKUIGradientView.h
//  GroupedTableStyled
//
//  Created by Olivier Collet on 11-04-07.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKRoundedCornerView.h"

/** TODO
 */
typedef enum {
	CKGradientViewBorderTypeNone = 0,
	CKGradientViewBorderTypeTop = 1 << 1,
	CKGradientViewBorderTypeBottom = 1 << 2,
	CKGradientViewBorderTypeRight = 1 << 3,
	CKGradientViewBorderTypeLeft = 1 << 4,
	CKGradientViewBorderTypeAll = CKGradientViewBorderTypeTop | CKGradientViewBorderTypeBottom | CKGradientViewBorderTypeRight | CKGradientViewBorderTypeLeft
} CKGradientViewBorderType;


/** TODO
 */
@interface CKGradientViewUpdater : NSObject{
	UIView* _view;
	CGSize _size;
}
@property(nonatomic,assign)UIView* view;
- (id)initWithView:(UIView*)view;
@end


/** TODO
 */
@interface CKGradientView : CKRoundedCornerView {
	NSArray *_gradientColors;
	NSArray *_gradientColorLocations;
	UIImage *_image;
	UIViewContentMode _imageContentMode;
	UIColor* _borderColor;
	CGFloat _borderWidth;
	
	CKGradientViewUpdater* _updater;
	
	NSInteger _borderStyle;
	
	UIColor* _fillColor;
	UIColor *_embossTopColor;
	UIColor *_embossBottomColor;
}

@property (nonatomic, retain) NSArray *gradientColors;
@property (nonatomic, retain) NSArray *gradientColorLocations;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) UIColor *borderColor;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, assign) NSInteger borderStyle;
@property (nonatomic, assign) UIViewContentMode imageContentMode;
@property (nonatomic, retain) UIColor *embossTopColor;
@property (nonatomic, retain) UIColor *embossBottomColor;

@end
