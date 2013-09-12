//
//  UIView+DragNDrop.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2012 WhereCloud Inc. All rights reserved.
//

#import "UIView+DragNDrop.h"
#import "NSObject+Invocation.h"
#import "CKRuntime.h"
#import "CKObject.h"
#import "CKPropertyExtendedAttributes+Attributes.h"
#import "CKBindingsManager.h"

#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

static char UIViewDragTargetActionsKey;
static char UIViewDragTypeKey;
static char UIViewDraggingOffsetKey;
static char UIViewDraggingBeginPointKey;
static char UIViewDraggingKey;
static char UIViewIndexInParentBeforeDraggingKey;

static BOOL UIViewSwizzlingDone = NO;
static BOOL UIControlSwizzlingDone = NO;


@interface UIView (CKDragNDrop_Private)
@property(nonatomic,assign)NSInteger indexInParentBeforeDragging;
@end

@implementation UIView (CKDragNDrop)
@dynamic dragTargetActions;
@dynamic dragType;
@dynamic dragging;
@dynamic draggingOffset;

+ (void)executeSwizzling{
    if(!UIViewSwizzlingDone){
        CKSwizzleSelector([UIView class],@selector(touchesBegan:withEvent:),     @selector(dnd_view_touchesBegan:withEvent:));
        CKSwizzleSelector([UIView class],@selector(touchesMoved:withEvent:),     @selector(dnd_view_touchesMoved:withEvent:));
        CKSwizzleSelector([UIView class],@selector(touchesEnded:withEvent:),     @selector(dnd_view_touchesEnded:withEvent:));
        CKSwizzleSelector([UIView class],@selector(touchesCancelled:withEvent:), @selector(dnd_view_touchesCancelled:withEvent:));
        UIViewSwizzlingDone = YES;
    }
}

- (void)dragTypeExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"CKDragType", 
                                               CKDragTypeNone,
                                               CKDragTypeMove,
                                               CKDragTypeGhost);
}

