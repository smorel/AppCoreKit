//
//  CKCarouselView.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-07.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKCarouselView.h"
#import "CKNSObject+Bindings.h"
#import <QuartzCore/QuartzCore.h>
#include <math.h>

double round(double x)
{
	double intpart;
	double fractpart = modf(x, &intpart);
	if (fractpart >= 0.5)
		return (intpart + 1);
	else if (fractpart >= -0.5)
		return intpart;
	else
		return (intpart - 1);
	return 0;
}

@interface CKCarouselViewLayer : CALayer{
	CGFloat _contentOffset;
}
@property (nonatomic,assign) CGFloat contentOffset;
@end

@implementation CKCarouselViewLayer
@dynamic contentOffset;

+ (BOOL)needsDisplayForKey:(NSString*)key {
    if ([key isEqualToString:@"contentOffset"]) {
        return YES;
    } else {
        return [super needsDisplayForKey:key];
    }
}

- (void)drawInContext:(CGContextRef)ctx
{
	[super drawInContext:ctx];
}

- (CGFloat)contentOffset{
	return _contentOffset;
}

- (void)setContentOffset:(CGFloat)offset{
	_contentOffset = offset;
}

@end


@interface CKCarouselView()
@property (nonatomic,retain) UIView* visibleHeaderView;
@property (nonatomic,retain) NSMutableDictionary* visibleViewsForIndexPaths;
@property (nonatomic,retain) NSMutableDictionary* reusableViews;
@property (nonatomic,assign) CGFloat contentOffset;

- (void)enqueuReusableView:(UIView*)view;
- (void)updateVisibleIndexPaths:(NSMutableArray*)visiblesIndexPaths indexPathToAdd:(NSMutableArray*)indexPathToAdd indexPathToRemove:(NSMutableArray*)indexPathToRemove;
- (void)layoutSubView:(UIView*)view atIndexPath:(NSIndexPath*)indexPath;
- (CGSize)sizeForViewAtIndexPath:(NSIndexPath*)indexPath;
- (BOOL)isVisibleAtIndexPath:(NSIndexPath*)indexPath;
- (CGFloat)convertToPageCoordinate:(CGFloat)x;

@end

@implementation CKCarouselView
@synthesize contentOffset = _contentOffset;
@synthesize visibleHeaderView = _visibleHeaderView;
@synthesize visibleViewsForIndexPaths = _visibleViewsForIndexPaths;
@synthesize numberOfPages = _numberOfPages;
@synthesize currentPage = _currentPage;
@synthesize dataSource = _dataSource;
@synthesize delegate = _delegate;
@synthesize reusableViews = _reusableViews;
@synthesize displayType = _displayType;

- (void)postInit{
	self.contentOffset = 0;
	self.numberOfPages = 0;
	self.currentPage = 0;
	self.visibleViewsForIndexPaths = [NSMutableDictionary dictionary];
	self.reusableViews = [NSMutableDictionary dictionary];
	self.displayType = CKCarouselViewDisplayTypeHorizontal;
	self.layer.delegate = self;
	
	//add gestures
    UITapGestureRecognizer* tapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)]autorelease];
    [self addGestureRecognizer:tapRecognizer];
    tapRecognizer.delegate = self;
	
	UIPanGestureRecognizer* panRecognizer = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)]autorelease];
	[self addGestureRecognizer:panRecognizer];
    panRecognizer.delegate = self;
}

+ (Class) layerClass {
    return [CKCarouselViewLayer class];
}

- (id)init{
	[super init];
	[self postInit];
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
	[super initWithCoder:aDecoder];
	[self postInit];
	return self;
}

- (id)initWithFrame:(CGRect)theFrame{
	[super initWithFrame:theFrame];
	[self postInit];
	return self;
}

- (void)dealloc{
	[_visibleHeaderView release];
	_visibleHeaderView = nil;
	[_visibleViewsForIndexPaths release];
	_visibleViewsForIndexPaths = nil;
	[_reusableViews release];
	_reusableViews = nil;
	_dataSource = nil;
	_delegate = nil;
	[super dealloc];
}

