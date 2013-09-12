//
//  UIView+DragNDrop.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2012 WhereCloud Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKBinding.h"

/**
 */
typedef NS_ENUM(NSInteger, CKDragEvents){
    CKDragEventNone      = 0,
    CKDragEventBegin     = 1 << 1,
    CKDragEventDrop      = 1 << 2,
    CKDragEventCancelled = 1 << 3,
    CKDragEventDragging  = 1 << 4,
    CKDragEventAll = CKDragEventBegin | CKDragEventDrop | CKDragEventCancelled | CKDragEventDragging
};

/**
 */
typedef NS_ENUM(NSInteger, CKDragType){
    CKDragTypeNone,
    CKDragTypeMove,
    CKDragTypeGhost
};

/**
 */
@interface UIView (CKDragNDrop)

///-----------------------------------
/// @name Customizing drag'n'drop behaviour
///-----------------------------------

/** 
 */
@property(nonatomic,assign)CKDragType dragType;

///-----------------------------------
/// @name Accessing drag'n'drop status
///-----------------------------------

/** 
 */
@property(nonatomic,assign,readonly)BOOL dragging;

/** 
 */
@property(nonatomic,assign,readonly)CGPoint draggingOffset;

///-----------------------------------
/// @name Preparing and Sending Action Messages
///-----------------------------------

/** 
 */
@property(nonatomic,retain,readonly)NSMutableDictionary* dragTargetActions;

/** 
 */
- (void)addTarget:(id)target action:(SEL)action forDragEvents:(CKDragEvents)dragEvents;

/** 
 */
- (void)removeTarget:(id)target action:(SEL)action forDragEvents:(CKDragEvents)dragEvents;

/** 
 */
- (void)sendActionsForDragEvents:(CKDragEvents)dragEvents touch:(UITouch*)touch;

///-----------------------------------
/// @name Accessing view hierarchy while drag'n'dropping
///-----------------------------------

/** 
 */
- (NSArray*)hitStackUnderTouch:(UITouch *)touch;


//Private interface : This method will get called each time the draggingOffset is getting changed.
//By default, this sets the view's transform to an affine transform with draggingOffset as translation.
- (void)updateTransform;

@end


/** 
 */
@interface UIView (CKDragNDropBindings)

///-----------------------------------
/// @name Bindings
///-----------------------------------

/** 
 */
- (void)bindDragEvent:(CKDragEvents)dragEvents withBlock:(void (^)(UIView* view, UITouch* touch, CKDragEvents event))block;

/** 
 */
- (void)bindDragEvent:(CKDragEvents)dragEvents target:(id)target action:(SEL)selector;

@end