- (void)setDragTargetActions:(NSMutableDictionary*)dragTargetActions{
    objc_setAssociatedObject(self, 
                             &UIViewDragTargetActionsKey,
                             dragTargetActions,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary*)dragTargetActions{
    return objc_getAssociatedObject(self, &UIViewDragTargetActionsKey);
}

- (void)setDragType:(CKDragType)dragType{
    [self willChangeValueForKey:@"dragType"];
    [UIView executeSwizzling];
    objc_setAssociatedObject(self, 
                             &UIViewDragTypeKey,
                             [NSNumber numberWithInt:dragType],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"dragType"];
}

- (CKDragType)dragType{
    NSNumber* number = objc_getAssociatedObject(self, &UIViewDragTypeKey);
    if(!number)
        return NO;
    return (CKDragType)[number intValue];
}

- (void)setDragging:(BOOL)dragging{
    [self willChangeValueForKey:@"dragging"];
    [UIView executeSwizzling];
    objc_setAssociatedObject(self, 
                             &UIViewDraggingKey,
                             [NSNumber numberWithBool:dragging],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"dragging"];
}

- (BOOL)dragging{
    NSNumber* number = objc_getAssociatedObject(self, &UIViewDraggingKey);
    if(!number)
        return NO;
    return [number boolValue];
}

- (void)updateTransform{
    [CATransaction begin];
    [CATransaction setDisableActions: YES];
    
    self.transform = CGAffineTransformMakeTranslation(self.draggingOffset.x, self.draggingOffset.x);
    
    [CATransaction commit];
}

- (void)setDraggingOffset:(CGPoint)draggingOffset{
    [self willChangeValueForKey:@"draggingOffset"];
    [UIView executeSwizzling];
    objc_setAssociatedObject(self, 
                             &UIViewDraggingOffsetKey,
                             [NSValue valueWithCGPoint:draggingOffset],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self updateTransform];
    [self didChangeValueForKey:@"draggingOffset"];
}

- (CGPoint)draggingOffset{
    NSValue* value = objc_getAssociatedObject(self, &UIViewDraggingOffsetKey);
    if(!value)
        return CGPointMake(0, 0);
    return [value CGPointValue];
}

- (void)setDraggingBeginPoint:(CGPoint)p{
    objc_setAssociatedObject(self, 
                             &UIViewDraggingBeginPointKey,
                             [NSValue valueWithCGPoint:p],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGPoint)draggingBeginPoint{
    NSValue* value = objc_getAssociatedObject(self, &UIViewDraggingBeginPointKey);
    return [value CGPointValue];
}

- (NSArray*)dragEventsArrayFromControlEvents:(CKDragEvents)dragEvents{
    NSMutableArray* ar = [NSMutableArray array];
    if(dragEvents & CKDragEventBegin){
        [ar addObject:[NSNumber numberWithInt:CKDragEventBegin]];
    }
    if(dragEvents & CKDragEventDrop){
        [ar addObject:[NSNumber numberWithInt:CKDragEventDrop]];
    }
    if(dragEvents & CKDragEventCancelled){
        [ar addObject:[NSNumber numberWithInt:CKDragEventCancelled]];
    }
    if(dragEvents & CKDragEventDragging){
        [ar addObject:[NSNumber numberWithInt:CKDragEventDragging]];
    }
    return ar;
}

- (void)addTarget:(id)target action:(SEL)action forDragEventsInArray:(NSArray*)controlEvents{
    if(!self.dragTargetActions){self.dragTargetActions = [NSMutableDictionary dictionaryWithCapacity:18];}
    for(NSNumber* event in controlEvents){
        NSMutableArray* array = [self.dragTargetActions objectForKey:event];
        if(!array){
            array = [NSMutableArray array];
            [self.dragTargetActions setObject:array forKey:event];
        }
        
        [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:target,@"target",[NSValue valueWithPointer:action],@"action", nil]];
    }
}

- (void)removeTarget:(id)target action:(SEL)action forDragEventsInArray:(NSArray*)controlEvents{
    for(NSNumber* event in controlEvents){
        NSMutableArray* array = [self.dragTargetActions objectForKey:event];
        if(array){
            NSMutableArray* toRemove = [NSMutableArray array];
            for(NSDictionary* dico in array){
                id t = [dico objectForKey:@"target"];
                if(t == target){
                    [toRemove addObject:dico];
                }
            }
            
            [array removeObjectsInArray:toRemove];
        }
    }
}

- (void)addTarget:(id)target action:(SEL)action forDragEvents:(CKDragEvents)dragEvents{
    [UIView executeSwizzling];
    NSArray* events = [self dragEventsArrayFromControlEvents:dragEvents];
    [self addTarget:target action:action forDragEventsInArray:events];
}

- (void)removeTarget:(id)target action:(SEL)action forDragEvents:(CKDragEvents)dragEvents{
    NSArray* events = [self dragEventsArrayFromControlEvents:dragEvents];
    [self removeTarget:target action:action forDragEventsInArray:events];
}

- (void)sendActionsForDragEvents:(CKDragEvents)dragEvents touch:(UITouch*)touch{
    NSArray* events = [self dragEventsArrayFromControlEvents:dragEvents];
    for(NSNumber* event in events){
        NSMutableArray* array = [self.dragTargetActions objectForKey:event];
        for(NSDictionary* dico in array){
            id target = [dico objectForKey:@"target"];
            SEL action = (SEL)[[dico objectForKey:@"action"]pointerValue];
            if([target respondsToSelector:action]){
                [target performSelector:action withObjects:[NSArray arrayWithObjects:self,touch,event,nil]]; 
            }
        }
    }
}

- (void)hitTest:(CGPoint)point inView:(UIView*)view stack:(NSMutableArray*)stack{
    if(view.hidden == YES){
        return;
    }
 
    if([view superview]){
        point = [view convertPoint:point fromView:[view superview]];
    }
    
    BOOL forgetSubViews = NO;
    if([view pointInside:point withEvent:nil]){
        [stack insertObject:view atIndex:0];
    }
    /*else if(view.clipsToBounds){
        forgetSubViews = YES;
    }*/
    
    if(!forgetSubViews){
        for(UIView* v in view.subviews){
            [self hitTest:point inView:v stack:stack];
        }
    }
}


- (NSMutableArray*)hitTest:(CGPoint)point inWindow:(UIWindow*)window{
    NSMutableArray* ar = [NSMutableArray array];
    for(UIView* view in [window subviews]){
        [self hitTest:point inView:view stack:ar];
    }
    return ar;
}

- (NSArray*)hitStackUnderTouch:(UITouch *)touch{
    CGPoint p = [touch locationInView:self];
    CGPoint windowPoint = [self convertPoint:p toView:touch.window];
    
    return [self hitTest:windowPoint inWindow:touch.window];
}

- (void)startDragging{
    NSInteger index = [[[self superview]subviews]indexOfObjectIdenticalTo:self];
    self.indexInParentBeforeDragging = index;
    
    [[self superview]bringSubviewToFront:self];
    
    self.dragging = YES;
}

- (void)endDragging{
    [[self superview]insertSubview:self atIndex:self.indexInParentBeforeDragging];
    self.indexInParentBeforeDragging = NSNotFound;
    self.dragging = NO;
}

- (void)handle_dnd_view_touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if(self.dragType != CKDragTypeNone){
        UITouch* touch = [touches anyObject];
        CGPoint p = [touch locationInView:self];
        
        p = [self convertPoint:p toView:[self superview]];
        [self setDraggingBeginPoint:p];
        
        [self sendActionsForDragEvents:CKDragEventBegin touch:touch];
        [self startDragging];
    }
}

