//
//  CKObjectCarouselViewController.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-07.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKObjectCarouselViewController.h"


@interface UIViewWithIdentifier : UIView{
	id identifier;
}
@property (nonatomic,retain) id identifier;
@end

@implementation UIViewWithIdentifier
@synthesize identifier;
- (void)dealloc{ self.identifier = nil; [super dealloc]; }
@end


@implementation CKObjectCarouselViewController
@synthesize carouselView = _carouselView;

- (void)postInit{
}

- (id)initWithCoder:(NSCoder *)decoder {
	[super initWithCoder:decoder];
	[self postInit];
	return self;
}

- (id)init {
    if (self = [super init]) {
		[self postInit];
    }
    return self;
}

- (void)dealloc {
	[_carouselView release];
	_carouselView = nil;
	[super dealloc];
}

- (void)loadView {
	[super loadView];
	if (self.view == nil) {
		CGRect theViewFrame = [[UIScreen mainScreen] applicationFrame];
		UIView *theView = [[[UITableView alloc] initWithFrame:theViewFrame] autorelease];
		theView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		self.view = theView;
	}
	
	if (self.carouselView == nil) {
		if ([self.view isKindOfClass:[UITableView class]]) {
			// TODO: Assert - Should not be allowed
			self.carouselView = (CKCarouselView *)self.view;
		} else {
			CGRect theViewFrame = self.view.bounds;
			CKCarouselView *theCarouselView = [[[CKCarouselView alloc] initWithFrame:theViewFrame] autorelease];
			theCarouselView.delegate = self;
			theCarouselView.dataSource = self;
			theCarouselView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
			[self.view addSubview:theCarouselView];
			self.carouselView = theCarouselView;
		}
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self.carouselView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration{
	[super willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
}

#pragma mark CKCarouselViewDataSource

- (NSInteger)numberOfSectionsInCarouselView:(CKCarouselView*)carouselView{
	return 1;
}

- (NSInteger)carouselView:(CKCarouselView*)carouselView numberOfRowsInSection:(NSInteger)section{
	return 5;
}

- (UIView*)carouselView:(CKCarouselView*)carouselView viewForRowAtIndexPath:(NSIndexPath*)indexPath{
	UIView* view = [carouselView dequeuReusableViewWithIdentifier:@"test"];
	if(view == nil){
		view = [[[UIViewWithIdentifier alloc]initWithFrame:CGRectMake(0,0,100,100)]autorelease];
		[view performSelector:@selector(setIdentifier:) withObject:@"test"];
	}
	
	switch(indexPath.row){
		case 0:	view.backgroundColor = [UIColor redColor]; break;
		case 1:	view.backgroundColor = [UIColor blueColor]; break;
		case 2:	view.backgroundColor = [UIColor greenColor]; break;
		case 3:	view.backgroundColor = [UIColor yellowColor]; break;
		case 4:	view.backgroundColor = [UIColor purpleColor]; break;
	}
	
	return view;
}

#pragma mark CKObjectControllerDelegate

- (void)objectControllerReloadData:(id)controller{
}

- (void)objectControllerDidBeginUpdating:(id)controller{
}

- (void)objectControllerDidEndUpdating:(id)controller{
}

- (void)objectController:(id)controller insertObject:(id)object atIndexPath:(NSIndexPath*)indexPath{
}

- (void)objectController:(id)controller removeObject:(id)object atIndexPath:(NSIndexPath*)indexPath{
}

- (void)scrollToRowAtIndexPath:(NSIndexPath*)indexPath animated:(BOOL)animated{
	CGFloat offset = [self.carouselView pageForIndexPath:indexPath];
	[self.carouselView setContentOffset:offset animated:animated];
}

@end
