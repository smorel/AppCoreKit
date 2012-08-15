//
//  CKLayoutBox.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2012 WhereCloud Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

//#define LAYOUT_DEBUG_ENABLED

/**
 */
@protocol CKLayoutBoxProtocol

/**
 */
@property(nonatomic,assign) CGRect frame;

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

/**
 */
@property(nonatomic,assign) NSObject<CKLayoutBoxProtocol>* containerLayoutBox;

/**
 */
@property(nonatomic,assign,readonly) UIView* containerLayoutView;

/**
 */
@property(nonatomic,retain) NSArray* layoutBoxes;

/** This method computes the prefered size for the layout box including padding.
 */
- (CGSize)preferedSizeConstraintToSize:(CGSize)size;

/** This method performs the layout on the box and its sub boxes
 */
- (void)performLayoutWithFrame:(CGRect)frame;

/**
 */
@property(nonatomic,assign,readwrite) CGSize lastComputedSize;

/**
 */
@property(nonatomic,assign,readwrite) CGSize lastPreferedSize;

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


/**
 */
@interface CKLayoutBox : NSObject<CKLayoutBoxProtocol>

/** 
 */
@property(nonatomic,assign) CKLayoutVerticalAlignment verticalAlignment;

/**
 */
@property(nonatomic,assign) CKLayoutHorizontalAlignment horizontalAlignment;

@end



//CKVerticalBoxLayout

/**
 */
@interface CKVerticalBoxLayout : CKLayoutBox
@end

//CKHorizontalBoxLayout

/**
 */
@interface CKHorizontalBoxLayout : CKLayoutBox
@end

//CKLayoutFlexibleSpace

/**
 */
@interface CKLayoutFlexibleSpace : CKLayoutBox
@end

//UIView

/**
 */
@interface UIView (Layout)<CKLayoutBoxProtocol>
@end