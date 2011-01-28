//
//  CKGridView.m
//  CloudKit
//
//  Created by Olivier Collet on 11-01-19.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKGridView.h"
#import "CKCoreGraphicsAdditions.h"
#import "CKVersion.h"
#import "CKConstants.h"
#import <QuartzCore/QuartzCore.h>

#define DEFAULT_DRAGGEDVIEW_SCALE 2

@interface CKGridView ()

@property (nonatomic, retain) NSMutableArray *views;
@property (nonatomic, retain) UIView *draggedView;
@property (nonatomic, retain) NSIndexPath *fromIndexPath;
@property (nonatomic, retain) NSIndexPath *toIndexPath;

@property (nonatomic, readonly) CGFloat columnWidth;
@property (nonatomic, readonly) CGFloat rowHeight;

- (NSInteger)indexForIndexPath:(NSIndexPath *)indexPath;
- (CGPoint)pointForIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForPoint:(CGPoint)point;
- (UIView *)viewAtPoint:(CGPoint)point;
- (void)deleteDraggedView;

@end


@implementation CKGridView

@synthesize dataSource = _dataSource;
@synthesize delegate = _delegate;
@synthesize editing = _editing;
@synthesize minimumPressDuration = _minimumPressDuration;
@synthesize views = _views;
@synthesize draggedView = _draggedView;
@synthesize draggedViewScale = _draggedViewScale;
@synthesize fromIndexPath = _fromIndexPath;
@synthesize toIndexPath = _toIndexPath;
@synthesize rows = _rows;
@synthesize columns = _columns;

- (void)postInit {
	self.views = [NSMutableArray array];
	_minimumPressDuration = 0;
	self.editing = NO;
	self.draggedViewScale = DEFAULT_DRAGGEDVIEW_SCALE;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self postInit];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		[self postInit];
	}
	return self;
}

- (void)dealloc {
	self.views = nil;
	self.draggedView = nil;
	self.fromIndexPath = nil;
	self.toIndexPath = nil;
    [super dealloc];
}

-(void)layoutSubviews{
	[super layoutSubviews];
	
	if ([self.views count] == 0) {
		[self reloadData];
	}
	
	if (_needsLayout) {
		int index = 0;
		for (int row=0 ; row<_rows ; row++) {
			for (int column=0 ; column<_columns ; ++column, ++index) {
				NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row column:column];
				UIView *view = [self.views objectAtIndex:index];
				if (view && [view isKindOfClass:[UIView class]]) {
					CGPoint position = [self pointForIndexPath:indexPath];
					view.frame = CGRectIntegral(CGRectMake(position.x, position.y, self.columnWidth, self.rowHeight));
					view.autoresizingMask = CKUIViewAutoresizingFlexibleAll;
				}
			}
		}
		_needsLayout = NO;
	}
}

// 

- (BOOL)supportsGestureRecognizers {
	NSString *osVersion = CKOSVersion();
	return ([osVersion hasPrefix:@"4"] || [osVersion hasPrefix:@"3.2"]);
}

//

- (void)setEditing:(BOOL)edit {
	_editing = edit;
	if ([self supportsGestureRecognizers] && _editing) {
		UILongPressGestureRecognizer *gesture = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)] autorelease];
		gesture.minimumPressDuration = _minimumPressDuration;
		[self addGestureRecognizer:gesture];		
	}
	else {
		for (UIGestureRecognizer *recognizer in self.gestureRecognizers) {
			if ([recognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
				[self removeGestureRecognizer:recognizer];
			}
		}
	}
}

//

- (void)setMinimumPressDuration:(CFTimeInterval)duration {
	_minimumPressDuration = duration;
	for (UIGestureRecognizer *recognizer in self.gestureRecognizers) {
		if ([recognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
			[(UILongPressGestureRecognizer *)recognizer setMinimumPressDuration:_minimumPressDuration];
		}
	}
}

//

- (void)clear {
	for (id view in self.views) {
		if ([view isKindOfClass:[UIView class]]) {
			[(UIView *)view removeFromSuperview];
		}
	}
	self.views = [NSMutableArray array];
}

- (void)reloadData {
	[self clear];
	_rows = [self.dataSource numberOfRowsForGridView:self];
	_columns = [self.dataSource numberOfColumnsForGridView:self];

	for (int row=0 ; row<_rows ; row++) {
		for (int column=0 ; column<_columns ; column++) {
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row column:column];
			UIView *view = [self.dataSource gridView:self viewAtIndexPath:indexPath];
			if (view) {
				if ([view isDescendantOfView:self] == NO) [self addSubview:view];
			}
			if ([self.views containsObject:view] == NO) 
				[self.views insertObject:(view ? (id)view : (id)[NSNull null]) atIndex:[self indexForIndexPath:indexPath]];
		}
	}
	_needsLayout = YES;
	[self setNeedsLayout];
}

