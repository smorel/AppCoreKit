//
//  UIView+CKDragNDrop.h
//  AnimKit
//
//  Created by Sebastien Morel on 12-02-21.
//  Copyright (c) 2012 WhereCloud Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKBinding.h"
#import "CKBindingsManager.h"


typedef enum CKDragEvents{
    CKDragEventNone      = 0,
    CKDragEventBegin     = 1 << 1,
    CKDragEventDrop      = 1 << 2,
    CKDragEventCancelled = 1 << 3,
    CKDragEventDragging  = 1 << 4,
    CKDragEventAll = CKDragEventBegin | CKDragEventDrop | CKDragEventCancelled | CKDragEventDragging
}CKDragEvents;

@interface UIView (CKDragNDrop)
@property(nonatomic,retain)NSMutableDictionary* dragTargetActions;
@property(nonatomic,assign)BOOL draggable;
@property(nonatomic,assign,readonly)BOOL dragging;
@property(nonatomic,assign,readonly)CGPoint draggingOffset;

- (void)addTarget:(id)target action:(SEL)action forDragEvents:(CKDragEvents)dragEvents;
- (void)removeTarget:(id)target action:(SEL)action forDragEvents:(CKDragEvents)dragEvents;
- (void)sendActionsForDragEvents:(CKDragEvents)dragEvents hitStack:(NSArray*)hitStack;

@end


@interface UIView (CKDragNDropBindings)

- (void)bindDragEvent:(CKDragEvents)dragEvents withBlock:(void (^)(UIView* object, NSArray* hitTestViews, CKDragEvents event))block;
- (void)bindDragEvent:(CKDragEvents)dragEvents target:(id)target action:(SEL)selector;

@end