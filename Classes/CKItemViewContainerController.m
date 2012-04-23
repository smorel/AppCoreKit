//
//  CKItemViewContainerController.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-05-25.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKItemViewContainerController.h"

#import "CKWeakRef.h"
#import "CKFormTableViewController.h"

//private interfaces

@interface CKItemViewController()
@property (nonatomic, copy, readwrite) NSIndexPath *indexPath;
@property (nonatomic, assign, readwrite) CKItemViewContainerController* containerController;
@end

@interface CKItemViewContainerController ()

@property (nonatomic, retain) NSMutableDictionary* viewsToControllers;
@property (nonatomic, retain) NSMutableDictionary* viewsToIndexPath;
@property (nonatomic, retain) NSMutableDictionary* indexPathToViews;
@property (nonatomic, retain) NSMutableArray* weakViews;
@property (nonatomic, retain) NSMutableArray* sectionsToControllers;

@property (nonatomic, assign) BOOL rotating;

@end

@interface CKItemViewControllerFactory ()

- (CKItemViewControllerFactoryItem*)factoryItemAtIndexPath:(NSIndexPath*)indexPath;
- (id)controllerForObject:(id)object atIndexPath:(NSIndexPath*)indexPath;

@end


@interface CKItemViewContainerController(CKItemViewControllerManagement)
- (void) createsItemViewControllers;
- (void) insertItemViewControllersForObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths;
- (void) removeItemViewControllersForObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths;
- (void) updateItemViewControllersVisibleViewsIndexPath;
- (void) updateItemViewControllersVisibility:(BOOL)visible;
- (CKItemViewController*) itemViewControllerAtIndexPath:(NSIndexPath*)indexPath;
- (void) insertItemViewControllersSectionAtIndex:(NSInteger)index;
- (void) removeItemViewControllersSectionAtIndex:(NSInteger)index;
@end

//CKItemViewContainerController

@implementation CKItemViewContainerController

@synthesize objectController = _objectController;
@synthesize controllerFactory = _controllerFactory;
@synthesize viewsToControllers = _viewsToControllers;
@synthesize viewsToIndexPath = _viewsToIndexPath;
@synthesize indexPathToViews = _indexPathToViews;
@synthesize weakViews = _weakViews;
@synthesize delegate = _delegate;
@synthesize numberOfObjectsToprefetch = _numberOfObjectsToprefetch;
@synthesize sectionsToControllers = _sectionsToControllers;
@synthesize rotating = _rotating;


#pragma mark Initialization
- (void)postInit {
	[super postInit];
	_numberOfObjectsToprefetch = 10;
    _rotating = NO;
}

- (id)init {
	self = [super init];
	if (self) {
	}
	return self;
}

- (id)initWithCollection:(CKCollection*)collection factory:(CKItemViewControllerFactory*)factory{
    CKCollectionController* controller = [[[CKCollectionController alloc]initWithCollection:collection]autorelease];
	return [self initWithObjectController:controller factory:factory];
}

- (id)initWithObjectController:(id)controller factory:(CKItemViewControllerFactory*)factory{
    self = [self init];
	self.objectController = controller;
	self.controllerFactory = factory;
	return self;
}


- (void)setupWithCollection:(CKCollection*)collection factory:(CKItemViewControllerFactory*)factory{
	self.controllerFactory = factory;
    self.objectController = [[[CKCollectionController alloc]initWithCollection:collection]autorelease];
}

- (void)dealloc {
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
    [_sectionsToControllers release];
    _sectionsToControllers = nil;
	
	[super dealloc];
}

#pragma mark ObjectController/ FactoryController initialization


