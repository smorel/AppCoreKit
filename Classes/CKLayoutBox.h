//
//  CKLayoutBox.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2012 WhereCloud Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

//#define LAYOUT_DEBUG_ENABLED

@protocol CKLayoutBoxProtocol;
typedef void(^CKLayoutBoxInvalidatedBlock)(NSObject<CKLayoutBoxProtocol>* layoutBox);

/**
 */
@protocol CKLayoutBoxProtocol

///-----------------------------------
/// @name Accessing a layout at runtime
///-----------------------------------

/** The name of the layout to acces it using layoutWithName: or layoutWithKeyPath:
 */
@property(nonatomic,retain) NSString* name;

/* Returns the first layout box matching name in the layout hierarchy
 */
- (id<CKLayoutBoxProtocol>)layoutWithName:(NSString*)name;

/* Returns the exact layout box matching the specified keypath (name.name.name ...)
 */
- (id<CKLayoutBoxProtocol>)layoutWithKeyPath:(NSString*)keypath;


///-----------------------------------
/// @name Configuring a LayoutBox’s Visual Appearance
///-----------------------------------

/** The children layoutBox that will get layouted by the current layout box.
 */
@property(nonatomic,retain) NSArray* layoutBoxes;

/**
 */
@property(nonatomic,assign) CGSize maximumSize;
/**
 */
@property(nonatomic,assign) CGFloat maximumWidth;
/**
 */
@property(nonatomic,assign) CGFloat maximumHeight;

/**
 */
@property(nonatomic,assign) CGSize minimumSize;
/**
 */
@property(nonatomic,assign) CGFloat minimumWidth;
/**
 */
@property(nonatomic,assign) CGFloat minimumHeight;

/**
 */
@property(nonatomic,assign) CGSize fixedSize;
/**
 */
@property(nonatomic,assign) CGFloat fixedWidth;
/**
 */
@property(nonatomic,assign) CGFloat fixedHeight;

/**
 */
@property(nonatomic,assign) UIEdgeInsets margins;
/**
 */
@property(nonatomic,assign) CGFloat marginLeft;
/**
 */
@property(nonatomic,assign) CGFloat marginTop;
/**
 */
@property(nonatomic,assign) CGFloat marginBottom;
/**
 */
@property(nonatomic,assign) CGFloat marginRight;

/**
 */
@property(nonatomic,assign) UIEdgeInsets padding;
/**
 */
@property(nonatomic,assign) CGFloat paddingLeft;
/**
 */
@property(nonatomic,assign) CGFloat paddingTop;
/**
 */
@property(nonatomic,assign) CGFloat paddingBottom;
/**
 */
@property(nonatomic,assign) CGFloat paddingRight;

/**
 */
@property(nonatomic,assign,getter=isHidden) BOOL hidden;


///-----------------------------------
/// @name Accessing the parent UIView and LayoutBox
///-----------------------------------

/** The layout box containing the current layout box.
 */
@property(nonatomic,assign) NSObject<CKLayoutBoxProtocol>* containerLayoutBox;

/** The UIView containing the current layout box.
 */
@property(nonatomic,assign,readonly) UIView* containerLayoutView;

/** The root layout box of the hierarchy.
 */
- (NSObject<CKLayoutBoxProtocol>*)rootLayoutBox;


///-----------------------------------
/// @name Performing the layout
///-----------------------------------

/** This returns the current frame of a layout box. Setting or animating this value in a layouted hierachy will have an unknown effect and will be ignore as soon as layoutSubviews will get called in one of the layouted UIView.
 */
@property(nonatomic,assign) CGRect frame;


/** This method computes the prefered size for the layout box including padding.
 */
- (CGSize)preferedSizeConstraintToSize:(CGSize)size;

/** This method performs the layout on the box and its sub boxes
 */
- (void)performLayoutWithFrame:(CGRect)frame;

/**
 */
- (void)invalidateLayout;

/** This block gets called when parts of the layout has been invalidated.
 You can implement this block to get notified that the global size of the layouted UIView could change (For example a tableViewCell's contentView).
 This block must be set on the root view contaning layoutBoxes. The subViews of subBoxes will not call this for performance reasons.
 
 The signature of this block is:
     void(^)(NSObject<CKLayoutBoxProtocol>* layoutBox);
 */
@property(nonatomic,copy) CKLayoutBoxInvalidatedBlock invalidatedLayoutBlock;


///PRIVATE

@property(nonatomic,assign,readwrite) CGSize lastComputedSize;
@property(nonatomic,assign,readwrite) CGSize lastPreferedSize;

