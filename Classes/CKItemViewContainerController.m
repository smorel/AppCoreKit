//
//  CKItemViewContainerController.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-05-25.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKItemViewContainerController.h"

#import "CKWeakRef.h"
#import "CKItemViewController+StyleManager.h"
#import "CKFormTableViewController.h"

//CKItemViewContainerController

@interface CKItemViewController()
@property (nonatomic, retain, readwrite) NSIndexPath *indexPath;
@property (nonatomic, assign, readwrite) UIViewController* parentController;
@end

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
@synthesize numberOfObjectsToprefetch = _numberOfObjectsToprefetch;


#pragma mark Initialization
- (void)postInit {
	[super postInit];
	_numberOfObjectsToprefetch = 10;
}

- (id)init {
	self = [super initWithNibName:nil bundle:nil];
	if (self) {
	}
	return self;
}

- (void)setupWithCollection:(CKDocumentCollection*)collection mappings:(NSArray*)mappings{
	self.controllerFactory = [CKObjectViewControllerFactory factoryWithMappings:mappings];
    self.objectController = [[[CKDocumentCollectionController alloc]initWithCollection:collection]autorelease];
}

- (id)initWithObjectController:(id)controller withControllerFactory:(CKObjectViewControllerFactory*)factory  withNibName:(NSString*)nib{
	[self initWithNibName:nib bundle:[NSBundle mainBundle]];
	self.objectController = controller;
	self.controllerFactory = factory;
	return self;	
}