- (void)reload{
    [self createsItemViewControllers];
    [self onReload];
}

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
	
	if(([self state] & CKUIViewControllerStateDidAppear) && [controller respondsToSelector:@selector(setDelegate:)]){
		[controller performSelector:@selector(setDelegate:) withObject:self];
        [self reload];
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
    self.rotating = YES;
    
    if([self isKindOfClass:[CKTableViewController class]]){
        //Invalidate all controller's size !
        for(int i =0; i< [self numberOfSections];++i){
            for(int j=0;j<[self numberOfObjectsForSection:i];++j){
                NSIndexPath* indexPath = [NSIndexPath indexPathForRow:j inSection:i];
                CKTableViewCellController* controller = (CKTableViewCellController*)[self controllerAtIndexPath:indexPath];
                controller.invalidatedSize = YES;
            }
        }
    }
    
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration{
	[super willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:duration];
	[self updateVisibleViewsRotation];
	[self updateViewsVisibility:YES];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
	[self updateViewsVisibility:YES];
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    self.rotating = NO;
}


#pragma mark Visible views management

- (void)updateVisibleViewsRotation{
	NSArray *visibleIndexPaths = [self visibleIndexPaths];
	for (NSIndexPath *indexPath in visibleIndexPaths) {
		CKItemViewController* controller = [self controllerAtIndexPath:indexPath];
		if([controller respondsToSelector:@selector(rotateView:animated:)]){
			[controller rotateView:controller.view animated:YES];
		}
	}	
}

//Update the indexPath of the visible controllers as they could have moved.
- (void)updateVisibleViewsIndexPath{
    for(CKWeakRef* weakView in self.weakViews){
        UIView* view = weakView.object;
        if(view && [view superview] != nil){
            //indexPathForView is overloaded to point on the real views and not out reference maps
            //by using this method, we're "sure" to retrieve the right indexPath corresponding to an item view.
            NSIndexPath* indexPath = [self indexPathForView:view];
            if(indexPath){
                NSValue* weakViewValue = [NSValue valueWithNonretainedObject:view];
                [self.viewsToIndexPath setObject:indexPath forKey:weakViewValue];
                [self.indexPathToViews setObject:weakViewValue forKey:indexPath];
            }
        }
    }
    
    [self updateItemViewControllersVisibleViewsIndexPath];
}

- (void)updateViewsVisibility:(BOOL)visible{
    [self updateItemViewControllersVisibility:visible];
}

#pragma mark IndexPath/View/Controller management

- (CKItemViewController*)controllerAtIndexPath:(NSIndexPath *)indexPath{
    return [self itemViewControllerAtIndexPath:indexPath];
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
    CKItemViewController* controller = [self controllerAtIndexPath:indexPath];
    return controller.size;
}

- (CKItemViewFlags)flagsForViewAtIndexPath:(NSIndexPath*)indexPath{
    CKItemViewController* controller = [self controllerAtIndexPath:indexPath];
    return controller.flags;
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
    BOOL appendCollectionCellControllerAsFooterCell = NO;
    if([_objectController respondsToSelector:@selector(appendCollectionCellControllerAsFooterCell)]){
        appendCollectionCellControllerAsFooterCell = [_objectController appendCollectionCellControllerAsFooterCell];
    }
	int numberOfRows = [self numberOfObjectsForSection:indexPath.section] - (appendCollectionCellControllerAsFooterCell ? 1 : 0);
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
		
        CKItemViewController* controller = [self controllerAtIndexPath:indexPath];
        NSString* identifier = [controller identifier];
        UIView *view = [self dequeueReusableViewWithIdentifier:identifier];
        
        if(!_sectionsToControllers){
            self.sectionsToControllers = [NSMutableArray array];
        }
        
        [controller setValue:object];
        [controller performSelector:@selector(setContainerController:) withObject:self];
        [controller performSelector:@selector(setIndexPath:) withObject:indexPath];
        
        if(view == nil){
            view = [controller loadView];
            view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            
            //Register cell to controller
            if(_weakViews == nil){ self.weakViews = [NSMutableArray array]; }
            
            CKWeakRef* viewRef = [CKWeakRef weakRefWithObject:view target:self action:@selector(releaseView:)];
            [_weakViews addObject:viewRef];
        }
        else{
            //Reset state
            CKItemViewController* previousController = [_viewsToControllers objectForKey:[NSValue valueWithNonretainedObject:view]];
            if(previousController && [previousController view] == view){
                [previousController setView:nil];
            }
            
            NSIndexPath* previousPath = [_viewsToIndexPath objectForKey:[NSValue valueWithNonretainedObject:view]];
            if(previousPath){
                [_indexPathToViews removeObjectForKey:previousPath];
                [_viewsToIndexPath removeObjectForKey:[NSValue valueWithNonretainedObject:view]];
            }
        }
        
        if(_viewsToControllers == nil){ self.viewsToControllers = [NSMutableDictionary dictionary]; }
        [_viewsToControllers setObject:controller forKey:[NSValue valueWithNonretainedObject:view]];
        
        NSAssert(view != nil,@"The view has not been created");
        
        [controller setView:view];
        
        if(_viewsToIndexPath == nil){ self.viewsToIndexPath = [NSMutableDictionary dictionary]; }
        [_viewsToIndexPath setObject:indexPath forKey:[NSValue valueWithNonretainedObject:view]];
        if(_indexPathToViews == nil){self.indexPathToViews = [NSMutableDictionary dictionary]; }
        [_indexPathToViews setObject:[NSValue valueWithNonretainedObject:view] forKey:indexPath];
        
        [controller setupView:view];	
        
        if(controller){
            [controller rotateView:view animated:NO];
        }
        return view;
    }
    else{
        NSAssert(NO,@"WTF");
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
	[self reload];
	
	//bad solution because the contentsize is updated at the end of insert animation ....
	//could be better if we could observe or be notified that the contentSize has changed.
	NSTimeInterval delay = 0.4;
	[self performSelector:@selector(updateViewsVisibility:) withObject:[NSNumber numberWithBool:YES] afterDelay:delay];
}

- (void)objectControllerDidBeginUpdating:(id)controller{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
	[self onBeginUpdates];
}

- (void)objectControllerDidEndUpdating:(id)controller{
	[self updateVisibleViewsIndexPath];
	[self onEndUpdates];
	
	//bad solution because the contentsize is updated at the end of insert animation ....
	//could be better if we could observe or be notified that the contentSize has changed.
	NSTimeInterval delay = 0.4;
	[self performSelector:@selector(updateViewsVisibility:) withObject:[NSNumber numberWithBool:YES] afterDelay:delay];
}

- (void)objectController:(id)controller insertObject:(id)object atIndexPath:(NSIndexPath*)indexPath{
	[self objectController:controller insertObjects:[NSArray arrayWithObject:object] atIndexPaths:[NSArray arrayWithObject:indexPath]];
}

- (void)objectController:(id)controller removeObject:(id)object atIndexPath:(NSIndexPath*)indexPath{
	[self objectController:controller removeObjects:[NSArray arrayWithObject:object] atIndexPaths:[NSArray arrayWithObject:indexPath]];
}

- (void)objectController:(id)controller insertObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths{
    [self insertItemViewControllersForObjects:objects atIndexPaths:indexPaths]; 
	[self onInsertObjects:objects atIndexPaths:indexPaths];
}

- (void)objectController:(id)controller removeObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths{
    [self removeItemViewControllersForObjects:objects atIndexPaths:indexPaths];    
	[self onRemoveObjects:objects atIndexPaths:indexPaths];
}

- (void)objectController:(id)controller insertSectionAtIndex:(NSInteger)index{
    [self insertItemViewControllersSectionAtIndex:index];   
	[self onInsertSectionAtIndex:index];
}

- (void)objectController:(id)controller removeSectionAtIndex:(NSInteger)index{
    [self removeItemViewControllersSectionAtIndex:index];   
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

- (void)onSizeChangeAtIndexPath:(NSIndexPath*)index{
	//To implement in inherited class
    NSAssert(NO,@"Implements this in tables by performing intelligently beginUpdate/endUpdate!");
}

- (CKFeedSource*)collectionDataSource{
	if([self.objectController isKindOfClass:[CKCollectionController class]]){
		CKCollectionController* documentController = (CKCollectionController*)self.objectController;
		return documentController.collection.feedSource;
	}
	return nil;
}

@end


//CKItemViewContainerController(CKItemViewControllerManagement)


/* All the methods manipulating itemViewControllers are grouped in this extension.
 This allow us to change the strategy by modifying the following methods.
 Yet, the itemViewControllers are all created when reloading the controller or inserting rows.
 They will get created on demand after inserting section ...
 
 It could be improved to create them on-demand by inserting NSNull objects in creates and insert methods, 
 and creating the controller only in itemViewControllerAtIndexPath method.
 */
@implementation CKItemViewContainerController(CKItemViewControllerManagement)

- (CKItemViewController*)itemViewControllerAtIndexPath:(NSIndexPath*)indexPath{
    if(_sectionsToControllers == nil){
        self.sectionsToControllers = [NSMutableArray array];
    }
    
    if([indexPath section] < [self.sectionsToControllers count]){
        NSMutableArray* controllers = [self.sectionsToControllers objectAtIndex:[indexPath section]];
        if([indexPath row] < [controllers count]){
            CKItemViewController* controller = [controllers objectAtIndex:[indexPath row]];
            return controller;
        }
    }
    
    id object = [self objectAtIndexPath:indexPath];
    CKItemViewController* controller = [_controllerFactory controllerForObject:object  atIndexPath:indexPath];
    if(!controller)
        return nil;
    
    [controller performSelector:@selector(setContainerController:) withObject:self];
    [controller performSelector:@selector(setValue:) withObject:object];
    [controller performSelector:@selector(setIndexPath:) withObject:indexPath];
    
    NSMutableArray* controllers = nil;
    if([indexPath section] < [self.sectionsToControllers count]){
        controllers = [self.sectionsToControllers objectAtIndex:[indexPath section]];
    }else{
        controllers = [NSMutableArray array];
        [self.sectionsToControllers insertObject:controllers atIndex:[indexPath section]];
    }
    [controllers insertObject:controller atIndex:[indexPath row]];
    
	return controller;
}

- (void) createsItemViewControllers{
    self.sectionsToControllers = [NSMutableArray array];
    
    //creates all viewControllers
    NSInteger sectionCount = [self numberOfSections];
    for(NSInteger section=0;section<sectionCount;++section){
        NSInteger rowCount = [self numberOfObjectsForSection:section];
        
        NSMutableArray* controllers = nil;
        if(section < [self.sectionsToControllers count]){
            controllers = [self.sectionsToControllers objectAtIndex:section];
        }else{
            controllers = [NSMutableArray array];
            [self.sectionsToControllers insertObject:controllers atIndex:section];
        }
        
        for(int row =0;row<rowCount;++row){
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            
            id object = [self objectAtIndexPath:indexPath];
            CKItemViewController* controller = [_controllerFactory controllerForObject:object  atIndexPath:indexPath];
            [controller performSelector:@selector(setContainerController:) withObject:self];
            [controller performSelector:@selector(setValue:) withObject:object];
            [controller performSelector:@selector(setIndexPath:) withObject:indexPath];
            
            [controllers insertObject:controller atIndex:[indexPath row]];
        }
    }
}
 
- (void) insertItemViewControllersForObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths{ 
    if(!_sectionsToControllers){
        self.sectionsToControllers = [NSMutableArray array];
    }
    
    for(NSInteger i = 0; i<[indexPaths count];++i){
        NSIndexPath* indexPath = [indexPaths objectAtIndex:i];
        NSIndexPath* object = [objects objectAtIndex:i];
        CKItemViewController* controller = [_controllerFactory controllerForObject:object  atIndexPath:indexPath];
        [controller performSelector:@selector(setContainerController:) withObject:self];
        [controller performSelector:@selector(setValue:) withObject:object];
        [controller performSelector:@selector(setIndexPath:) withObject:indexPath];
        
        NSMutableArray* controllers = nil;
        if([indexPath section] < [_sectionsToControllers count]){
            controllers = [_sectionsToControllers objectAtIndex:[indexPath section]];
        }else{
            controllers = [NSMutableArray array];
            [_sectionsToControllers insertObject:controllers atIndex:[indexPath section]];
        }
        [controllers insertObject:controller atIndex:[indexPath row]];
    }
}

- (void) removeItemViewControllersForObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths{ 
    if(!_sectionsToControllers){
        return;
    }
    
    NSMutableDictionary* indexsToRemove = [NSMutableDictionary dictionary];
    for(NSInteger i = 0; i<[indexPaths count];++i){
        NSIndexPath* indexPath = [indexPaths objectAtIndex:i];
        NSMutableIndexSet* indexSet = [indexsToRemove objectForKey:[NSNumber numberWithInt:[indexPath section]]];
        if(!indexSet){
            indexSet = [NSMutableIndexSet indexSet];
            [indexsToRemove setObject:indexSet forKey:[NSNumber numberWithInt:[indexPath section]]];
        }
        
        NSMutableArray* controllers = [self.sectionsToControllers objectAtIndex:[indexPath section]];
        if([indexPath row] < [controllers count]){
            [indexSet addIndex:[indexPath row]];
        }
    }
    
    for(NSNumber* section in [indexsToRemove allKeys]){
        NSIndexSet* indexes = [indexsToRemove objectForKey:section];
        if([section intValue] < [_sectionsToControllers count]){
            NSMutableArray* controllers = [_sectionsToControllers objectAtIndex:[section intValue]];
            [controllers removeObjectsAtIndexes:indexes];
        }
    }
}

- (void) insertItemViewControllersSectionAtIndex:(NSInteger)index{
    if(!_sectionsToControllers){
        self.sectionsToControllers = [NSMutableArray array];
    }
    [self.sectionsToControllers insertObject:[NSMutableArray array] atIndex:index];
}

- (void) removeItemViewControllersSectionAtIndex:(NSInteger)index{
    if(!_sectionsToControllers || index < 0 || index >= [_sectionsToControllers count]){
        return;
    }
    
    [self.sectionsToControllers removeObjectAtIndex:index];
}

- (void) updateItemViewControllersVisibleViewsIndexPath{
    for(NSInteger section=0;section<[self.sectionsToControllers count];++section){
        NSMutableArray* controllers = [self.sectionsToControllers objectAtIndex:section];
        for(int row =0;row<[controllers count];++row){
            CKItemViewController* controller = [controllers objectAtIndex:row];
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            [controller setIndexPath:indexPath];
        }
    }
}

- (void) updateItemViewControllersVisibility:(BOOL)visible{
    //We do not use controllerAtIndexPath here as we do not want to create any controllers in this method ...
	NSArray *visibleIndexPaths = [self visibleIndexPaths];
	for (NSIndexPath *indexPath in visibleIndexPaths) {
        if([indexPath section] < [self.sectionsToControllers count]){
            NSMutableArray* controllers = [self.sectionsToControllers objectAtIndex:[indexPath section]];
            if([indexPath row] < [controllers count]){
                CKItemViewController* controller = [controllers objectAtIndex:[indexPath row]];
                if([controller view]){
                    if(visible){
                        [controller viewDidAppear:controller.view];
                    }
                    else{
                        [controller viewDidDisappear];
                    }
                }
            }
        }
	}
}

@end
