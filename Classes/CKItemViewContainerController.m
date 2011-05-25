//
//  CKItemViewContainerController.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-05-25.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKItemViewContainerController.h"

#import <CloudKit/MAZeroingWeakRef.h>
#import "CKTableViewCellController+StyleManager.h"

//CKItemViewContainerController

@interface CKItemViewContainerController ()

@property (nonatomic, retain) NSMutableDictionary* viewsToControllers;
@property (nonatomic, retain) NSMutableDictionary* viewsToIndexPath;
@property (nonatomic, retain) NSMutableDictionary* indexPathToViews;
@property (nonatomic, retain) NSMutableArray* weakViews;

@end

//CKItemViewContainerController

@implementation CKItemViewContainerController

@synthesize objectController = _objectController;
@synthesize controllerFactory = _controllerFactory;
@synthesize viewsToControllers = _viewsToControllers;
@synthesize viewsToIndexPath = _viewsToIndexPath;
@synthesize indexPathToViews = _indexPathToViews;
@synthesize weakViews = _weakViews;
@synthesize params = _params;
@synthesize delegate = _delegate;


#pragma mark Initialization

- (id)initWithObjectController:(id)controller withControllerFactory:(CKObjectViewControllerFactory*)factory  withNibName:(NSString*)nib{
	[super initWithNibName:nib bundle:[NSBundle mainBundle]];
	self.objectController = controller;
	self.controllerFactory = factory;
	return self;	
}

- (id)initWithCollection:(CKDocumentCollection*)collection mappings:(NSArray*)mappings withNibName:(NSString*)nib{
	CKDocumentController* controller = [[[CKDocumentController alloc]initWithCollection:collection]autorelease];
	CKObjectViewControllerFactory* factory = [CKObjectViewControllerFactory factoryWithMappings:mappings];
	[self initWithObjectController:controller withControllerFactory:factory withNibName:nib];
	return self;
}

- (id)initWithCollection:(CKDocumentCollection*)collection mappings:(NSArray*)mappings{
	[self initWithCollection:collection mappings:mappings withNibName:nil];
	return self;
}

- (id)initWithObjectController:(id)controller withControllerFactory:(CKObjectViewControllerFactory*)factory{
	[self initWithObjectController:controller withControllerFactory:factory withNibName:nil];
	return self;
}

- (void)dealloc {
	[_params release];
	_params = nil;
	[_objectController release];
	_objectController = nil;
	[_viewsToControllers release];
	_viewsToControllers = nil;
	[_controllerFactory release];
	_controllerFactory = nil;
	[_viewsToIndexPath release];
	_viewsToIndexPath = nil;
	[_indexPathToViews release];
	_indexPathToViews = nil;
	[_weakViews release];
	_weakViews = nil;
	
	[super dealloc];
}

#pragma mark ObjectController/ FactoryController initialization

