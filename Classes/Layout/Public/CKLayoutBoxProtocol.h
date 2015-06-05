//
//  CKLayoutBox.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2012 WhereCloud Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKArrayCollection.h"

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
@property(nonatomic,retain) CKArrayCollection* layoutBoxes;

/**
 */
- (void)addLayoutBox:(id<CKLayoutBoxProtocol>)box;

/**
 */
- (void)insertLayoutBox:(id<CKLayoutBoxProtocol>)box atIndex:(NSInteger)index;

/**
 */
- (void)removeLayoutBox:(id<CKLayoutBoxProtocol>)box;

/**
 */
- (void)removeAllLayoutBoxes;

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
@property(nonatomic,assign) BOOL flexibleSize;
/**
 */
@property(nonatomic,assign) BOOL flexibleWidth;

/**
 */
@property(nonatomic,assign) BOOL flexibleHeight;

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

/** The UIView containing the current layout box.
 */
@property(nonatomic,assign,readonly) UIViewController* containerViewController;

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
- (CGSize)preferredSizeConstraintToSize:(CGSize)size;

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