- (void)reloadData{
	NSInteger numberOfSections = 0;
	if(_dataSource && [_dataSource respondsToSelector:@selector(numberOfSectionsInCarouselView:)]){
		numberOfSections = [_dataSource numberOfSectionsInCarouselView:self];
	}
	
	NSInteger count = 0;
	for(NSInteger i=0;i<numberOfSections; ++i){
		if(_dataSource && [_dataSource respondsToSelector:@selector(carouselView:numberOfRowsInSection:)]){
			count += [_dataSource carouselView:self numberOfRowsInSection:i];
		}
	}
	self.numberOfPages = count;
	[self setNeedsLayout];
}

- (void)enqueuReusableView:(UIView*)view{
	id identifier = nil;
	if([view respondsToSelector:@selector(identifier)]){
		identifier = [view performSelector:@selector(identifier)];
	}
	if(identifier){
		NSMutableArray* reusable = [_reusableViews objectForKey:identifier];
		if(!reusable){
			reusable = [NSMutableArray array];
			[_reusableViews setObject:reusable forKey:identifier];
		}
		[reusable addObject:view];
	}
}

- (UIView*)dequeuReusableViewWithIdentifier:(id)identifier{
	NSMutableArray* reusable = [_reusableViews objectForKey:identifier];
	if(reusable && [reusable count] > 0){
		UIView* view = [reusable lastObject];
		[reusable removeLastObject];
		return view;
	}
	return nil;
}

- (void)layoutSubviews{
	NSMutableArray* toAdd = [NSMutableArray array];
	NSMutableArray* toRemove = [NSMutableArray array];
	NSMutableArray* visibles = [NSMutableArray array];
	[self updateVisibleIndexPaths:visibles indexPathToAdd:toAdd indexPathToRemove:toRemove];
	
	for(NSIndexPath* indexPath in toRemove){
		UIView* view = [_visibleViewsForIndexPaths objectForKey:indexPath];
		[view removeFromSuperview];
		[_visibleViewsForIndexPaths removeObjectForKey:indexPath];
		[self enqueuReusableView:view];
	}
	
	for(NSIndexPath* indexPath in toAdd){
		if(_dataSource && [_dataSource respondsToSelector:@selector(carouselView:viewForRowAtIndexPath:)]){
			UIView* view = [_dataSource carouselView:self viewForRowAtIndexPath:indexPath];
			if([view superview] != self){
				[view removeFromSuperview];
				[self addSubview:view];
				[_visibleViewsForIndexPaths setObject:view forKey:indexPath];
			}
		}
	}
	
	for(NSIndexPath* indexPath in [_visibleViewsForIndexPaths allKeys]){
		UIView* view = [_visibleViewsForIndexPaths objectForKey:indexPath];
		[self layoutSubView:view atIndexPath:indexPath];
	}
	
	//Same for HeaderView
}

- (NSIndexPath*)indexPathForPage:(NSInteger)page{
	NSInteger numberOfSections = 0;
	if(_dataSource && [_dataSource respondsToSelector:@selector(numberOfSectionsInCarouselView:)]){
		numberOfSections = [_dataSource numberOfSectionsInCarouselView:self];
	}
	
	NSInteger count = 0;
	for(NSInteger i=0;i<numberOfSections; ++i){
		if(_dataSource && [_dataSource respondsToSelector:@selector(carouselView:numberOfRowsInSection:)]){
			NSInteger rowCount = [_dataSource carouselView:self numberOfRowsInSection:i];
			count += rowCount;
			if(page < count){
				NSInteger offset = count - page;
				NSInteger row = rowCount - offset;
				return [NSIndexPath indexPathForRow:row inSection:i];
			}
		}
	}
	return nil;
}