- (id<CKLayoutBoxProtocol>)_layoutWithNameInSelf:(NSString*)name;

- (void)setBoxFrameTakingCareOfTransform:(CGRect)rect;

@end


//CKLayoutBox

typedef enum CKLayoutVerticalAlignment{
    CKLayoutVerticalAlignmentTop,
    CKLayoutVerticalAlignmentCenter,
    CKLayoutVerticalAlignmentBottom
}CKLayoutVerticalAlignment;

typedef enum CKLayoutHorizontalAlignment{
    CKLayoutHorizontalAlignmentLeft,
    CKLayoutHorizontalAlignmentCenter,
    CKLayoutHorizontalAlignmentRight
}CKLayoutHorizontalAlignment;


/** CKLayoutBox is the base class for the various layout algorithms.
 @see : CKVerticalBoxLayout, CKHorizontalBoxLayout, CKLayoutFlexibleSpace
 */
@interface CKLayoutBox : NSObject<CKLayoutBoxProtocol>

/** This specify how to align the children layout box vertically in case the height of the current layoutbox is higher that the height of the layouted children boxes.
 
 The possible values are :
     * CKLayoutVerticalAlignmentTop
     * CKLayoutVerticalAlignmentCenter
     * CKLayoutVerticalAlignmentBottom
 
 @info : You can use flexible spaces.
 */
@property(nonatomic,assign) CKLayoutVerticalAlignment verticalAlignment;

/** This specify how to align the children layout box horizontally in case the width of the current layoutbox is higher that the width of the layouted children boxes.
 
 The possible values are :
 * CKLayoutVerticalAlignmentTop
 * CKLayoutVerticalAlignmentCenter
 * CKLayoutVerticalAlignmentBottom
 
 @info : You can use flexible spaces.
 */
@property(nonatomic,assign) CKLayoutHorizontalAlignment horizontalAlignment;

@end



//CKVerticalBoxLayout

/** CKVerticalBoxLayout layouts children layoutBoxes vertically.
 */
@interface CKVerticalBoxLayout : CKLayoutBox
@end

//CKHorizontalBoxLayout

/** CKHorizontalBoxLayout layouts children layoutBoxes horizontally.
 */
@interface CKHorizontalBoxLayout : CKLayoutBox
@end

//CKLayoutFlexibleSpace

/** CKLayoutFlexibleSpace responsability is to pack free space to the maximum. The space is distributed equally between the other items. You can also specify maximum/minimum or fixed size for flexible spaces as well as padding.
 CKLayoutFlexibleSpace Margins as well as margins of the previous/next layoutbox are ignored to get the flexible space fill the empty space to the maximum. This helps to align boxes correctly.
 */
@interface CKLayoutFlexibleSpace : CKLayoutBox
@end

//UIView

/**
 */
@interface UIView (Layout)<CKLayoutBoxProtocol>

/** Default value is YES. that means layoutting the view will automatically shrink or expand its size to fit the layouted content.
 Views managed by UIViewController or UITableViewCellContentView are forced to NO as the controller, container controller or table view cell controller is responsible to manage it's view frame.
 */
@property(nonatomic,assign) BOOL sizeToFitLayoutBoxes;

@end


//UIButton

/**
 */
@interface UIButton (Layout)

/** This attribute specify whether the button can be stretched horizontally to fill a bigger space. By default, the prefered size of a button uses sizeToFit in order to get the optimal size of a button.
 You can either use Minimum/maximum/fixed size on a button with flexibleWidth = NO to manage its size manually, or set flexibleWidth = YES to make it fill the space as much as possible.
 */
@property(nonatomic,assign) BOOL flexibleWidth;


/** This attribute specify whether the button can be stretched vertically to fill a bigger space. By default, the prefered size of a button uses sizeToFit in order to get the optimal size of a button.
 You can either use Minimum/maximum/fixed size on a button with flexibleWidth = NO to manage its size manually, or set flexibleWidth = YES to make it fill the space as much as possible.
 */
@property(nonatomic,assign) BOOL flexibleHeight;

/** This attribute specify whether the button can be stretched vertically and horizontally to fill a bigger space. By default, the prefered size of a button uses sizeToFit in order to get the optimal size of a button.
 You can either use Minimum/maximum/fixed size on a button with flexibleWidth = NO to manage its size manually, or set flexibleWidth = YES to make it fill the space as much as possible.
 */
@property(nonatomic,assign) BOOL flexibleSize;

@end