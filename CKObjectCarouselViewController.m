//
//  CKObjectCarouselViewController.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-07.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKObjectCarouselViewController.h"
#import "CKTableViewCellController.h"
#import "CKNSObject+Bindings.h"
#import "CKDocumentController.h"


@interface UIViewWithIdentifier : UIView{
	id reuseIdentifier;
}
@property (nonatomic,retain) id reuseIdentifier;
@end

@implementation UIViewWithIdentifier
@synthesize reuseIdentifier;
- (void)dealloc{ self.reuseIdentifier = nil; [super dealloc]; }
@end


@interface CKObjectCarouselViewController ()
@property (nonatomic, retain) NSMutableDictionary* cellsToControllers;
@property (nonatomic, retain) NSMutableDictionary* headerViewsForSections;
@property (nonatomic, retain) NSMutableDictionary* controllersForIdentifier;
@property (nonatomic, retain) NSMutableDictionary* params;

- (CKTableViewCellController*)controllerForRowAtIndexPath:(NSIndexPath*)indexPath;
- (void)notifiesCellControllersForVisibleRows;
- (CKTableViewCellFlags)flagsForRowAtIndexPath:(NSIndexPath*)indexPath;

- (NSString*)identifierForClass:(Class)theClass object:(id)object indexPath:(NSIndexPath*)indexPath;
- (void)updateParams;

@end

@implementation CKObjectCarouselViewController
@synthesize carouselView = _carouselView;
@synthesize objectController = _objectController;
@synthesize controllerFactory = _controllerFactory;
@synthesize numberOfObjectsToprefetch = _numberOfObjectsToprefetch;
@synthesize cellsToControllers = _cellsToControllers;
@synthesize headerViewsForSections = _headerViewsForSections;
@synthesize pageControl = _pageControl;
@synthesize controllersForIdentifier = _controllersForIdentifier;
@synthesize params = _params;

- (void)postInit{
	self.cellsToControllers = [NSMutableDictionary dictionary];
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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		[self postInit];
	}
	return self;
}

- (id)initWithCollection:(CKDocumentCollection*)collection mappings:(NSDictionary*)mappings{
	CKDocumentController* controller = [[[CKDocumentController alloc]initWithCollection:collection]autorelease];
	CKObjectViewControllerFactory* factory = [CKObjectViewControllerFactory factoryWithMappings:mappings];
	[self initWithObjectController:controller withControllerFactory:factory];
	return self;
}

- (id)initWithObjectController:(id)controller withControllerFactory:(CKObjectViewControllerFactory*)factory{
	[self init];
	self.objectController = controller;
	self.controllerFactory = factory;
	
	//if([controller conformsToProtocol:@protocol(CKObjectController)]){
	if([controller respondsToSelector:@selector(setDelegate:)]){
		[controller performSelector:@selector(setDelegate:) withObject:self];
	}
	//}
	return self;
}

- (void)dealloc {
	[NSObject removeAllBindingsForContext:[NSString stringWithFormat:@"%p_params",self]];
	[NSObject removeAllBindingsForContext:[NSString stringWithFormat:@"<%p>_pageControl"]];
	[_params release];
	_params = nil;
	[_controllersForIdentifier release];
	_controllersForIdentifier = nil;
	[_carouselView release];
	_carouselView = nil;
	[_objectController release];
	_objectController = nil;
	[_controllerFactory release];
	_controllerFactory = nil;
	[_headerViewsForSections release];
	_headerViewsForSections = nil;
	[_cellsToControllers release];
	_cellsToControllers = nil;
	[_pageControl release];
	_pageControl = nil;
	[super dealloc];
}

- (void)setObjectController:(id)controller{
	//if(_objectController && [_objectController conformsToProtocol:@protocol(CKObjectController)]){
	if([_objectController respondsToSelector:@selector(setDelegate:)]){
		[_objectController performSelector:@selector(setDelegate:) withObject:nil];
	}
	//}
	
	if([_controllerFactory respondsToSelector:@selector(setObjectController:)]){
		[_controllerFactory performSelector:@selector(setObjectController:) withObject:nil];
	}
	
	
	[_objectController release];
	_objectController = [controller retain];
	
	if([self.view window] && [controller respondsToSelector:@selector(setDelegate:)]){
		[controller performSelector:@selector(setDelegate:) withObject:self];
	}
	
	if([_controllerFactory respondsToSelector:@selector(setObjectController:)]){
		[_controllerFactory performSelector:@selector(setObjectController:) withObject:_objectController];
	}
	
	if(controller && [controller isKindOfClass:[CKDocumentController class]]){
		CKDocumentController* documentController = (CKDocumentController*)controller;
		documentController.displayFeedSourceCell = NO;
	}
}