- (NSUInteger)viewCount {
	NSUInteger count = 0;
	for(id object in self.views){
		if([object isKindOfClass:[UIView class]])
			++count;
	}
	return count;
}

// Conversion methods

- (NSInteger)indexForIndexPath:(NSIndexPath *)indexPath {
	return (indexPath.row * _columns) + indexPath.column;
}
- (NSIndexPath *)indexPathForIndex:(NSInteger)index {
	int r = index / _columns;
	int c = index - r * _columns;
	NSAssert(r>= 0 && r<_rows && c>=0 && c<_columns,@"invalid row column");
	return [NSIndexPath indexPathForRow:r column:c];
}

- (UIView *)viewAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger index = [self indexForIndexPath:indexPath];
	id view = (index < self.views.count) ? [self.views objectAtIndex:index] : nil;
	if ([view isKindOfClass:[UIView class]]) return view;
	return nil;
}
- (NSIndexPath *)indexPathForView:(UIView *)view {
	NSUInteger index = [self.views indexOfObject:view];
	if (index == NSNotFound) return nil;
	return [self indexPathForIndex:index];
}

- (CGPoint)pointForIndexPath:(NSIndexPath *)indexPath {
	return CGPointMake((indexPath.column * self.columnWidth), (indexPath.row * self.rowHeight));
}
- (NSIndexPath *)indexPathForPoint:(CGPoint)point {
	NSInteger row = point.y / self.rowHeight;
	NSInteger column = point.x / self.columnWidth;
	return [NSIndexPath indexPathForRow:row column:column];	
}
- (UIView *)viewAtPoint:(CGPoint)point {
	return [self viewAtIndexPath:[self indexPathForPoint:point]];
}

// Dimensions

- (CGFloat)columnWidth { return self.bounds.size.width / _columns; }
- (CGFloat)rowHeight { return self.bounds.size.height / _rows; }

// Touch events handling

- (void)longPressBeganAtPoint:(CGPoint)point {
	NSIndexPath *indexPath = [self indexPathForPoint:point];

	if (self.dataSource && [(id)self.dataSource respondsToSelector:@selector(gridView:canEditViewAtIndexPath:)]) {
		if ([self.dataSource gridView:self canEditViewAtIndexPath:indexPath] == NO) return;
	}
	else return;

	if (self.draggedView == nil) {
		self.fromIndexPath = indexPath;
		UIView *touchedView = [self viewAtPoint:point];
		
		UIGraphicsBeginImageContext(touchedView.bounds.size);
		CGContextRef gc = UIGraphicsGetCurrentContext();
		[touchedView.layer renderInContext:gc];
		UIImage *tmpImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		self.draggedView = [[[UIImageView alloc] initWithImage:tmpImage] autorelease];
		self.draggedView.center = CGPointOffset(point, 0, -22);
		CGRect draggedViewRect = self.draggedView.bounds;
		draggedViewRect.size.width *= self.draggedViewScale;
		draggedViewRect.size.height *= self.draggedViewScale;
		[self addSubview:self.draggedView];
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.1];
		self.draggedView.bounds = draggedViewRect;
		[UIView commitAnimations];
	}
}

- (void)longPressMovedToPoint:(CGPoint)point {
	if (self.draggedView == nil) return;
	
	NSIndexPath *indexPath = [self indexPathForPoint:point];

	// Notify the delegate that the dragged view moved
	if (self.delegate && [(id)self.delegate respondsToSelector:@selector(gridView:canMoveViewAtIndexPath:toPoint:)]) {
		if ([self.delegate gridView:self canMoveViewAtIndexPath:self.fromIndexPath toPoint:point] == NO) return;
	}
	
	self.draggedView.center = CGPointOffset(point, 0, -22);
	
	UIView *fromView = [self viewAtIndexPath:self.fromIndexPath];
	if ((_animating == NO) && [self.fromIndexPath isEqual:indexPath] == NO) {
		UIView *toView = [self viewAtIndexPath:indexPath];
		if (toView && self.dataSource && [(id)self.dataSource respondsToSelector:@selector(gridView:canMoveViewFromIndexPath:toIndexPath:)]) {
			if ([self.dataSource gridView:self canMoveViewFromIndexPath:self.fromIndexPath toIndexPath:indexPath]) {
				self.toIndexPath = indexPath;
				_animating = YES;
				[UIView beginAnimations:nil context:nil];
				[UIView setAnimationDelegate:self];
				[UIView setAnimationDidStopSelector:@selector(swapAnimationDidStop:finished:context:)];
				CGRect destframe = toView.frame;
				toView.frame = fromView.frame;
				fromView.frame = destframe;
				[UIView commitAnimations];
			}
		}			
	}		
}

