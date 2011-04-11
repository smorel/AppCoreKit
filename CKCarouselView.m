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
@property (nonatomic,retain) UIView* headerViewToRemove;
@property (nonatomic,retain) NSMutableDictionary* visibleViewsForIndexPaths;
@property (nonatomic,retain) NSMutableDictionary* reusableViews;
@property (nonatomic,retain) NSMutableArray* rowSizes;
@property (nonatomic,assign) CGFloat contentOffset;

- (void)enqueueReusableView:(UIView*)view;
- (void)updateVisibleIndexPaths:(NSMutableArray*)visiblesIndexPaths indexPathToAdd:(NSMutableArray*)indexPathToAdd indexPathToRemove:(NSMutableArray*)indexPathToRemove;
- (void)layoutSubView:(UIView*)view atIndexPath:(NSIndexPath*)indexPath;
- (CGSize)sizeForViewAtIndexPath:(NSIndexPath*)indexPath;
- (BOOL)isVisibleAtIndexPath:(NSIndexPath*)indexPath;
- (CGFloat)convertToPageCoordinate:(CGFloat)initialOffset translation:(CGFloat)x;
- (CGSize)sizeForPage:(NSInteger)page;

@end

@implementation CKCarouselView
@synthesize contentOffset = _contentOffset;
@synthesize visibleHeaderView = _visibleHeaderView;
@synthesize headerViewToRemove = _headerViewToRemove;
@synthesize visibleViewsForIndexPaths = _visibleViewsForIndexPaths;
@synthesize numberOfPages = _numberOfPages;
@synthesize currentPage = _currentPage;
@synthesize dataSource = _dataSource;
@synthesize delegate = _delegate;
@synthesize reusableViews = _reusableViews;
@synthesize displayType = _displayType;
@synthesize currentSection = _currentSection;
@synthesize spacing = _spacing;
@synthesize rowSizes = _rowSizes;

- (void)postInit{
	self.contentOffset = 0;
	self.numberOfPages = 0;
	self.currentPage = 0;
	self.currentSection = 0;
	self.spacing = 0;
	self.visibleViewsForIndexPaths = [NSMutableDictionary dictionary];
	self.reusableViews = [NSMutableDictionary dictionary];
	self.rowSizes = [NSMutableArray array];
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
	[_rowSizes release];
	_rowSizes = nil;
	[_headerViewToRemove release];
	_headerViewToRemove = nil;
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
	
	[_rowSizes removeAllObjects];
	NSInteger count = 0;
	for(NSInteger i=0;i<numberOfSections; ++i){
		if(_dataSource && [_dataSource respondsToSelector:@selector(carouselView:numberOfRowsInSection:)]){
			count += [_dataSource carouselView:self numberOfRowsInSection:i];
			for(NSInteger j=0;j<count;++j){
				if(_delegate && [_delegate respondsToSelector:@selector(carouselView:sizeForViewAtIndexPath:)]){
					NSIndexPath* indexPath = [NSIndexPath indexPathForRow:j inSection:i];
					[_rowSizes addObject:[NSValue valueWithCGSize:[_delegate carouselView:self sizeForViewAtIndexPath:indexPath]]];
				}
			}
		}
	}
	
	if(_delegate && [_delegate respondsToSelector:@selector(carouselView:viewForHeaderInSection:)]){
		self.visibleHeaderView = [_delegate carouselView:self viewForHeaderInSection:0];
	}
	
	self.numberOfPages = count;
	self.currentPage = self.currentPage;
	[self updateViewsAnimated:NO];
}