- (NSInteger)pageForIndexPath:(NSIndexPath*)indexPath{
	NSInteger count = 0;
	for(int i=0;i<indexPath.section;++i){
		if(_dataSource && [_dataSource respondsToSelector:@selector(carouselView:numberOfRowsInSection:)]){
			count +=  [_dataSource carouselView:self numberOfRowsInSection:i];
		}
	}
	return count + indexPath.row;
}

- (CGSize)sizeForViewAtIndexPath:(NSIndexPath*)indexPath{
	CGSize carouselSize = self.bounds.size;
	CGFloat headerSize = 50;
	
	return CGSizeMake(carouselSize.width - 100,carouselSize.height - headerSize);
}

- (CGRect)rectForRowAtIndexPath:(NSIndexPath*)indexPath{
	CGFloat headerSize = 50;
	
	NSInteger page = [self pageForIndexPath:indexPath];
	CGFloat offset = (CGFloat)page - self.contentOffset;
	CGSize viewSize = [self sizeForViewAtIndexPath:indexPath];
	CGPoint viewTopLeft = CGPointMake(self.bounds.size.width / 2 + (offset * viewSize.width) - viewSize.width / 2,headerSize);
	
	return CGRectMake(viewTopLeft.x,viewTopLeft.y,viewSize.width,viewSize.height);
}

- (BOOL)isVisibleAtIndexPath:(NSIndexPath*)indexPath{
	switch(_displayType){
		case CKCarouselViewDisplayTypeHorizontal:{
			CGRect viewRect = [self rectForRowAtIndexPath:indexPath];
			if(viewRect.origin.x + viewRect.size.width < 0
			   || viewRect.origin.x > self.bounds.size.width){
				return NO;
			}
			return YES;
		}
	}
	return NO;
}

- (void)layoutSubView:(UIView*)view atIndexPath:(NSIndexPath*)indexPath{
	CGRect frameForRow = [self rectForRowAtIndexPath:indexPath];
	view.frame = frameForRow;
	
	//DO Layout _contentOffset
	//set frame, bounds, center, scale and layer transforms
}

- (void)updateVisibleIndexPaths:(NSMutableArray*)visiblesIndexPaths indexPathToAdd:(NSMutableArray*)indexPathToAdd indexPathToRemove:(NSMutableArray*)indexPathToRemove{
	[visiblesIndexPaths removeAllObjects];
	[indexPathToAdd removeAllObjects];
	[indexPathToRemove removeAllObjects];
	
	BOOL finished = NO;
	for(NSInteger i = (NSInteger)self.contentOffset; i >=0 && !finished; --i){
		NSIndexPath* indexPath = [self indexPathForPage:i];
		if([self isVisibleAtIndexPath:indexPath]){
			if([_visibleViewsForIndexPaths objectForKey:indexPath] == nil){
				[indexPathToAdd addObject:indexPath];
			}
			[visiblesIndexPaths addObject:indexPath];
		}
		else{
			finished = YES;
		}
	}
	finished = NO;
	for(NSInteger i = (NSInteger)self.contentOffset +1; i < _numberOfPages && !finished; ++i){
		NSIndexPath* indexPath = [self indexPathForPage:i];
		if([self isVisibleAtIndexPath:indexPath]){
			if([_visibleViewsForIndexPaths objectForKey:indexPath] == nil){
				[indexPathToAdd addObject:indexPath];
			}
			[visiblesIndexPaths addObject:indexPath];
		}
		else{
			finished = YES;
		}
	}
	
	NSArray* allKeys = [_visibleViewsForIndexPaths allKeys];
	for(NSIndexPath* indexPath in allKeys){
		if(![visiblesIndexPaths containsObject:indexPath]){
			[indexPathToRemove addObject:indexPath];
		}
	}
}


#pragma mark contentOffset
- (void)updateOffset:(CGFloat)offset{
	if(_contentOffset != offset){
		self.contentOffset = offset;
		self.currentPage = MAX(0,MIN(_numberOfPages-1,(NSInteger)round(self.contentOffset)));
		NSLog(@"contentOffset: %f currentPage=%d", _contentOffset,_currentPage);
		[self setNeedsLayout];
		[self setNeedsDisplay];
	}
}