- (void)longPressEndedToPoint:(CGPoint)point {

	// Notify the delegate that the dragged view moved
	if (self.delegate && [(id)self.delegate respondsToSelector:@selector(gridView:didMoveViewAtIndexPath:toPoint:)]) {
		[self.delegate gridView:self didMoveViewAtIndexPath:self.fromIndexPath toPoint:point];
	}
	
	UIView *fromView = [self viewAtIndexPath:self.fromIndexPath];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(deleteDraggedView)];
	if (self.delegate &&
		[(id)self.delegate respondsToSelector:@selector(gridView:shouldMoveDraggedViewToOriginFromPoint:)] &&
		([self.delegate gridView:self shouldMoveDraggedViewToOriginFromPoint:point] == NO)) {
		self.draggedView.alpha = 0;
		self.draggedView.bounds = CGRectInset(self.draggedView.bounds, self.draggedView.bounds.size.width/2, self.draggedView.bounds.size.height/2);
	}
	else self.draggedView.frame = fromView.frame;
	[UIView commitAnimations];
}

// Gestures

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)sender {

	if (sender.state == UIGestureRecognizerStateBegan) {
		[self longPressBeganAtPoint:[sender locationInView:self]];
	}

	if (self.draggedView) {
		[self longPressMovedToPoint:[sender locationInView:self]];
		
		if (sender.state == UIGestureRecognizerStateEnded) {
			// NOTE: Retain self in case it is released in a delegate method
			// to avoid a crash while completing the animations
			[self retain];

			[self longPressEndedToPoint:[sender locationInView:self]];

			// NOTE: Release self following [self retain] above
			[self release];
		}
	}
}

- (void)swapAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	if (finished == NO) return;

	if (self.dataSource && [(id)self.dataSource respondsToSelector:@selector(gridView:didMoveViewFromIndexPath:toIndexPath:)]) {
		[self.dataSource gridView:self didMoveViewFromIndexPath:self.fromIndexPath toIndexPath:self.toIndexPath];
	}
	[self.views exchangeObjectAtIndex:[self indexForIndexPath:self.fromIndexPath] withObjectAtIndex:[self indexForIndexPath:self.toIndexPath]];
	self.fromIndexPath = self.toIndexPath;
	self.toIndexPath = nil;
	_animating = NO;
}

- (void)deleteDraggedView {
	[self.draggedView removeFromSuperview];
	self.draggedView = nil;
	self.fromIndexPath = nil;
}

// Gesture Compatibilty with iOS 3.x

- (void)recognizedLongPress:(UITouch *)touch {
	_longPressRecognized = YES;

	// NOTE: Hack to ensure a proper behavior in a UIScrollView
	if ([self.superview isKindOfClass:[UIScrollView class]]) {
		[(UIScrollView *)self.superview setCanCancelContentTouches:NO];
	}
	// --

	_longPressStartTime = touch.timestamp;
	[self longPressBeganAtPoint:[touch locationInView:self]];
}

- (void)finishedLongPress:(UITouch *)touch {
	_longPressRecognized = NO;

	// NOTE: Hack to ensure a proper behavior in a UIScrollView
	if ([self.superview isKindOfClass:[UIScrollView class]]) {
		[(UIScrollView *)self.superview setCanCancelContentTouches:YES];
	}
	// --
	
	_longPressStartTime = touch.timestamp;

	if ([self supportsGestureRecognizers] || (_editing == NO)) return;
	
	if (self.draggedView) {
		[self longPressEndedToPoint:[touch locationInView:self]];
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesBegan:touches withEvent:event];

	if ((_editing == NO) || [self supportsGestureRecognizers]) return;

	UITouch *touch = [touches anyObject];
    if (([touch view] != self) || ([touch tapCount] != 1)) return;
	_longPressStartTime = touch.timestamp;

	if (_minimumPressDuration == 0) {
		[self recognizedLongPress:touch];
	}
	else {
		[self performSelector:@selector(recognizedLongPress:) withObject:touch afterDelay:_minimumPressDuration];
	}

}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesMoved:touches withEvent:event];
	[NSObject cancelPreviousPerformRequestsWithTarget:self];

	if ((_editing == NO) || [self supportsGestureRecognizers]) return;

	UITouch *touch = [touches anyObject];
	if (_longPressRecognized == NO) {
		if ((touch.timestamp - _longPressStartTime) < _minimumPressDuration) return;
		[self recognizedLongPress:touch];
		return;
	}
	if (self.draggedView) {
		[self longPressMovedToPoint:[touch locationInView:self]];
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesEnded:touches withEvent:event];
	[NSObject cancelPreviousPerformRequestsWithTarget:self];

	if ((_editing == NO) || [self supportsGestureRecognizers]) return;

	[self finishedLongPress:[touches anyObject]];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesCancelled:touches withEvent:event];
	[NSObject cancelPreviousPerformRequestsWithTarget:self];

	if ((_editing == NO) || [self supportsGestureRecognizers]) return;

	[self finishedLongPress:[touches anyObject]];
}

@end