- (void)handle_dnd_view_touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if(self.dragType != CKDragTypeNone){
        UITouch* touch = [touches anyObject];
        CGPoint p = [touch locationInView:self];
        p = [self convertPoint:p toView:[self superview]];
        
        CGPoint begin = [self draggingBeginPoint];
        
        CGPoint newDraggingOffset = CGPointMake((p.x - begin.x), (p.y - begin.y));
        [self setDraggingOffset:newDraggingOffset];
        
        [self sendActionsForDragEvents:CKDragEventDragging touch:touch];
    }
}

- (void)handle_dnd_view_touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
     if(self.dragType != CKDragTypeNone){
        [self sendActionsForDragEvents:CKDragEventDrop touch:[touches anyObject]];
        [self setDraggingOffset:CGPointMake(0, 0)];
        
        [self endDragging];
    }
}

- (void)handle_dnd_view_touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
     if(self.dragType != CKDragTypeNone){
        [self sendActionsForDragEvents:CKDragEventCancelled touch:[touches anyObject]];
        [self setDraggingOffset:CGPointMake(0, 0)];
        
        [self endDragging];
    }
}


- (void)dnd_view_touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self handle_dnd_view_touchesBegan:touches withEvent:event];
}

- (void)dnd_view_touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [self handle_dnd_view_touchesMoved:touches withEvent:event];
}

- (void)dnd_view_touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self handle_dnd_view_touchesEnded:touches withEvent:event];
}

- (void)dnd_view_touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [self handle_dnd_view_touchesCancelled:touches withEvent:event];
}

@end

@implementation UIView (CKDragNDrop_Private)
@dynamic indexInParentBeforeDragging;

- (void)setIndexInParentBeforeDragging:(NSInteger)index{
    [self willChangeValueForKey:@"indexInParentBeforeDragging"];
    [UIView executeSwizzling];
    objc_setAssociatedObject(self, 
                             &UIViewIndexInParentBeforeDraggingKey,
                             [NSNumber numberWithInteger:index],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"indexInParentBeforeDragging"];
}

- (NSInteger)indexInParentBeforeDragging{
    NSNumber* number = objc_getAssociatedObject(self, &UIViewIndexInParentBeforeDraggingKey);
    if(!number)
        return NO;
    return [number intValue];
}

@end


@interface UIControl (CKDragNDrop)
@end

@implementation UIControl (CKDragNDrop)

