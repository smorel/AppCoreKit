//
//  CKStyleView.h
//  CloudKit
//
//  Created by Olivier Collet on 11-04-07.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKRoundedCornerView.h"

/** TODO
 */
typedef enum {
	CKStyleViewBorderLocationNone = 0,
	CKStyleViewBorderLocationTop = 1 << 1,
	CKStyleViewBorderLocationBottom = 1 << 2,
	CKStyleViewBorderLocationRight = 1 << 3,
	CKStyleViewBorderLocationLeft = 1 << 4,
	CKStyleViewBorderLocationAll = CKStyleViewBorderLocationTop | CKStyleViewBorderLocationBottom | CKStyleViewBorderLocationRight | CKStyleViewBorderLocationLeft
} CKStyleViewBorderLocation;

/** TODO
 */
typedef enum {
	CKStyleViewSeparatorLocationNone = CKStyleViewBorderLocationNone,
	CKStyleViewSeparatorLocationTop = CKStyleViewBorderLocationTop,
	CKStyleViewSeparatorLocationBottom = CKStyleViewBorderLocationBottom,
	CKStyleViewSeparatorLocationRight = CKStyleViewBorderLocationRight,
	CKStyleViewSeparatorLocationLeft = CKStyleViewBorderLocationLeft,
	CKStyleViewSeparatorLocationAll = CKStyleViewBorderLocationAll
} CKStyleViewSeparatorLocation;


/** TODO
 */
@interface CKStyleViewUpdater : NSObject{
	UIView* _view;
	CGSize _size;
}
@property(nonatomic,assign)UIView* view;
- (id)initWithView:(UIView*)view;
@end


/** TODO
 */
@interface CKStyleView : CKRoundedCornerView {
	NSArray *_gradientColors;
	NSArray *_gradientColorLocations;
	UIImage *_image;
	UIViewContentMode _imageContentMode;
    
	NSInteger _borderLocation;
	UIColor* _borderColor;
	CGFloat _borderWidth;
    
	NSInteger _separatorLocation;
	UIColor* _separatorColor;
	CGFloat _separatorWidth;
	
	CKStyleViewUpdater* _updater;
	
	UIColor* _fillColor;
	UIColor *_embossTopColor;
	UIColor *_embossBottomColor;
}

@property (nonatomic, retain) NSArray *gradientColors;
@property (nonatomic, retain) NSArray *gradientColorLocations;

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, assign) UIViewContentMode imageContentMode;

@property (nonatomic, retain) UIColor *borderColor;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, assign) NSInteger borderLocation;

@property (nonatomic, retain) UIColor *separatorColor;
@property (nonatomic, assign) CGFloat separatorWidth;
@property (nonatomic, assign) NSInteger separatorLocation;

@property (nonatomic, retain) UIColor *embossTopColor;
@property (nonatomic, retain) UIColor *embossBottomColor;

@end