- (void)setControllerFactory:(id)factory{
	if([_controllerFactory respondsToSelector:@selector(setObjectController:)]){
		[_controllerFactory performSelector:@selector(setObjectController:) withObject:nil];
	}
	
	[_controllerFactory release];
	_controllerFactory = [factory retain];
	
	if([factory respondsToSelector:@selector(setObjectController:)]){
		[factory performSelector:@selector(setObjectController:) withObject:_objectController];
	}
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
	
	//DEBUG :
	self.carouselView.clipsToBounds = YES;
	self.carouselView.spacing = 20;
	
	[NSObject beginBindingsContext:[NSString stringWithFormat:@"%p_params",self] policy:CKBindingsContextPolicyRemovePreviousBindings];
	[self.carouselView bind:@"frame" target:self action:@selector(updateParams)];
	[self bind:@"interfaceOrientation" target:self action:@selector(updateParams)];
	[self.carouselView bind:@"pagingEnabled" target:self action:@selector(updateParams)];
	[self bind:@"orientation" target:self action:@selector(updateParams)];
	[NSObject endBindingsContext];	
}

- (void)updateParams{
	if(self.params == nil){
		[self.params setObject:[NSValue valueWithCGSize:self.view.bounds.size] forKey:CKTableViewAttributeBounds];
		[self.params setObject:[NSNumber numberWithInt:self.interfaceOrientation] forKey:CKTableViewAttributeInterfaceOrientation];
		[self.params setObject:[NSNumber numberWithBool:YES] forKey:CKTableViewAttributePagingEnabled];//NOT SUPPORTED
		[self.params setObject:[NSNumber numberWithInt:CKTableViewOrientationLandscape] forKey:CKTableViewAttributeOrientation];//NOT SUPPORTED
		[self.params setObject:[NSNumber numberWithDouble:0] forKey:CKTableViewAttributeAnimationDuration];
		[self.params setObject:[NSNumber numberWithBool:NO] forKey:CKTableViewAttributeEditable];//NOT SUPPORTED
	}
}

- (void)scrollToPage:(id)page{
	[self.carouselView setContentOffset:_pageControl.currentPage animated:YES];
}

- (void)updatePageControlPage:(id)page{
	_pageControl.currentPage = (_pageControl.currentPage + 1 >= self.carouselView.numberOfPages) ? self.carouselView.currentPage - 1 :  self.carouselView.currentPage +1;
	_pageControl.currentPage = self.carouselView.currentPage;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	if(_pageControl){
		[NSObject beginBindingsContext:[NSString stringWithFormat:@"<%p>_pageControl"]];
		[self.carouselView bind:@"currentPage" target:self action:@selector(updatePageControlPage:)];
		[self.carouselView bind:@"numberOfPages" toObject:_pageControl withKeyPath:@"numberOfPages"];
		[_pageControl bindEvent:UIControlEventTouchUpInside target:self action:@selector(scrollToPage:)];
		[NSObject endBindingsContext];
	}
}

- (void)viewDidUnload {
    [super viewDidUnload];
	[NSObject removeAllBindingsForContext:[NSString stringWithFormat:@"<%p>_pageControl"]];
}