+ (void)executeSwizzling{
    if(!UIControlSwizzlingDone){
        CKSwizzleSelector([UIControl class],@selector(touchesBegan:withEvent:),     @selector(dnd_ctrl_touchesBegan:withEvent:));
        CKSwizzleSelector([UIControl class],@selector(touchesMoved:withEvent:),     @selector(dnd_ctrl_touchesMoved:withEvent:));
        CKSwizzleSelector([UIControl class],@selector(touchesEnded:withEvent:),     @selector(dnd_ctrl_touchesEnded:withEvent:));
        CKSwizzleSelector([UIControl class],@selector(touchesCancelled:withEvent:), @selector(dnd_ctrl_touchesCancelled:withEvent:));
        UIControlSwizzlingDone = YES;
    }
}

- (void)setDragType:(CKDragType)dragType{
    [UIControl executeSwizzling];
    [super setDragType:dragType];
}

- (void)addTarget:(id)target action:(SEL)action forDragEvents:(CKDragEvents)dragEvents{
    [UIControl executeSwizzling];
    [super addTarget:target action:action forDragEvents:dragEvents];
}

- (void)dnd_ctrl_touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self handle_dnd_view_touchesBegan:touches withEvent:event];
    [self dnd_ctrl_touchesBegan:touches withEvent:event];
}

- (void)dnd_ctrl_touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [self handle_dnd_view_touchesMoved:touches withEvent:event];
    [self dnd_ctrl_touchesMoved:touches withEvent:event];
}

- (void)dnd_ctrl_touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self handle_dnd_view_touchesEnded:touches withEvent:event];
    [self dnd_ctrl_touchesEnded:touches withEvent:event];
}

- (void)dnd_ctrl_touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [self handle_dnd_view_touchesCancelled:touches withEvent:event];
    [self dnd_ctrl_touchesCancelled:touches withEvent:event];
}

@end


//BINDING

typedef void(^UIViewDragDropBlock)(UIView* view, UITouch* touch, CKDragEvents event);

/**
 */
@interface UIViewDragDropBlockBinder : CKBinding{
	UIViewDragDropBlock block;
	CKWeakRef* targetRef;
	SEL selector;
	
	CKWeakRef* viewRef;
	BOOL binded;
}

@property (nonatomic, assign) CKDragEvents dragEvents;
@property (nonatomic, copy) UIViewDragDropBlock block;
@property (nonatomic, assign) SEL selector;

- (void)setTarget:(id)instance;
- (void)setView:(UIView*)view;

@end

@interface UIViewDragDropBlockBinder ()
@property (nonatomic, retain) CKWeakRef *viewRef;
@property (nonatomic, retain) CKWeakRef* targetRef;
- (void)unbindInstance:(id)instance;
@end


@implementation UIViewDragDropBlockBinder
@synthesize dragEvents;
@synthesize block;
@synthesize viewRef;
@synthesize targetRef;
@synthesize selector;

#pragma mark Initialization

-(id)init{
	if (self = [super init]) {
      	binded = NO;
        self.targetRef = [CKWeakRef weakRefWithObject:nil target:self action:@selector(releaseTarget:)];
        self.viewRef = [CKWeakRef weakRefWithObject:nil target:self action:@selector(releaseView:)];
    }
	return self;
}

-(void)dealloc{
	[self unbind];
	[self reset];
	self.viewRef = nil;
	self.targetRef = nil;
	[super dealloc];
}

- (NSString*)description{
	return [NSString stringWithFormat:@"<UIViewDragDropBlockBinder : %p>{\ncontrolRef = %@\ndragEvents = %ld}",
			self,viewRef ? viewRef.object : @"(null)",(long)dragEvents];
}

- (void)reset{
    [super reset];
	self.dragEvents = CKDragEventNone;
	self.block = nil;
	self.viewRef.object = nil;
	self.targetRef.object = nil;
	self.selector = nil;
}

- (id)releaseTarget:(CKWeakRef*)weakRef{
	[[CKBindingsManager defaultManager]unregister:self];
	return nil;
}

- (void)setTarget:(id)instance{
	self.targetRef.object = instance;
}

- (id)releaseView:(CKWeakRef*)weakRef{
	[[CKBindingsManager defaultManager]unregister:self];
	return nil;
}

- (void)setView:(UIView*)view{
    self.viewRef.object = view;
}