- (id)initWithCollection:(CKDocumentCollection*)collection mappings:(NSArray*)mappings withNibName:(NSString*)nib{
	CKDocumentCollectionController* controller = [[[CKDocumentCollectionController alloc]initWithCollection:collection]autorelease];
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
	
	if([self isViewLoaded] && ([self.view superview] != nil) && [controller respondsToSelector:@selector(setDelegate:)]){
		[controller performSelector:@selector(setDelegate:) withObject:self];
		[self onReload];
		for(int i =0; i< [self numberOfSections];++i){
			[self fetchMoreIfNeededAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
		}
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
	[super viewWillAppear:animated];
    
	if([_objectController respondsToSelector:@selector(setDelegate:)]){
		[_objectController performSelector:@selector(setDelegate:) withObject:self];
	}
    
	[self updateParams];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[self updateViewsVisibility:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[self.view endEditing:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
	[self updateViewsVisibility:NO];
	[super viewWillDisappear:animated];
}

#pragma mark Interface Orientation Management

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
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}


#pragma mark Visible views management

- (void)updateVisibleViewsRotation{
	NSArray *visibleIndexPaths = [self visibleIndexPaths];
	for (NSIndexPath *indexPath in visibleIndexPaths) {
		CKItemViewController* controller = [self controllerAtIndexPath:indexPath];
		if([controller respondsToSelector:@selector(rotateView:withParams:animated:)]){
			[controller rotateView:controller.view withParams:self.params animated:YES];
		}
	}	
}

//Update the indexPath of the visible controllers as they could have moved.
- (void)updateVisibleViewsIndexPath{
    for(CKWeakRef* weakView in self.weakViews){
        UIView* view = weakView.object;
        if(view){
            //indexPathForView is overloaded to point on the real views and not out reference maps
            //by using this method, we're "sure" to retrieve the right indexPath corresponding to an item view.
            NSIndexPath* indexPath = [self indexPathForView:view];
            if(indexPath){
                NSValue* weakViewValue = [NSValue valueWithNonretainedObject:view];
                CKItemViewController* controller = [self.viewsToControllers objectForKey:weakViewValue];
                [controller performSelector:@selector(setIndexPath:) withObject:indexPath];
                [self.viewsToIndexPath setObject:indexPath forKey:weakViewValue];
                [self.indexPathToViews setObject:weakViewValue forKey:indexPath];
            }
        }
    }
}

- (void)updateViewsVisibility:(BOOL)visible{
	//FIXME : a verifier .... ptet utiliser tous les controllers de _viewsToControllers
	NSArray *visibleIndexPaths = [self visibleIndexPaths];
	for (NSIndexPath *indexPath in visibleIndexPaths) {
		CKItemViewController* controller = [self controllerAtIndexPath:indexPath];
		if(visible){
			[controller viewDidAppear:controller.view];
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
    NSValue* v = [_indexPathToViews objectForKey:indexPath];
	return v ? [v nonretainedObjectValue] : nil;
}

- (NSIndexPath*)indexPathForView:(UIView*)view{
	return [_viewsToIndexPath objectForKey:[NSValue valueWithNonretainedObject:view]];
}

- (NSArray*)visibleIndexPaths{
	NSAssert(NO,@"Implement in inheriting class");
	return nil;
}

- (void)updateParams{
	NSAssert(NO,@"Implement in inheriting class");
}

#pragma mark ObjectController/ControllerFactory helpers

- (NSInteger)numberOfSections{
	if([_objectController respondsToSelector:@selector(numberOfSections)]){
		return [_objectController numberOfSections];
	}
	return 0;
}

- (NSInteger)numberOfObjectsForSection:(NSInteger)section{
	if([_objectController respondsToSelector:@selector(numberOfObjectsForSection:)]){
		return [_objectController numberOfObjectsForSection:section];
	}
	return 0;
}

- (CGSize)sizeForViewAtIndexPath:(NSIndexPath *)indexPath{
    if(self.params == nil){
        [self updateParams];
    }
	return [self.controllerFactory sizeForControllerAtIndexPath:indexPath params:self.params];
}

- (CKItemViewFlags)flagsForViewAtIndexPath:(NSIndexPath*)indexPath{
	CKItemViewFlags flags = [self.controllerFactory flagsForControllerIndexPath:indexPath params:self.params];
	return flags;
}

- (void)fetchMoreData{
    //return;
    
	//Fetch data if needed
	NSInteger minVisibleSectionIndex = INT32_MAX;
	NSInteger maxVisibleSectionIndex = -1;
	NSMutableDictionary* maxIndexPaths = [NSMutableDictionary dictionary];
	NSArray *visibleIndexPaths = [self visibleIndexPaths];
	for (NSIndexPath *indexPath in visibleIndexPaths) {
		NSInteger section = indexPath.section;
		if(section < minVisibleSectionIndex) minVisibleSectionIndex = section;
		if(section > maxVisibleSectionIndex) maxVisibleSectionIndex = section;
		id maxForSection = [maxIndexPaths objectForKey:[NSNumber numberWithInt:section]];
		if(maxForSection != nil){
			if(indexPath.row > [maxForSection intValue]){
				[maxIndexPaths setObject:[NSNumber numberWithInt:indexPath.row] forKey:[NSNumber numberWithInt:section]];
			}
		}
		else{
			[maxIndexPaths setObject:[NSNumber numberWithInt:indexPath.row] forKey:[NSNumber numberWithInt:section]];
		}
	}
	
	for(NSInteger i = minVisibleSectionIndex; i <= maxVisibleSectionIndex; ++i){
		NSNumber* sectionNumber = [NSNumber numberWithInt:i];
		id maxRowNumber = [maxIndexPaths objectForKey:sectionNumber];
		NSInteger maxRow = maxRowNumber ? [maxRowNumber intValue] : 0;
		[self fetchMoreIfNeededAtIndexPath:[NSIndexPath indexPathForRow:maxRow inSection:i]];
	}
}

- (void)fetchMoreIfNeededAtIndexPath:(NSIndexPath*)indexPath{
    BOOL feedSourceCellEnabled = NO;
    if([_objectController respondsToSelector:@selector(displayFeedSourceCell)]){
        feedSourceCellEnabled = [_objectController displayFeedSourceCell];
    }
	int numberOfRows = [self numberOfObjectsForSection:indexPath.section] - (feedSourceCellEnabled ? 1 : 0);
	if(_numberOfObjectsToprefetch + indexPath.row > numberOfRows){
		[self fetchObjectsInRange:NSMakeRange(numberOfRows, _numberOfObjectsToprefetch) forSection:indexPath.section];
	}
}

- (void)fetchObjectsInRange:(NSRange)range forSection:(NSInteger)section{
	if([_objectController respondsToSelector:@selector(fetchRange:forSection:)]){
		[_objectController fetchRange:range forSection:section];
	}
}

#pragma mark View/Controller life management

- (id)releaseView:(CKWeakRef*)weakref{
    NSAssert(weakref,@"Weird ... Should never happend");
    NSValue* weakViewValue = [NSValue valueWithNonretainedObject:weakref.object];
	NSIndexPath* previousPath = [_viewsToIndexPath objectForKey:weakViewValue];
    if(previousPath){
        [_indexPathToViews removeObjectForKey:previousPath];
    }
	[_viewsToIndexPath removeObjectForKey:weakViewValue];
	[_viewsToControllers removeObjectForKey:weakViewValue];
	[_weakViews removeObject:weakref];
	return (id)nil;
}


- (UIView*)dequeueReusableViewWithIdentifier:(NSString*)identifier{
	NSAssert(NO,@"Implement in inheriting class");
	return nil;
}


- (id)objectAtIndexPath:(NSIndexPath*)indexPath{
	if([_objectController respondsToSelector:@selector(objectAtIndexPath:)]){
		return [_objectController objectAtIndexPath:indexPath];
	}
	return nil;
}

- (BOOL)isValidIndexPath:(NSIndexPath*)indexPath{
    if(indexPath == nil)
        return NO;
    
	id object = [self objectAtIndexPath:indexPath];
	return object != nil;
}

- (NSArray*)objectsForSection:(NSInteger)section{
	NSMutableArray* array = [NSMutableArray array];
	NSInteger count = [self numberOfObjectsForSection:section];
	for(int i=0;i<count;++i){
		[array addObject:[self objectAtIndexPath:[NSIndexPath indexPathForRow:i inSection:section]]];
	}
	return array;
}

- (NSInteger)indexOfObject:(id)object inSection:(NSInteger)section{
	NSArray* objects = [self objectsForSection:section];
	return [objects indexOfObject:object];
}

- (UIView*)createViewAtIndexPath:(NSIndexPath*)indexPath{
	if([_objectController respondsToSelector:@selector(objectAtIndexPath:)]){
		id object = [_objectController objectAtIndexPath:indexPath];
        
        UIView* previousView = [[_indexPathToViews objectForKey:indexPath]nonretainedObjectValue];
        if(previousView){
            [_indexPathToViews removeObjectForKey:indexPath];
            [_viewsToIndexPath removeObjectForKey:[NSValue valueWithNonretainedObject:previousView]];
        }
		
		CKObjectViewControllerFactoryItem* factoryItem = [_controllerFactory factoryItemAtIndexPath:indexPath];
		if(factoryItem != nil && factoryItem.controllerClass){
			NSString* identifier = [CKItemViewController identifierForItem:factoryItem object:object indexPath:indexPath  parentController:self];
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
				
				CKWeakRef* viewRef = [CKWeakRef weakRefWithObject:view target:self action:@selector(releaseView:)];
				[_weakViews addObject:viewRef];
                
                [_viewsToControllers setObject:controller forKey:[NSValue valueWithNonretainedObject:view]];
			}
			else{
				NSIndexPath* previousPath = [_viewsToIndexPath objectForKey:[NSValue valueWithNonretainedObject:view]];
                if(previousPath){
                    [_indexPathToViews removeObjectForKey:previousPath];
                    [_viewsToIndexPath removeObjectForKey:[NSValue valueWithNonretainedObject:view]];
                    //NSLog(@"createViewAtIndexPath -- controller <%p> _indexPathToViews removes view : <%p> at indexPath : %@",self,view,previousPath);
                }
				
				//Reuse controller
				NSAssert(_viewsToControllers != nil,@"Should have been created");
				controller = (CKItemViewController*)[_viewsToControllers objectForKey:[NSValue valueWithNonretainedObject:view]];
				
				controller.createCallback = [factoryItem createCallback];
				controller.initCallback = [factoryItem initCallback];
				controller.setupCallback = [factoryItem setupCallback];
				controller.selectionCallback = [factoryItem selectionCallback];
				controller.accessorySelectionCallback = [factoryItem accessorySelectionCallback];
				controller.becomeFirstResponderCallback = [factoryItem becomeFirstResponderCallback];
				controller.resignFirstResponderCallback = [factoryItem resignFirstResponderCallback];
				controller.layoutCallback = [factoryItem layoutCallback];
			}
			
			NSAssert(view != nil,@"The view has not been created");
			
			[controller setParentController:self];
			[controller setIndexPath:indexPath];
			[controller setView:view];
			
			if(_viewsToIndexPath == nil){ self.viewsToIndexPath = [NSMutableDictionary dictionary]; }
			[_viewsToIndexPath setObject:indexPath forKey:[NSValue valueWithNonretainedObject:view]];
			if(_indexPathToViews == nil){self.indexPathToViews = [NSMutableDictionary dictionary]; }
			[_indexPathToViews setObject:[NSValue valueWithNonretainedObject:view] forKey:indexPath];
            //NSLog(@"createViewAtIndexPath -- controller <%p> _indexPathToViews set view : <%p> at indexPath : %@",self,view,indexPath);

			[controller setValue:object];
			[controller setupView:view];	
			
			if(controller){
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

- (void)incrementIndexPathFrom:(NSIndexPath*)indexPath{
    id view = [_indexPathToViews objectForKey:indexPath];
    if(view){
        NSInteger section = indexPath.section;
        NSInteger row = indexPath.row;
        NSInteger count = [self numberOfObjectsForSection:section];
        for(int i = count - 1;i >= row ; --i){
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:section];
            NSIndexPath* newIndexPath = [NSIndexPath indexPathForRow:i+1 inSection:section];
            id v = [_indexPathToViews objectForKey:indexPath];
            if(v){
                [_indexPathToViews setObject:v forKey:newIndexPath];
                //NSLog(@"incrementIndexPathFrom -- controller <%p> _indexPathToViews set view : <%p> at indexPath : %@",self,v,newIndexPath);
                [_viewsToIndexPath setObject:newIndexPath forKey:v];
                [_indexPathToViews removeObjectForKey:indexPath];
                //NSLog(@"incrementIndexPathFrom -- controller <%p> _indexPathToViews removes view : <%p> at indexPath : %@",self,view,indexPath);
            }
        }
    }
}

- (void)objectController:(id)controller insertObject:(id)object atIndexPath:(NSIndexPath*)indexPath{
    [self incrementIndexPathFrom:indexPath];
	[self onInsertObjects:[NSArray arrayWithObject:object] atIndexPaths:[NSArray arrayWithObject:indexPath]];
}

- (void)objectController:(id)controller removeObject:(id)object atIndexPath:(NSIndexPath*)indexPath{
	[self onRemoveObjects:[NSArray arrayWithObject:object] atIndexPaths:[NSArray arrayWithObject:indexPath]];
}

- (void)objectController:(id)controller insertObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths{
    for(NSIndexPath* indexPath in indexPaths){
        [self incrementIndexPathFrom:indexPath];
    }
	[self onInsertObjects:objects atIndexPaths:indexPaths];
}

- (void)objectController:(id)controller removeObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths{
	[self onRemoveObjects:objects atIndexPaths:indexPaths];
}

- (void)objectController:(id)controller insertSectionAtIndex:(NSInteger)index{
	[self onInsertSectionAtIndex:index];
}

- (void)objectController:(id)controller removeSectionAtIndex:(NSInteger)index{
	[self onRemoveSectionAtIndex:index];
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

- (void)onInsertSectionAtIndex:(NSInteger)index{
	//To implement in inherited class
}

- (void)onRemoveSectionAtIndex:(NSInteger)index{
	//To implement in inherited class
}

- (CKFeedSource*)collectionDataSource{
	if([self.objectController isKindOfClass:[CKDocumentCollectionController class]]){
		CKDocumentCollectionController* documentController = (CKDocumentCollectionController*)self.objectController;
		return documentController.collection.feedSource;
	}
	return nil;
}

@end