- (void)viewWillAppear:(BOOL)animated {
	if([_objectController respondsToSelector:@selector(setDelegate:)]){
		[_objectController performSelector:@selector(setDelegate:) withObject:self];
	}
	
    [super viewWillAppear:animated];
	[self updateParams];
	
	for(NSValue* cellValue in [_cellsToControllers allKeys]){
		CKTableViewCellController* controller = [_cellsToControllers objectForKey:cellValue];
		UITableViewCell* cell = [cellValue nonretainedObjectValue];
		if([controller respondsToSelector:@selector(rotateCell:withParams:animated:)]){
			[controller rotateCell:cell withParams:self.params animated:YES];
		}
	}	
	
	
	[self.carouselView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[self notifiesCellControllersForVisibleRows];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	if([_objectController respondsToSelector:@selector(setDelegate:)]){
		[_objectController performSelector:@selector(setDelegate:) withObject:nil];
	}
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	for(NSValue* cellValue in [_cellsToControllers allKeys]){
		CKTableViewCellController* controller = [_cellsToControllers objectForKey:cellValue];
		if(controller && [controller respondsToSelector:@selector(cellDidDisappear)]){
			[controller cellDidDisappear];
		}
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration{
	[self updateParams];
	for(NSValue* cellValue in [_cellsToControllers allKeys]){
		CKTableViewCellController* controller = [_cellsToControllers objectForKey:cellValue];
		UITableViewCell* cell = [cellValue nonretainedObjectValue];
		
		if([controller respondsToSelector:@selector(rotateCell:withParams:animated:)]){
			[self.params setObject:[NSNumber numberWithDouble:duration] forKey:CKTableViewAttributeAnimationDuration];
			[controller rotateCell:cell withParams:self.params animated:YES];
		}
	}
	[self notifiesCellControllersForVisibleRows];
	
	[self.carouselView reloadData];
	[self.carouselView updateViewsAnimated:YES];
	
	[super willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
	[self notifiesCellControllersForVisibleRows];
}

#pragma mark CKCarouselViewDataSource

- (NSInteger)numberOfSectionsInCarouselView:(CKCarouselView*)carouselView{
	if([_objectController respondsToSelector:@selector(numberOfSections)]){
		return [_objectController numberOfSections];
	}
	return 0;
}

- (NSInteger)carouselView:(CKCarouselView*)carouselView numberOfRowsInSection:(NSInteger)section{
	if([_objectController respondsToSelector:@selector(numberOfObjectsForSection:)]){
		return [_objectController numberOfObjectsForSection:section];
	}
	return 0;
}


- (NSString*)identifierForClass:(Class)theClass object:(id)object indexPath:(NSIndexPath*)indexPath {
	if(self.controllersForIdentifier == nil){
		self.controllersForIdentifier = [NSMutableDictionary dictionary];
	}
	
	CKTableViewCellController* controller = [_controllersForIdentifier objectForKey:theClass];
	if(controller == nil){
		controller = [[[theClass alloc]init]autorelease];
		[_controllersForIdentifier setObject:controller forKey:theClass];
	}
	
	[controller performSelector:@selector(setParentController:) withObject:self];
	[controller performSelector:@selector(setIndexPath:) withObject:indexPath];
	[controller setValue:object];
	
	return [controller identifier];
}

- (UIView*)carouselView:(CKCarouselView*)carouselView viewForRowAtIndexPath:(NSIndexPath*)indexPath{
	if([_objectController respondsToSelector:@selector(objectAtIndexPath:)]){
		id object = [_objectController objectAtIndexPath:indexPath];
		
		Class controllerClass = [_controllerFactory controllerClassForIndexPath:indexPath];
		if(controllerClass){
			NSString* identifier = [self identifierForClass:controllerClass object:object indexPath:indexPath];
			
			UIView* view = [self.carouselView dequeueReusableViewWithIdentifier:identifier];
			UITableViewCell* cell = (UITableViewCell*)view;

			CKTableViewCellController* controller = nil;
			if(cell == nil){
				controller = [[[controllerClass alloc]init]autorelease];
				[controller performSelector:@selector(setParentController:) withObject:self];
				[controller performSelector:@selector(setIndexPath:) withObject:indexPath];
				[controller setValue:object];
				
				cell = [controller loadCell];
				cell.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
				
				//Register cell to controller
				if(_cellsToControllers == nil){
					self.cellsToControllers = [NSMutableDictionary dictionary];
				}
				
				[_cellsToControllers setObject:controller forKey:[NSValue valueWithNonretainedObject:cell]];
			}
			else{
				controller = (CKTableViewCellController*)[_cellsToControllers objectForKey:[NSValue valueWithNonretainedObject:cell]];
			}
			
			
			NSAssert(cell != nil,@"The cell has not been created");
			
			[controller performSelector:@selector(setParentController:) withObject:self];
			[controller performSelector:@selector(setIndexPath:) withObject:indexPath];
			[controller performSelector:@selector(setTableViewCell:) withObject:cell];
			
			[_controllerFactory initializeController:controller atIndexPath:indexPath];
			[controller setValue:object];
			[controller setupCell:cell];	
			
			[self fetchMoreIfNeededAtIndexPath:indexPath];
			
			return cell;
		}
	}
	
	return nil;
}

#pragma mark CKCarouselViewDelegate

- (UIView*) carouselView:(CKCarouselView*)carouselView viewForHeaderInSection:(NSInteger)section{
	UIView* view = _headerViewsForSections ? [_headerViewsForSections objectForKey:[NSNumber numberWithInt:section]] : nil;
	if(view){
		return view;
	}
	
	//if([_objectController conformsToProtocol:@protocol(CKObjectController) ]){
	if([_objectController respondsToSelector:@selector(headerViewForSection:)]){
		view = [_objectController headerViewForSection:section];
		if(_headerViewsForSections == nil){
			self.headerViewsForSections = [NSMutableDictionary dictionary];
		}
		if(view != nil){
			[_headerViewsForSections setObject:view forKey:[NSNumber numberWithInt:section]];
		}
	}
	//}
	return view;
}

- (CGSize) carouselView:(CKCarouselView*)carouselView sizeForViewAtIndexPath:(NSIndexPath*)indexPath{
	if([_objectController respondsToSelector:@selector(objectAtIndexPath:)]){
		id object = [_objectController objectAtIndexPath:indexPath];
		
		Class controllerClass = [_controllerFactory controllerClassForIndexPath:indexPath];
		if(controllerClass && [controllerClass respondsToSelector:@selector(rowSizeForObject:withParams:)]){
			NSValue* v = (NSValue*) [controllerClass performSelector:@selector(rowSizeForObject:withParams:) withObject:object withObject:self.params];
			return [v CGSizeValue];
		}
	}
	return CGSizeMake(0,0);
}

- (void) carouselView:(CKCarouselView*)carouselView viewDidDisappearAtIndexPath:(NSIndexPath*)indexPath{
	CKTableViewCellController* controller = [self controllerForRowAtIndexPath:indexPath];
	if(controller && [controller respondsToSelector:@selector(cellDidDisappear)]){
		[controller cellDidDisappear];
	}
}

- (void) carouselView:(CKCarouselView*)carouselView viewDidAppearAtIndexPath:(NSIndexPath*)indexPath{
	CKTableViewCellController* controller = [self controllerForRowAtIndexPath:indexPath];
	if(controller && [controller respondsToSelector:@selector(rotateCell:withParams:animated:)]){
		UIView* view = [self.carouselView viewAtIndexPath:indexPath];
		NSAssert([view isKindOfClass:[UITableViewCell class]],@"Works with CKTableViewCellController YET");
		UITableViewCell* cell = (UITableViewCell*)view;
		
		[controller rotateCell:cell withParams:self.params animated:NO];
	}	
}

- (void) carouselViewDidScroll:(CKCarouselView*)carouselView{
}

#pragma mark CKObjectControllerDelegate

- (void)objectControllerReloadData:(id)controller{
	[self.carouselView reloadData];
	[self notifiesCellControllersForVisibleRows];
}

- (void)objectControllerDidBeginUpdating:(id)controller{
	//NOT SUPPORTED
}

- (void)objectControllerDidEndUpdating:(id)controller{
	//NOT SUPPORTED
	[self.carouselView reloadData];
}

- (void)objectController:(id)controller insertObject:(id)object atIndexPath:(NSIndexPath*)indexPath{
	//NOT SUPPORTED dynamic insertion
}

- (void)objectController:(id)controller removeObject:(id)object atIndexPath:(NSIndexPath*)indexPath{
	//NOT SUPPORTED dynamic deletion
}

- (void)scrollToRowAtIndexPath:(NSIndexPath*)indexPath animated:(BOOL)animated{
	CGFloat offset = [self.carouselView pageForIndexPath:indexPath];
	[self.carouselView setContentOffset:offset animated:animated];
}

#pragma mark CKObjectCarouselViewController

- (CKTableViewCellController*)controllerForRowAtIndexPath:(NSIndexPath*)indexPath{
	UIView* view = [self.carouselView viewAtIndexPath:indexPath];
	if(view){
		CKTableViewCellController* controller = [_cellsToControllers objectForKey:[NSValue valueWithNonretainedObject:view]];
		return controller;
	}
	return nil;
}

- (void)notifiesCellControllersForVisibleRows {
	NSArray *visibleIndexPaths = [self.carouselView visibleIndexPaths];
	for (NSIndexPath *indexPath in visibleIndexPaths) {
		UIView* view = [self.carouselView viewAtIndexPath:indexPath];
		NSAssert([view isKindOfClass:[UITableViewCell class]],@"Works with CKTableViewCellController YET");
		UITableViewCell* cell = (UITableViewCell*)view;
		[[self controllerForRowAtIndexPath:indexPath] cellDidAppear:cell];
	}
}

- (CKTableViewCellFlags)flagsForRowAtIndexPath:(NSIndexPath*)indexPath{
	//if([_objectController conformsToProtocol:@protocol(CKObjectController)]){
	if([_objectController respondsToSelector:@selector(objectAtIndexPath:)]){
		id object = [_objectController objectAtIndexPath:indexPath];
		
		Class controllerClass = [_controllerFactory controllerClassForIndexPath:indexPath];
		if(controllerClass && [controllerClass respondsToSelector:@selector(flagsForObject:withParams:)]){
			CKTableViewCellFlags flags = [controllerClass flagsForObject:object withParams:self.params];
			return flags;
		}
	}
	//}
	return CKTableViewCellFlagNone;
}

- (void)fetchMoreIfNeededAtIndexPath:(NSIndexPath*)indexPath{
	if([_objectController respondsToSelector:@selector(fetchRange:forSection:)]){
		int numberOfRows = [self carouselView:self.carouselView numberOfRowsInSection:indexPath.section];
		if(_numberOfObjectsToprefetch + indexPath.row > numberOfRows){
			[_objectController fetchRange:NSMakeRange(numberOfRows, _numberOfObjectsToprefetch) forSection:indexPath.section];
		}
	}
}

@end