- (void)enqueueReusableView:(UIView*)view{
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

- (UIView*)dequeueReusableViewWithIdentifier:(id)identifier{
	NSMutableArray* reusable = [_reusableViews objectForKey:identifier];
	if(reusable && [reusable count] > 0){
		UIView* view = [reusable lastObject];
		[reusable removeLastObject];
		return view;
	}
	return nil;
}


- (void)updateViewsAnimated:(BOOL)animated{
	if(_headerViewToRemove){
		[_headerViewToRemove removeFromSuperview];
		_headerViewToRemove = nil;
	}
	if(_visibleHeaderView){
		_visibleHeaderView.frame = CGRectMake(0,0,self.bounds.size.width,_visibleHeaderView.bounds.size.height);
		if([_visibleHeaderView superview] != self){
			[self addSubview:_visibleHeaderView];
		}
	}
	
	NSMutableArray* toAdd = [NSMutableArray array];
	NSMutableArray* toRemove = [NSMutableArray array];
	NSMutableArray* visibles = [NSMutableArray array];
	[self updateVisibleIndexPaths:visibles indexPathToAdd:toAdd indexPathToRemove:toRemove];
	
	for(NSIndexPath* indexPath in toRemove){
		UIView* view = [_visibleViewsForIndexPaths objectForKey:indexPath];
		[view removeFromSuperview];
		[_visibleViewsForIndexPaths removeObjectForKey:indexPath];
		[self enqueueReusableView:view];
		
		
		if(_delegate && [_delegate respondsToSelector:@selector(carouselView:viewDidDisappearAtIndexPath:)]){
			[_delegate carouselView:self viewDidDisappearAtIndexPath:indexPath];
		}
	}
	
	for(NSIndexPath* indexPath in toAdd){
		if(_dataSource && [_dataSource respondsToSelector:@selector(carouselView:viewForRowAtIndexPath:)]){
			UIView* view = [_dataSource carouselView:self viewForRowAtIndexPath:indexPath];
			if([view superview] != self){
				[view removeFromSuperview];
				[self addSubview:view];
				[_visibleViewsForIndexPaths setObject:view forKey:indexPath];
			}
			
			if(_delegate && [_delegate respondsToSelector:@selector(carouselView:viewDidAppearAtIndexPath:)]){
				[_delegate carouselView:self viewDidAppearAtIndexPath:indexPath];
			}
		}
	}
	
	for(NSIndexPath* indexPath in [_visibleViewsForIndexPaths allKeys]){
		UIView* view = [_visibleViewsForIndexPaths objectForKey:indexPath];
		[self layoutSubView:view atIndexPath:indexPath];
	}
	
	//Same for HeaderView
}

- (void)layoutSubviews{
	
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

- (BOOL)isVisibleAtIndexPath:(NSIndexPath*)indexPath{
	switch(_displayType){
		case CKCarouselViewDisplayTypeHorizontal:{
			CGRect viewRect = [self rectForRowAtIndexPath:indexPath];
			if(viewRect.origin.x + viewRect.size.width <= 0
			   || viewRect.origin.x >= self.bounds.size.width){
				return NO;
			}
			return YES;
		}
	}
	return NO;
}

- (void)updateVisibleIndexPaths:(NSMutableArray*)visiblesIndexPaths indexPathToAdd:(NSMutableArray*)indexPathToAdd indexPathToRemove:(NSMutableArray*)indexPathToRemove{
	[visiblesIndexPaths removeAllObjects];
	[indexPathToAdd removeAllObjects];
	[indexPathToRemove removeAllObjects];
	
	BOOL finished = NO;
	for(NSInteger i = MIN(MAX((NSInteger)_contentOffset,0),_numberOfPages-1); i >=0 && !finished; --i){
		NSIndexPath* indexPath = [self indexPathForPage:i];
		if(indexPath){
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
	}
	finished = NO;
	for(NSInteger i = MIN(MAX((NSInteger)_contentOffset+1,0),_numberOfPages-1); i < _numberOfPages && !finished; ++i){
		NSIndexPath* indexPath = [self indexPathForPage:i];
		if(indexPath){
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
	}
	
	NSArray* allKeys = [_visibleViewsForIndexPaths allKeys];
	for(NSIndexPath* indexPath in allKeys){
		if(![visiblesIndexPaths containsObject:indexPath]){
			[indexPathToRemove addObject:indexPath];
		}
	}
}

- (NSArray*)visibleIndexPaths{
	NSArray* allKeys = [_visibleViewsForIndexPaths allKeys];
	return allKeys;
}

- (NSArray*)visibleViews{
	NSArray* allValues = [_visibleViewsForIndexPaths allValues];
	return allValues;
}

- (UIView*)viewAtIndexPath:(NSIndexPath*)indexPath{
	return [_visibleViewsForIndexPaths objectForKey:indexPath];
}

#pragma mark Horizontal Scroll Layout

- (CGSize)defaultSize{
	return CGSizeMake(self.bounds.size.width,100);
}

- (CGFloat)convertToViewCoordinate:(CGFloat)page offset:(CGFloat)offset{
	//offset between 0 && 1
	if(page >= 0 && page < [_rowSizes count]){
		CGSize viewSize = [[_rowSizes objectAtIndex:page]CGSizeValue];
		CGFloat totalWidth = viewSize.width + _spacing;
		return totalWidth * offset;
	}
	else if(page < 0 && [_rowSizes count] > 0){
		CGSize viewSize = [[_rowSizes objectAtIndex:0]CGSizeValue];
		CGFloat totalWidth = viewSize.width + _spacing;
		return totalWidth * offset;
	}
	else if(page >= [_rowSizes count] && [_rowSizes count] > 0){
		CGSize viewSize = [[_rowSizes objectAtIndex: [_rowSizes count]-1]CGSizeValue];
		CGFloat totalWidth = viewSize.width + _spacing;
		return totalWidth * offset;
	}
	return ([self defaultSize].width + _spacing) * offset;
}

- (CGFloat)convertToPageCoordinate:(CGFloat)initialOffset translation:(CGFloat)x{
	CGFloat translationSign = (x < 0) ? 1 : -1;
	CGFloat firstPage = round(initialOffset);
	
	CGFloat coeff = 0.5;
	CGFloat offset = 0;
	CGFloat cumulativeX = 0;
	cumulativeX = [self convertToViewCoordinate:(NSInteger)firstPage offset:coeff];
	
	coeff = 1.0;
	CGFloat page = firstPage;
	CGFloat previousX = 0;
	while(cumulativeX < fabs(x)){
		page += translationSign;
		offset = -translationSign * 0.5;
		previousX = cumulativeX;
		cumulativeX += [self convertToViewCoordinate:(NSInteger)page offset:coeff];
	}
	
	CGSize viewSize = [self sizeForPage:page];
	CGFloat totalWidth =  (viewSize.width + _spacing) * coeff;
	
	CGFloat totalOffset = 0;
	if(translationSign > 0){
		CGFloat deltaInPageX = fabs(x) - previousX;
		totalOffset = page + offset + (deltaInPageX / totalWidth);
	}
	else{
		CGFloat deltaInPageX = fabs(x) - previousX;
		totalOffset = page + offset - (deltaInPageX / totalWidth);
	}
	
	return initialOffset - totalOffset;
}


- (CGSize)sizeForPage:(NSInteger)page{
	if(page < [_rowSizes count]){
		return [[_rowSizes objectAtIndex:page]CGSizeValue];
	}
	else if(page < 0 && [_rowSizes count] > 0){
		return [[_rowSizes objectAtIndex:0]CGSizeValue];
	}
	else if(page >= [_rowSizes count] && [_rowSizes count] > 0){
		return [[_rowSizes objectAtIndex: [_rowSizes count]-1]CGSizeValue];
	}
	return [self defaultSize];
}

- (CGSize)sizeForViewAtIndexPath:(NSIndexPath*)indexPath{
	NSInteger page = [self pageForIndexPath:indexPath];
	return [self sizeForPage:page];
}

- (CGRect)rectForRowAtIndexPath:(NSIndexPath*)indexPath{
	CGFloat headerSize = (_visibleHeaderView != nil) ? _visibleHeaderView.frame.size.height : 0;
	CGPoint center = CGPointMake(self.bounds.size.width / 2,headerSize + (self.bounds.size.height - headerSize) / 2);
	
	CGFloat xOffset = 0;
	
	CGSize viewSize = [self sizeForViewAtIndexPath:indexPath];
	
	NSInteger page = [self pageForIndexPath:indexPath];
	CGFloat offset = page - _contentOffset;
	CGFloat sign = (offset > 0 ) ? 1 : -1;
	CGFloat absOffset = fabs(offset);
	if(absOffset < 0.5){
		xOffset = [self convertToViewCoordinate:page offset:sign * absOffset];
	}
	else{
		xOffset = [self convertToViewCoordinate:page offset:sign * 0.5];
		absOffset -= 0.5;
		while(absOffset >= 0){
			page -= sign;
			if(absOffset > 1){
				xOffset += [self convertToViewCoordinate:page offset:sign * 1];
			}
			else{
				xOffset += [self convertToViewCoordinate:page offset:sign * absOffset];
			}
			absOffset--;
		}
	}
	
	page = [self pageForIndexPath:indexPath];
	CGPoint viewTopLeft = CGPointMake(center.x + xOffset - viewSize.width / 2,center.y - viewSize.height / 2);
	CGRect rect = CGRectMake(viewTopLeft.x,viewTopLeft.y,viewSize.width,viewSize.height);
	return rect;
}

- (void)layoutSubView:(UIView*)view atIndexPath:(NSIndexPath*)indexPath{
	CGRect frameForRow = [self rectForRowAtIndexPath:indexPath];
	view.frame = frameForRow;
	
	//DO Layout _contentOffset
	//set frame, bounds, center, scale and layer transforms
}

#pragma mark contentOffset
- (void)updateOffset:(CGFloat)offset{
	if(_contentOffset != offset){
		self.contentOffset = offset;
		NSInteger page = MAX(0,MIN(_numberOfPages-1,(NSInteger)round(self.contentOffset)));
		if(page != _currentPage){
			self.currentPage = page;
			NSIndexPath* indexPath = [self indexPathForPage:page];
			NSInteger section = indexPath.section;
			if(section != _currentSection){
				self.currentSection = section;
				_headerViewToRemove = _visibleHeaderView;
				if(_delegate && [_delegate respondsToSelector:@selector(carouselView:viewForHeaderInSection:)]){
					self.visibleHeaderView = [_delegate carouselView:self viewForHeaderInSection:section];
				}
			}
		}
		[self updateViewsAnimated:NO];
		if(_delegate && [_delegate respondsToSelector:@selector(carouselViewDidScroll:)]){
			[_delegate carouselViewDidScroll:self];
		}
	}
}

-(void)drawLayer:(CALayer*)l inContext:(CGContextRef)context{
	CKCarouselViewLayer* carouselLayer = (CKCarouselViewLayer*)l;
	[self updateOffset:carouselLayer.contentOffset];
}

- (void)setContentOffset:(CGFloat)offset animated:(BOOL)animated{
	CKCarouselViewLayer* carouselLayer = (CKCarouselViewLayer*)[self.layer presentationLayer];
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"contentOffset"];
	animation.duration = 0.4;
	animation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.2 :0.8 :1.0 :1.0];//[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
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
	
	CGFloat pageOffset = [self convertToPageCoordinate:_contentOffsetWhenStartPanning translation:translation.x];
	//CGFloat pageVelocity = [self convertToPageCoordinate:_contentOffsetWhenStartPanning translation:velocity.x];
	
	if(recognizer.state == UIGestureRecognizerStateBegan){
		_contentOffsetWhenStartPanning = _contentOffset;
	}
	else if(recognizer.state != UIGestureRecognizerStateEnded){
		[self setContentOffset:_contentOffsetWhenStartPanning - pageOffset animated:NO];
	}
	else{
		CGFloat offset = round(_contentOffset);
		if((offset <= 0 && velocity.x >= 0)|| (offset >= _numberOfPages-1 && velocity.x <= 0) || fabs(velocity.x) <= 300){
			offset = MAX(0,MIN(_numberOfPages-1,offset));
			[self setContentOffset:offset animated:YES];
		}
		else if(fabs(velocity.x) > 300){
			offset = round(_contentOffsetWhenStartPanning);
			if(velocity.x < 0)
				++offset;
			else{
				--offset;
			}
			
			offset = MAX(0,MIN(_numberOfPages-1,offset));
			
			CKCarouselViewLayer* carouselLayer = (CKCarouselViewLayer*)[self.layer presentationLayer];
			
			CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"contentOffset"];
			animation.calculationMode = kCAAnimationPaced;
			animation.duration = 0.3;
			//animation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:1 :0.8 :0.0 :1.0];
			animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
			
			NSMutableArray* values = [NSMutableArray array];
			[values addObject: [NSNumber numberWithFloat:_contentOffset]];
			[values addObject: [NSNumber numberWithFloat:offset - velocity.x / 30000]];
			[values addObject: [NSNumber numberWithFloat:offset]];
			animation.values = values;
			animation.removedOnCompletion = NO;
			animation.fillMode = kCAFillModeForwards;
			[carouselLayer addAnimation:animation forKey:@"contentOffset"];			
		}
	}
	
	BOOL ended = (recognizer.state == UIGestureRecognizerStateEnded);
	
	//NSLog(@"location=%f offset=%f velocity=%f pageOffset=%f pageVelocity=%f ended=%@",location.x,translation.x,velocity.x,pageOffset,pageVelocity,ended ? @"YES" : @"NO");
}

@end
