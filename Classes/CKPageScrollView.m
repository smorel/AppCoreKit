//
//  CKPageScrollView.m
//  CloudKit
//
//  Created by Olivier Collet on 10-07-27.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKPageScrollView.h"

@interface CKPageScrollView ()

@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) NSMutableArray *views;
@property (nonatomic, assign) BOOL didSendMoveNotification;
@property (nonatomic, readonly) CGFloat pageWidth;
@property (nonatomic, readwrite) BOOL isScrolling;

- (CGFloat)offsetForIndex:(NSUInteger)index;
- (NSUInteger)indexForOffset:(CGFloat)offset;

- (void)insertView:(UIView *)view atIndex:(NSUInteger)index;

- (void)didBeginScrolling;
- (void)didEndScrolling;

@end

//

@implementation CKPageScrollView

@synthesize dataSource = _dataSource;
@synthesize delegate = _delegate;
@synthesize scrollView = _scrollView;
@synthesize views = _views;
@synthesize didSendMoveNotification = _didSendMoveNotification;
@synthesize isScrolling = _isScrolling;

- (void)postInit {
	self.scrollView = [[[UIScrollView alloc] initWithFrame:self.bounds] autorelease];
	self.scrollView.backgroundColor = [UIColor clearColor];
	self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.scrollView.delegate = self;
	self.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
	self.scrollView.pagingEnabled = YES;
	self.scrollView.clipsToBounds = NO;
	self.scrollView.delaysContentTouches = NO;
	self.scrollView.showsVerticalScrollIndicator = self.scrollView.showsHorizontalScrollIndicator = NO;
	[self addSubview:self.scrollView];

	self.views = [NSMutableArray array];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		[self postInit];
		self.backgroundColor = [UIColor clearColor];
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
	self.scrollView = nil;
    [super dealloc];
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
	[super willMoveToWindow:newWindow];
	[self reloadData];
}

//

- (NSUInteger)currentIndex {
	NSInteger currentIndex = [self indexForOffset:self.scrollView.contentOffset.x];
	if (currentIndex > (self.views.count-1)) currentIndex = (self.views.count-1);
	if (currentIndex < 0) currentIndex = 0;
	return currentIndex;
}

- (UIView *)currentView {
	if (self.views.count == 0) return nil;
	return [self.views objectAtIndex:[self currentIndex]];
}

- (NSArray *)allViews {
	return self.views;
}

// View Management

- (void)reloadData {
	for (UIView *view in self.views) {
		[view removeFromSuperview];
	}
	[self.views removeAllObjects];
	
	if (self.dataSource == nil) {
		_nbPages = 0;
		_currentPageIndex = 0;
		return;
	}
	
	_nbPages = [self.dataSource numberOfPagesInPageScrollView:self];
	self.scrollView.contentSize = CGSizeMake(_nbPages * self.bounds.size.width, self.bounds.size.height);
	
	if (_nbPages == 0) {
		_currentPageIndex = 0;
		return;
	}

	for (int index=0 ; index<_nbPages ; index++) {
		UIView *view = [self.dataSource pageScrollView:self viewForPageAtIndex:index];
		[self insertView:view atIndex:index];
		[self.views addObject:view];
	}

	if (_currentPageIndex >= _nbPages) _currentPageIndex = _nbPages - 1;
}

- (void)insertView:(UIView *)view atIndex:(NSUInteger)index {
	view.center = CGPointMake((NSInteger)((self.pageWidth / 2.0) + (self.pageWidth * index)),(NSInteger)( self.bounds.size.height / 2.0));
	[self.scrollView addSubview:view];
}

// Calculations

- (CGFloat)pageWidth {
	return self.bounds.size.width;
}

- (CGFloat)offsetForIndex:(NSUInteger)index {
	return index * self.pageWidth;
}

- (NSUInteger)indexForOffset:(CGFloat)offset {
	return (NSUInteger)(offset / self.pageWidth);
}

// Scroll

- (void)scrollToIndex:(NSInteger)index {
	if ((index < 0) || (index >= self.views.count) || self.isScrolling) return;

	CGPoint point = CGPointMake([self offsetForIndex:index], 0);
	if (point.x == self.scrollView.contentOffset.x) return;
	[self.scrollView setContentOffset:point animated:YES];
}

- (void)didBeginScrolling {
	self.isScrolling = YES;
	if (self.didSendMoveNotification == NO) {
		if (self.delegate && [(id)self.delegate respondsToSelector:@selector(pageScrollDidBeginScrolling:)]) {
			[self.delegate pageScrollDidBeginScrolling:self];
		}
		self.didSendMoveNotification = YES;
	}
}

- (void)didEndScrolling {
	self.isScrolling = NO;
	if (self.didSendMoveNotification) {
		if (self.delegate && [(id)self.delegate respondsToSelector:@selector(pageScrollDidEndScrolling:)]) {
			[self.delegate pageScrollDidEndScrolling:self];
			self.didSendMoveNotification = NO;
		}
	}	
}

// ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[self didBeginScrolling];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if (decelerate) {
		return;
	}
	[self didEndScrolling];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	[self didEndScrolling];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
	[self didEndScrolling];
}


@end