-(void)executeDragEventForObject:(UIView*)view touch:(UITouch*)touch dragEvent:(NSNumber*)event{
    if(self.block){
		self.block(view,touch,[event intValue]);
	}
	else if(self.targetRef.object && [self.targetRef.object respondsToSelector:self.selector]){
        [self.targetRef.object performSelector:self.selector
                  withObjects:[NSArray arrayWithObjects:view,touch,event,nil]];
	}
	else{
		//CKAssert(NO,@"CKUIControlBlockBinder no action plugged");
	}
}

//Update data in model
-(void)controlChange{
    if(self.contextOptions & CKBindingsContextPerformOnMainThread){
        [self performSelectorOnMainThread:@selector(execute) withObject:nil waitUntilDone:(self.contextOptions & CKBindingsContextWaitUntilDone)];
    }
    else {
        [self performSelector:@selector(execute) onThread:[NSThread currentThread] withObject:nil waitUntilDone:(self.contextOptions & CKBindingsContextWaitUntilDone)];
    }
}

-(void)dragEventForObject:(UIView*)view touch:(UITouch*)touch dragEvent:(NSNumber*)eventNumber{
    if(self.contextOptions & CKBindingsContextPerformOnMainThread){
        [self  performSelectorOnMainThread:@selector(executeDragEventForObject:touch:dragEvent:) 
                                withObject:view withObject:touch withObject:eventNumber
                             waitUntilDone:(self.contextOptions & CKBindingsContextWaitUntilDone)];
    }
    else {
        [self performSelector:@selector(executeDragEventForObject:touch:dragEvent:) onThread:[NSThread currentThread] 
                  withObjects:[NSArray arrayWithObjects:view,touch,eventNumber,nil] 
                waitUntilDone:(self.contextOptions & CKBindingsContextWaitUntilDone)];
    }
}

#pragma mark Public API
- (void)bind{
	[self unbind];
    
	if(self.viewRef.object){
        [(UIView*)self.viewRef.object addTarget:self action:@selector(dragEventForObject:touch:dragEvent:) forDragEvents:self.dragEvents];
	}
	binded = YES;
}

-(void)unbind{
	[self unbindInstance:self.viewRef.object];
}

- (void)unbindInstance:(id)instance{
	if(binded){
		if(instance){
            [(UIView*)instance removeTarget:self action:@selector(dragEventForObject:touch:dragEvent:) forDragEvents:self.dragEvents];
		}
		binded = NO;
	}
}

@end



@interface NSObject ()
+ (id)currentBindingContext;
+ (CKBindingsContextOptions)currentBindingContextOptions;
@end


@implementation UIView (CKDragNDropBindings)

- (void)bindDragEvent:(CKDragEvents)dragEvents withBlock:(void (^)(UIView* view, UITouch* touch, CKDragEvents event))block{
    [NSObject validateCurrentBindingsContext];
    
	UIViewDragDropBlockBinder* binder = (UIViewDragDropBlockBinder*)[[CKBindingsManager defaultManager]newDequeuedReusableBindingWithClass:[UIViewDragDropBlockBinder class]];
    binder.contextOptions = [NSObject currentBindingContextOptions];
	binder.dragEvents = dragEvents;
	binder.block = block;
	[binder setView:self];
	[[CKBindingsManager defaultManager]bind:binder withContext:[NSObject currentBindingContext]];
	[binder release];
}

- (void)bindDragEvent:(CKDragEvents)dragEvents target:(id)target action:(SEL)selector{
    [NSObject validateCurrentBindingsContext];
    
	UIViewDragDropBlockBinder* binder = (UIViewDragDropBlockBinder*)[[CKBindingsManager defaultManager]newDequeuedReusableBindingWithClass:[UIViewDragDropBlockBinder class]];
    binder.contextOptions = [NSObject currentBindingContextOptions];
	binder.dragEvents = dragEvents;
	[binder setView:self];
	[binder setTarget:target];
	binder.selector = selector;
	[[CKBindingsManager defaultManager]bind:binder withContext:[NSObject currentBindingContext]];
	[binder release];
}

@end
