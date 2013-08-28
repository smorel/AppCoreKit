//
//  CKSegmentedControl.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import <UIKit/UIKit.h>

/* This is a sample of how to customize style for CKSegmentedControl in stylesheets :
 
"CKSegmentedControl" : {
    "CKSegmentedControlButton[position=CKSegmentedControlButtonPositionFirst]" : {
        "defaultBackgroundImage" : ["navbar-back","13 0"],
        "highlightedBackgroundImage" : ["navbar-back-press","13 0"],
        "selectedBackgroundImage" : ["navbar-back-press","13 0"],
        "contentEdgeInsets" : "3 30 3 10"
    },
    "CKSegmentedControlButton[position=CKSegmentedControlButtonPositionLast]" : {
        "defaultBackgroundImage" : "navbar-button-blue",
        "highlightedBackgroundImage" : "navbar-button-blue-press",
        "selectedBackgroundImage" : "navbar-button-blue-press"
    },
    "CKSegmentedControlButton[position=CKSegmentedControlButtonPositionMiddle]" : {
        "backgroundColor" : "yellowColor"
    },
    "CKSegmentedControlButton[position=CKSegmentedControlButtonPositionAlone]" : {
        "backgroundColor" : "redColor"
    }
}
*/
 
/**
 */
typedef enum CKSegmentedControlButtonPosition{
    CKSegmentedControlButtonPositionFirst  = 1 << 0,
    CKSegmentedControlButtonPositionMiddle = 1 << 1,
    CKSegmentedControlButtonPositionLast   = 1 << 2,
    CKSegmentedControlButtonPositionAlone  = 1 << 3
}CKSegmentedControlButtonPosition;

/**
 */
@interface CKSegmentedControlButton : UIButton 

///-----------------------------------
/// @name Accessing the segemented control button status
///-----------------------------------

/**
 */
@property(nonatomic,assign,readonly)CKSegmentedControlButtonPosition position;

@end


/**
 */
@interface CKSegmentedControl : UIControl 

///-----------------------------------
/// @name Initializing a Segmented Control
///-----------------------------------

/** An array of NSString objects (for segment titles) or UIImage objects (for segment images).
 */
- (id)initWithItems:(NSArray *)items;

///-----------------------------------
/// @name Managing Segment Content
///-----------------------------------

/**
 */
- (UIImage *)imageForSegmentAtIndex:(NSUInteger)segment;

/**
 */
- (void)setImage:(UIImage *)image forSegmentAtIndex:(NSUInteger)segment;

/**
 */
- (NSString *)titleForSegmentAtIndex:(NSUInteger)segment;

/**
 */
- (void)setTitle:(NSString *)title forSegmentAtIndex:(NSUInteger)segment;

///-----------------------------------
/// @name Managing Segments
///-----------------------------------

/**
 */
@property(nonatomic,readonly)NSInteger numberOfSegments;

/**
 */
@property(nonatomic,assign)NSInteger selectedSegmentIndex;

/**
 */
- (CKSegmentedControlButton*)insertSegmentWithImage:(UIImage *)image atIndex:(NSUInteger)segment animated:(BOOL)animated;

/**
 */
- (CKSegmentedControlButton*)insertSegmentWithTitle:(NSString *)title atIndex:(NSUInteger)segment animated:(BOOL)animated;

/**
 */
- (void)removeAllSegments;

/**
 */
- (void)removeSegmentAtIndex:(NSUInteger)segment animated:(BOOL)animated;

/**
 */
- (CKSegmentedControlButton*)segmentAtIndex:(NSInteger)index;

/**
 */
- (void)setSelectedSegment:(CKSegmentedControlButton*)segment;

/**
 */
- (CKSegmentedControlButton*)insertSegmentWithImage:(UIImage *)image atIndex:(NSUInteger)segment animated:(BOOL)animated action:(void(^)())action;

/**
 */
- (CKSegmentedControlButton*)insertSegmentWithTitle:(NSString *)title atIndex:(NSUInteger)segment animated:(BOOL)animated action:(void(^)())action;

/**
 */
- (CKSegmentedControlButton*)insertSegmentWithTitle:(NSString *)title image:(UIImage*)image atIndex:(NSUInteger)segment animated:(BOOL)animated action:(void(^)())action;

/**
 */
- (CKSegmentedControlButton*)insertSegmentWithImage:(UIImage *)image atIndex:(NSUInteger)segment animated:(BOOL)animated target:(id)target action:(SEL)action;

/**
 */
- (CKSegmentedControlButton*)insertSegmentWithTitle:(NSString *)title atIndex:(NSUInteger)segment animated:(BOOL)animated target:(id)target action:(SEL)action;

/**
 */
- (CKSegmentedControlButton*)insertSegmentWithTitle:(NSString *)title image:(UIImage*)image atIndex:(NSUInteger)segment animated:(BOOL)animated target:(id)target action:(SEL)action;


///-----------------------------------
/// @name Managing Segment Behavior and Appearance
///-----------------------------------

/**
 */
@property(nonatomic,assign)BOOL momentary;

/** Default value is YES.
 */
@property(nonatomic,assign)BOOL autoResizeToFitContent;

/**
 */
- (BOOL)isEnabledForSegmentAtIndex:(NSUInteger)segment;

/**
 */
- (void)setEnabled:(BOOL)enabled forSegmentAtIndex:(NSUInteger)segment;

/**
 */
- (CGSize)contentOffsetForSegmentAtIndex:(NSUInteger)segment;

/**
 */
- (void)setContentOffset:(CGSize)offset forSegmentAtIndex:(NSUInteger)segment;

/**
 */
- (CGFloat)widthForSegmentAtIndex:(NSUInteger)segment;

/**
 */
- (void)setWidth:(CGFloat)width forSegmentAtIndex:(NSUInteger)segment;

@end