- (void)setObjectController:(id)controller{
	if([_objectController respondsToSelector:@selector(setDelegate:)]){
		[_objectController performSelector:@selector(setDelegate:) withObject:nil];
	}
	
	if([_controllerFactory respondsToSelector:@selector(setObjectController:)]){
		[_controllerFactory performSelector:@selector(setObjectController:) withObject:nil];
	}
	
	[_objectController release];
	_objectController = [controller retain];
	
	if([_controllerFactory respondsToSelector:@selector(setObjectController:)]){
		[_controllerFactory performSelector:@selector(setObjectController:) withObject:_objectController];
	}
	
	if([self isViewLoaded] && [self.view window] && [controller respondsToSelector:@selector(setDelegate:)]){
		[controller performSelector:@selector(setDelegate:) withObject:self];
		[self onReload];
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

#pragma mark View management

- (void)viewWillAppear:(BOOL)animated{
	if([_objectController respondsToSelector:@selector(setDelegate:)]){
		[_objectController performSelector:@selector(setDelegate:) withObject:self];
	}
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[self updateViewsVisibility:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[self updateViewsVisibility:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	if([_objectController respondsToSelector:@selector(setDelegate:)]){
		[_objectController performSelector:@selector(setDelegate:) withObject:nil];
	}
}

#pragma mark Interface Orientation Management


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration{
	[super willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:duration];
	
	[self updateParams];
	[self.params setObject:[NSNumber numberWithDouble:duration] forKey:CKTableViewAttributeAnimationDuration];
	[self updateVisibleViewsRotation];
	[self updateViewsVisibility:YES];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
	[self updateViewsVisibility:YES];
}


#pragma mark Visible views management

- (void)updateVisibleViewsRotation{
	NSArray *visibleViews = [self visibleViews];
	for (UIView *view in visibleViews) {
		NSIndexPath *indexPath = [self indexPathForView:view];
		CKItemViewController* controller = [self controllerAtIndexPath:indexPath];
		if([controller respondsToSelector:@selector(rotateView:withParams:animated:)]){
			[controller rotateView:view withParams:self.params animated:YES];
		}
	}	
}

//Update the indexPath of the visible controllers as they could have moved.
- (void)updateVisibleViewsIndexPath{
	//ptet utiliser tous les controllers de _viewsToControllers
	NSArray *visibleViews = [self visibleViews];
	for (UIView *view in visibleViews) {
		NSIndexPath *indexPath = [self indexPathForView:view];
		CKItemViewController* controller = [self controllerAtIndexPath:indexPath];
		[controller performSelector:@selector(setIndexPath:) withObject:indexPath];
	}
}

- (void)updateViewsVisibility:(BOOL)visible{
	//ptet utiliser tous les controllers de _viewsToControllers
	NSArray *visibleViews = [self visibleViews];
	for (UIView *view in visibleViews) {
		NSIndexPath *indexPath = [self indexPathForView:view];
		CKItemViewController* controller = [self controllerAtIndexPath:indexPath];
		if(visible){
			[controller viewDidAppear:view];
		}
		else{
			[controller viewDidDisappear];
		}
	}
}

#pragma mark IndexPath/View/Controller management

- (CKItemViewController*)controllerAtIndexPath:(NSIndexPath *)indexPath{
	UIView* view = [self viewAtIndexPath:indexPath];
	if(view){
		return (CKItemViewController*)[_viewsToControllers objectForKey:[NSValue valueWithNonretainedObject:view]];
	}
	return nil;
}

- (UIView*)viewAtIndexPath:(NSIndexPath *)indexPath{
	NSAssert(NO,@"Implement in inheriting class");
	return nil;
}

- (NSIndexPath*)indexPathForView:(UIView*)view{
	NSAssert(NO,@"Implement in inheriting class");
	return nil;
}

- (NSArray*)visibleViews{
	NSAssert(NO,@"Implement in inheriting class");
	return nil;
}


- (void)updateParams{
	NSAssert(NO,@"Implement in inheriting class");
}

#pragma mark ObjectController/ControllerFactory helpers

- (NSInteger)sectionCount{
	if([_objectController respondsToSelector:@selector(numberOfSections)]){
		return [_objectController numberOfSections];
	}
	return 0;
}

- (NSInteger)numberOfViewsForSection:(NSInteger)section{
	if([_objectController respondsToSelector:@selector(numberOfObjectsForSection:)]){
		return [_objectController numberOfObjectsForSection:section];
	}
	return 0;
}

- (CGSize)sizeForViewAtIndexPath:(NSIndexPath *)indexPath{
	return [self.controllerFactory sizeForControllerAtIndexPath:indexPath params:self.params];
}

- (CKItemViewFlags)flagsForViewAtIndexPath:(NSIndexPath*)indexPath{
	CKItemViewFlags flags = [self.controllerFactory flagsForControllerIndexPath:indexPath params:self.params];
	return flags;
}

- (void)fetchObjectsInRange:(NSRange)range forSection:(NSInteger)section{
	if([_objectController respondsToSelector:@selector(fetchRange:forSection:)]){
		[_objectController fetchRange:range forSection:section];
	}
}

#pragma mark View/Controller life management

- (void)releaseView:(id)sender target:(id)target{
	NSIndexPath* previousPath = [_viewsToIndexPath objectForKey:[NSValue valueWithNonretainedObject:target]];
	[_indexPathToViews removeObjectForKey:previousPath];
	
	CKItemViewController* controller = [_viewsToControllers objectForKey:[NSValue valueWithNonretainedObject:target]];
	[controller performSelector:@selector(setView:) withObject:nil];
	[_viewsToControllers removeObjectForKey:[NSValue valueWithNonretainedObject:target]];
	[_weakViews removeObject:sender];
}


- (UIView*)dequeueReusableViewWithIdentifier:(NSString*)identifier{
	NSAssert(NO,@"Implement in inheriting class");
	return nil;
}

- (UIView*)createViewAtIndexPath:(NSIndexPath*)indexPath{
	if([_objectController respondsToSelector:@selector(objectAtIndexPath:)]){
		id object = [_objectController objectAtIndexPath:indexPath];
		
		CKObjectViewControllerFactoryItem* factoryItem = [_controllerFactory factoryItemAtIndexPath:indexPath];
		if(factoryItem != nil && factoryItem.controllerClass){
			NSString* identifier = [CKItemViewController identifierForClass:factoryItem.controllerClass object:object indexPath:indexPath  parentController:self];
			UIView *view = [self dequeueReusableViewWithIdentifier:identifier];
			CKItemViewController* controller = nil;
			if(view == nil){
				controller = [factoryItem controllerForObject:object atIndexPath:indexPath];
				[controller performSelector:@selector(setParentController:) withObject:self];
				
				view = [controller loadView];
				view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
				
				//Register cell to controller
				if(_viewsToControllers == nil){ self.viewsToControllers = [NSMutableDictionary dictionary]; }
				if(_weakViews == nil){ self.weakViews = [NSMutableArray array]; }
				
				MAZeroingWeakRef* viewRef = [[MAZeroingWeakRef alloc]initWithTarget:view];
				[viewRef setDelegate:self action:@selector(releaseView:target:)];
				[_weakViews addObject:viewRef];
				[_viewsToControllers setObject:controller forKey:[NSValue valueWithNonretainedObject:view]];
				[viewRef release];
			}
			else{
				NSIndexPath* previousPath = [_viewsToIndexPath objectForKey:[NSValue valueWithNonretainedObject:view]];
				[_indexPathToViews removeObjectForKey:previousPath];
				
				//Reuse controller
				NSAssert(_viewsToControllers != nil,@"Should have been created");
				controller = (CKItemViewController*)[_viewsToControllers objectForKey:[NSValue valueWithNonretainedObject:view]];
			}
			
			NSAssert(view != nil,@"The view has not been created");
			
			[controller performSelector:@selector(setParentController:) withObject:self];
			[controller performSelector:@selector(setIndexPath:) withObject:indexPath];
			[controller performSelector:@selector(setView:) withObject:view];
			
			if(_viewsToIndexPath == nil){ self.viewsToIndexPath = [NSMutableDictionary dictionary]; }
			[_viewsToIndexPath setObject:indexPath forKey:[NSValue valueWithNonretainedObject:view]];
			if(_indexPathToViews == nil){self.indexPathToViews = [NSMutableDictionary dictionary]; }
			[_indexPathToViews setObject:[NSValue valueWithNonretainedObject:view] forKey:indexPath];
			
			[controller setValue:object];
			[controller setupView:view];	
			
			if(controller && [controller respondsToSelector:@selector(rotateView:withParams:animated:)]){
				[controller rotateView:view withParams:self.params animated:NO];
			}
			
			return view;
		}
	}
	
	return nil;
}

#pragma mark Item controller interactions
- (BOOL)willSelectViewAtIndexPath:(NSIndexPath *)indexPath{
	CKItemViewFlags flags = [self flagsForViewAtIndexPath:indexPath];
	BOOL bo = flags & CKItemViewFlagSelectable;
	if(bo){
		CKItemViewController* controller = [self controllerAtIndexPath:indexPath];
		if(controller != nil){
			[controller willSelect];
		}
	}
	return bo;
}

- (void)didSelectViewAtIndexPath:(NSIndexPath *)indexPath{
	CKItemViewController* controller = [self controllerAtIndexPath:indexPath];
	if(controller != nil){
		[controller didSelect];
		if(_delegate && [_delegate respondsToSelector:@selector(itemViewContainerController:didSelectViewAtIndexPath:withObject:)]){
			[_delegate itemViewContainerController:self didSelectViewAtIndexPath:indexPath withObject:controller.value];
		}
	}
}

- (void)didSelectAccessoryViewAtIndexPath:(NSIndexPath *)indexPath{
	CKItemViewController* controller = [self controllerAtIndexPath:indexPath];
	if(controller != nil){
		[controller didSelectAccessoryView];
		if(_delegate && [_delegate respondsToSelector:@selector(itemViewContainerController:didSelectAccessoryViewAtIndexPath:withObject:)]){
			[_delegate itemViewContainerController:self didSelectAccessoryViewAtIndexPath:indexPath withObject:controller.value];
		}
	}
}

- (BOOL)isViewEditableAtIndexPath:(NSIndexPath *)indexPath{
	CKItemViewFlags flags = [self flagsForViewAtIndexPath:indexPath];
	BOOL bo = flags & (CKItemViewFlagEditable | CKItemViewFlagRemovable | CKItemViewFlagMovable);
	return bo;
}

- (BOOL)isViewMovableAtIndexPath:(NSIndexPath *)indexPath{
	CKItemViewFlags flags = [self flagsForViewAtIndexPath:indexPath];
	BOOL bo = flags & CKItemViewFlagMovable;
	return bo;
}

#pragma mark parent controller interactions

- (void)didRemoveViewAtIndexPath:(NSIndexPath*)indexPath{
	if([_objectController respondsToSelector:@selector(removeObjectAtIndexPath:)]){
		[_objectController removeObjectAtIndexPath:indexPath];
	}
}

- (NSIndexPath*)targetIndexPathForMoveFromIndexPath:(NSIndexPath*)sourceIndexPath toProposedIndexPath:(NSIndexPath*)proposedDestinationIndexPath{
	if([_objectController respondsToSelector:@selector(targetIndexPathForMoveFromRowAtIndexPath:toProposedIndexPath:)]){
		return [_objectController targetIndexPathForMoveFromRowAtIndexPath:sourceIndexPath toProposedIndexPath:proposedDestinationIndexPath];
	}
	return [NSIndexPath indexPathForRow:0 inSection:-1];
}

- (void)didMoveViewAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath{
	if([_objectController respondsToSelector:@selector(moveObjectFromIndexPath:toIndexPath:)]){
		[_objectController moveObjectFromIndexPath:fromIndexPath toIndexPath:toIndexPath];
	}
}

#pragma mark CKObjectControllerDelegate

- (void)objectControllerReloadData:(id)controller{
	[self onReload];
	
	//bad solution because the contentsize is updated at the end of insert animation ....
	//could be better if we could observe or be notified that the contentSize has changed.
	NSTimeInterval delay = 0.4;
	[self performSelector:@selector(updateViewsVisibility:) withObject:[NSNumber numberWithBool:YES] afterDelay:delay];
}

- (void)objectControllerDidBeginUpdating:(id)controller{
	[self onBeginUpdates];
}

- (void)objectControllerDidEndUpdating:(id)controller{
	[self onEndUpdates];
	
	//bad solution because the contentsize is updated at the end of insert animation ....
	//could be better if we could observe or be notified that the contentSize has changed.
	NSTimeInterval delay = 0.4;
	[self performSelector:@selector(updateViewsVisibility:) withObject:[NSNumber numberWithBool:YES] afterDelay:delay];
	
	[self updateVisibleViewsIndexPath];
}

- (void)objectController:(id)controller insertObject:(id)object atIndexPath:(NSIndexPath*)indexPath{
	[self onInsertObjects:[NSArray arrayWithObject:object] atIndexPaths:[NSArray arrayWithObject:indexPath]];
}

- (void)objectController:(id)controller removeObject:(id)object atIndexPath:(NSIndexPath*)indexPath{
	[self onRemoveObjects:[NSArray arrayWithObject:object] atIndexPaths:[NSArray arrayWithObject:indexPath]];
}

- (void)objectController:(id)controller insertObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths{
	[self onInsertObjects:objects atIndexPaths:indexPaths];
}

- (void)objectController:(id)controller removeObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths{
	[self onRemoveObjects:objects atIndexPaths:indexPaths];
}

- (void)onReload{
	//To implement in inherited class
}

- (void)onBeginUpdates{
	//To implement in inherited class
}

- (void)onEndUpdates{
	//To implement in inherited class
}

- (void)onInsertObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths{
	//To implement in inherited class
}

- (void)onRemoveObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths{
	//To implement in inherited class
}

@end