-(void)drawLayer:(CALayer*)l inContext:(CGContextRef)context{
	CKCarouselViewLayer* carouselLayer = (CKCarouselViewLayer*)l;
	[self updateOffset:carouselLayer.contentOffset];
}

- (void)setContentOffset:(CGFloat)offset animated:(BOOL)animated{
	CKCarouselViewLayer* carouselLayer = (CKCarouselViewLayer*)[self.layer presentationLayer];
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"contentOffset"];
	animation.duration = 0.25;
	if(animated){
		animation.fromValue = [NSNumber numberWithFloat: _contentOffset ];
	}
	else{
		animation.fromValue = [NSNumber numberWithFloat: offset ];
	}
	animation.toValue = [NSNumber numberWithFloat: offset ];
	animation.removedOnCompletion = NO;
	animation.fillMode = kCAFillModeForwards;
	[carouselLayer addAnimation:animation forKey:@"contentOffset"];
}

#pragma mark gestures

- (CGFloat)convertToPageCoordinate:(CGFloat)x{
	CGSize viewSize = [self sizeForViewAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	return x / viewSize.width;
}

- (IBAction)takeLeftSwipeRecognitionEnabledFrom:(UISegmentedControl *)aSegmentedControl {
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

- (void)handleTapFrom:(UITapGestureRecognizer *)recognizer {
    
    /*CGPoint location = [recognizer locationInView:self.view];
    [self showImageWithText:@"tap" atPoint:location];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    imageView.alpha = 0.0;
    [UIView commitAnimations];*/
}

- (void)handlePanFrom:(UIPanGestureRecognizer *)recognizer {
	CGPoint location = [recognizer locationInView:self];
	CGPoint translation = [recognizer translationInView:self];
	CGPoint velocity = [recognizer velocityInView:self];
	
	CGFloat pageOffset = [self convertToPageCoordinate:translation.x];
	CGFloat pageVelocity = [self convertToPageCoordinate:velocity.x];
	
	if(recognizer.state == UIGestureRecognizerStateBegan){
		_contentOffsetWhenStartPanning = _contentOffset;
	}
	else if(recognizer.state != UIGestureRecognizerStateEnded){
		[self setContentOffset:_contentOffsetWhenStartPanning - pageOffset animated:NO];
	}
	else{
		CGFloat offset = round(_contentOffsetWhenStartPanning);
		if((offset <= 0 && pageVelocity >= 0)|| (offset > _numberOfPages-1 && pageVelocity <= 0) || fabs(pageVelocity) <= 1){
			[self setContentOffset:offset animated:YES];
		}
		else if(fabs(pageVelocity) > 1){
			if(velocity.x < 0)
				++offset;
			else{
				--offset;
			}
			
			offset = MAX(0,MIN(_numberOfPages-1,offset));
			
			CKCarouselViewLayer* carouselLayer = (CKCarouselViewLayer*)[self.layer presentationLayer];
			
			CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"contentOffset"];
			animation.calculationMode = kCAAnimationPaced;
			animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
			
			NSMutableArray* values = [NSMutableArray array];
			[values addObject: [NSNumber numberWithFloat:_contentOffset]];
			[values addObject: [NSNumber numberWithFloat:offset - pageVelocity / 100]];
			[values addObject: [NSNumber numberWithFloat:offset]];
			animation.values = values;
			animation.removedOnCompletion = NO;
			animation.fillMode = kCAFillModeForwards;
			[carouselLayer addAnimation:animation forKey:@"contentOffset"];			
		}
	}
	
	BOOL ended = (recognizer.state == UIGestureRecognizerStateEnded);
	
	NSLog(@"location=%f offset=%f velocity=%f pageOffset=%f pageVelocity=%f ended=%@",location.x,translation.x,velocity.x,pageOffset,pageVelocity,ended ? @"YES" : @"NO");
}

@end
