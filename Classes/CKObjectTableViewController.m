//
//  RootViewController.m
//  FeedView
//
//  Created by Sebastien Morel on 11-03-16.
//  Copyright Wherecloud 2011. All rights reserved.
//

#import "CKObjectTableViewController.h"
#import <CloudKit/CKNSDateAdditions.h>
#import <CloudKit/CKTableViewCellController.h>
#import <objc/runtime.h>
#import <CloudKit/CKUIKeyboardInformation.h>
#import <QuartzCore/QuartzCore.h>
#import <CloudKit/MAZeroingWeakRef.h>

//

@interface CKObjectTableViewController ()
@property (nonatomic, retain) NSMutableDictionary* cellsToControllers;
@property (nonatomic, retain) NSMutableDictionary* cellsToIndexPath;
@property (nonatomic, retain) NSMutableDictionary* indexPathToCells;
@property (nonatomic, retain) NSMutableArray* weakCells;
@end

//

@implementation CKObjectTableViewController
@synthesize objectController = _objectController;
@synthesize cellsToControllers = _cellsToControllers;
@synthesize controllerFactory = _controllerFactory;
@synthesize cellsToIndexPath = _cellsToIndexPath;
@synthesize indexPathToCells = _indexPathToCells;
@synthesize weakCells = _weakCells;
@synthesize currentPage = _currentPage;
@synthesize numberOfObjectsToprefetch = _numberOfObjectsToprefetch;
@synthesize orientation = _orientation;
@synthesize resizeOnKeyboardNotification = _resizeOnKeyboardNotification;
@synthesize scrolling = _scrolling;

- (void)postInit{
	_orientation = CKTableViewOrientationPortrait;
	_resizeOnKeyboardNotification = YES;
	_currentPage = 0;
	_scrolling = NO;
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

- (id)initWithObjectController:(id)controller withControllerFactory:(CKObjectViewControllerFactory*)factory{
	[self init];
	self.objectController = controller;
	self.controllerFactory = factory;
	
	if([controller conformsToProtocol:@protocol(CKObjectController)]){
		if([controller respondsToSelector:@selector(setDelegate:)]){
			[controller performSelector:@selector(setDelegate:) withObject:self];
		}
	}
	[self postInit];
	return self;
}


- (void)dealloc {
	[_objectController release];
	_objectController = nil;
	[_cellsToControllers release];
	_cellsToControllers = nil;
	[_controllerFactory release];
	_controllerFactory = nil;
	[_cellsToIndexPath release];
	_cellsToIndexPath = nil;
	[_indexPathToCells release];
	_indexPathToCells = nil;
	[_weakCells release];
	_weakCells = nil;
    [super dealloc];
}

- (void)setObjectController:(id)controller{
	if(_objectController && [_objectController conformsToProtocol:@protocol(CKObjectController)]){
		if([_objectController respondsToSelector:@selector(setDelegate:)]){
			[_objectController performSelector:@selector(setDelegate:) withObject:nil];
		}
	}
	
	if([_controllerFactory respondsToSelector:@selector(setObjectController:)]){
		[_controllerFactory performSelector:@selector(setObjectController:) withObject:nil];
	}
	
	[_objectController release];
	_objectController = [controller retain];
	
	if(controller && [controller conformsToProtocol:@protocol(CKObjectController)]){
		if([controller respondsToSelector:@selector(setDelegate:)]){
			[controller performSelector:@selector(setDelegate:) withObject:self];
		}
	}
	
	if([_controllerFactory respondsToSelector:@selector(setObjectController:)]){
		[_controllerFactory performSelector:@selector(setObjectController:) withObject:_objectController];
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

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
}

#pragma mark Orientation Management
- (void)adjustViewToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
	CGRect b = self.view.bounds;
	BOOL needRotation = (_orientation == CKTableViewOrientationLandscape);
	if(needRotation) {
		self.view.transform = CGAffineTransformMakeRotation(-M_PI/2);
	} else {
		self.view.transform = CGAffineTransformIdentity;
	}
	self.view.frame = CGRectMake(0,0,b.size.width - 10,b.size.height-10);
}

- (void)setOrientation:(CKTableViewOrientation)orientation {
	_orientation = orientation;
	[self adjustViewToInterfaceOrientation:self.interfaceOrientation];
}
   
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	//[self adjustViewToInterfaceOrientation:interfaceOrientation];
	return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
	_indexPathToReachAfterRotation = nil;
	NSArray* visible = [self.tableView indexPathsForVisibleRows];
	for(NSIndexPath* indexPath in visible){
		CGRect f = [self.tableView rectForRowAtIndexPath:indexPath];
		if(f.origin.y >= self.tableView.contentOffset.y){
			_indexPathToReachAfterRotation = indexPath;
			break;
		}
	}
	
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	
	if(_indexPathToReachAfterRotation){
		[self.tableView scrollToRowAtIndexPath:_indexPathToReachAfterRotation atScrollPosition:UITableViewScrollPositionTop animated:NO];
	}
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration{
	if(_indexPathToReachAfterRotation){
		[self.tableView scrollToRowAtIndexPath:_indexPathToReachAfterRotation atScrollPosition:UITableViewScrollPositionTop animated:NO];
	}
	[super willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:duration];
	for(NSValue* cellValue in [_cellsToControllers allKeys]){
		CKTableViewCellController* controller = [_cellsToControllers objectForKey:cellValue];
		UITableViewCell* cell = [cellValue nonretainedObjectValue];
		
		if([controller respondsToSelector:@selector(rotateCell:withParams:animated:)]){
			
			NSMutableDictionary* params = [NSMutableDictionary dictionary];
			[params setObject:[NSValue valueWithCGSize:self.tableView.bounds.size] forKey:CKTableViewAttributeBounds];
			[params setObject:[NSNumber numberWithInt:interfaceOrientation] forKey:CKTableViewAttributeInterfaceOrientation];
			[params setObject:[NSNumber numberWithBool:self.tableView.pagingEnabled] forKey:CKTableViewAttributePagingEnabled];
			[params setObject:[NSNumber numberWithInt:self.orientation] forKey:CKTableViewAttributeOrientation];
			[params setObject:[NSNumber numberWithDouble:duration] forKey:CKTableViewAttributeAnimationDuration];
			
			[controller rotateCell:cell withParams:params animated:YES];
		}
	}
}

#pragma mark UITableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if([_objectController conformsToProtocol:@protocol(CKObjectController)]){
		if([_objectController respondsToSelector:@selector(numberOfSections)]){
			return [_objectController numberOfSections];
		}
	}
	return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if([_objectController conformsToProtocol:@protocol(CKObjectController)]){
		if([_objectController respondsToSelector:@selector(numberOfObjectsForSection:)]){
			return [_objectController numberOfObjectsForSection:section];
		}
	}
	return 0;
}

- (CKTableViewCellController*)controllerForRowAtIndexPath:(NSIndexPath *)indexPath{
	UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
	if(cell){
		return (CKTableViewCellController*)[_cellsToControllers objectForKey:[NSValue valueWithNonretainedObject:cell]];
	}
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat height = 0;
	if([_objectController conformsToProtocol:@protocol(CKObjectController)]){
		if([_objectController respondsToSelector:@selector(objectAtIndexPath:)]){
			id object = [_objectController objectAtIndexPath:indexPath];
			
			Class controllerClass = [_controllerFactory controllerClassForIndexPath:indexPath];
			if(controllerClass && [controllerClass respondsToSelector:@selector(rowSizeForObject:withParams:)]){
				
				NSMutableDictionary* params = [NSMutableDictionary dictionary];
				[params setObject:[NSValue valueWithCGSize:self.tableView.bounds.size] forKey:CKTableViewAttributeBounds];
				[params setObject:[NSNumber numberWithInt:self.interfaceOrientation] forKey:CKTableViewAttributeInterfaceOrientation];
				[params setObject:[NSNumber numberWithBool:self.tableView.pagingEnabled] forKey:CKTableViewAttributePagingEnabled];
				[params setObject:[NSNumber numberWithInt:self.orientation] forKey:CKTableViewAttributeOrientation];
				
				NSValue* v = (NSValue*) [controllerClass performSelector:@selector(rowSizeForObject:withParams:) withObject:object withObject:params];
				CGSize size = [v CGSizeValue];
				height = (_orientation == CKTableViewOrientationLandscape) ? size.width : size.height;
			}
		}
	}
	
	return (height < 0) ? 0 : ((height == 0) ? tableView.rowHeight : height);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if([_objectController conformsToProtocol:@protocol(CKObjectController)]){
		if([_objectController respondsToSelector:@selector(objectAtIndexPath:)]){
			id object = [_objectController objectAtIndexPath:indexPath];
			
			Class controllerClass = [_controllerFactory controllerClassForIndexPath:indexPath];
			if(controllerClass){
				NSString* identifier = [NSString stringWithUTF8String:class_getName(controllerClass)];
				
				UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
				CKTableViewCellController* controller = nil;
				if(cell == nil){
					controller = [[[controllerClass alloc]init]autorelease];
					[controller setControllerStyle:[_controllerFactory styleForIndexPath:indexPath]];
					cell = [controller loadCell];
					
					//Register cell to controller
					if(_cellsToControllers == nil){
						self.cellsToControllers = [NSMutableDictionary dictionary];
					}
					
					MAZeroingWeakRef* cellRef = [[[MAZeroingWeakRef alloc]initWithTarget:cell]autorelease];
					[cellRef setCleanupBlock:^(id target){
						NSIndexPath* previousPath = [_cellsToIndexPath objectForKey:[NSValue valueWithNonretainedObject:target]];
						[_indexPathToCells removeObjectForKey:previousPath];
						
						[_cellsToControllers removeObjectForKey:[NSValue valueWithNonretainedObject:target]];
						[_weakCells removeObject:cellRef];
					}];
					[_weakCells addObject:cellRef];
					[_cellsToControllers setObject:controller forKey:[NSValue valueWithNonretainedObject:cell]];
				}
				else{
					NSIndexPath* previousPath = [_cellsToIndexPath objectForKey:[NSValue valueWithNonretainedObject:cell]];
					[_indexPathToCells removeObjectForKey:previousPath];
					
					NSAssert(_cellsToControllers != nil,@"Should have been created");
					controller = (CKTableViewCellController*)[_cellsToControllers objectForKey:[NSValue valueWithNonretainedObject:cell]];
				}
				
				
				[controller performSelector:@selector(setParentController:) withObject:self];
				[controller performSelector:@selector(setIndexPath:) withObject:indexPath];
				[controller performSelector:@selector(setTableViewCell:) withObject:cell];
				
				[_controllerFactory initializeController:controller atIndexPath:indexPath];
				
				if(_cellsToIndexPath == nil){
					self.cellsToIndexPath = [NSMutableDictionary dictionary];
				}
				[_cellsToIndexPath setObject:indexPath forKey:[NSValue valueWithNonretainedObject:cell]];
				if(_indexPathToCells == nil){
					self.indexPathToCells = [NSMutableDictionary dictionary];
				}
				[_indexPathToCells setObject:[NSValue valueWithNonretainedObject:cell] forKey:indexPath];
				
				if(![controller.value isEqual:object]){
					[controller setValue:object];
					[controller setupCell:cell];	
					
					NSString* objectType = [NSString stringWithUTF8String:class_getName([object class])];
				}
				
				if([controller respondsToSelector:@selector(rotateCell:withParams:animated:)]){
					NSMutableDictionary* params = [NSMutableDictionary dictionary];
					[params setObject:[NSValue valueWithCGSize:self.tableView.bounds.size] forKey:CKTableViewAttributeBounds];
					[params setObject:[NSNumber numberWithInt:self.interfaceOrientation] forKey:CKTableViewAttributeInterfaceOrientation];
					[params setObject:[NSNumber numberWithBool:self.tableView.pagingEnabled] forKey:CKTableViewAttributePagingEnabled];
					[params setObject:[NSNumber numberWithInt:self.orientation] forKey:CKTableViewAttributeOrientation];
					[controller rotateCell:cell withParams:params animated:NO];
				}	
				
				UIView *rotatedView	= cell.contentView;
				if (_orientation == CKTableViewOrientationLandscape) {
					rotatedView.transform = CGAffineTransformMakeRotation(M_PI/2);
				}
				
				if([_objectController respondsToSelector:@selector(fetchRange:forSection:)]){
					int numberOfRows = [self tableView:self.tableView numberOfRowsInSection:indexPath.section];
					if(_numberOfObjectsToprefetch + indexPath.row > numberOfRows){
						//int count = (_numberOfObjectsToprefetch + indexPath.row) - numberOfRows;
						//[_objectController fetchRange:NSMakeRange(numberOfRows, count) forSection:indexPath.section];
						[_objectController fetchRange:NSMakeRange(numberOfRows, _numberOfObjectsToprefetch) forSection:indexPath.section];
					}
				}
				
				return cell;
			}
		}
	}
	
	return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
	CKTableViewCellController* controller = (CKTableViewCellController*)[_cellsToControllers objectForKey:[NSValue valueWithNonretainedObject:cell]];
	if(controller){
		[controller cellDidAppear:cell];
	}
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	CKTableViewCellController* controller = [self controllerForRowAtIndexPath:indexPath];
	return (controller != nil) ? [controller willSelectRow] : nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	CKTableViewCellController* controller = [self controllerForRowAtIndexPath:indexPath];
	if(controller != nil){
		[controller didSelectRow];
	}
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	CKTableViewCellController* controller = [self controllerForRowAtIndexPath:indexPath];
	return (controller != nil && controller.isRemovable) ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete){
		if([_objectController conformsToProtocol:@protocol(CKObjectController)]){
			if([_objectController respondsToSelector:@selector(removeObjectAtIndexPath:)]){
				[_objectController removeObjectAtIndexPath:indexPath];
			}
		}
	}
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	CKTableViewCellController* controller = [self controllerForRowAtIndexPath:indexPath];
	return (controller != nil) ? controller.isEditable : NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	CKTableViewCellController* controller = [self controllerForRowAtIndexPath:indexPath];
	return (controller != nil) ? controller.isMovable : NO;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
	if([_objectController conformsToProtocol:@protocol(CKObjectController)]){
		if([_objectController respondsToSelector:@selector(targetIndexPathForMoveFromRowAtIndexPath:toProposedIndexPath:)]){
			return [_objectController targetIndexPathForMoveFromRowAtIndexPath:sourceIndexPath toProposedIndexPath:proposedDestinationIndexPath];
		}
	}
	return [NSIndexPath indexPathForRow:0 inSection:-1];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	if([_objectController conformsToProtocol:@protocol(CKObjectController)]){
		if([_objectController respondsToSelector:@selector(moveObjectFromIndexPath:toIndexPath:)]){
			[_objectController moveObjectFromIndexPath:fromIndexPath toIndexPath:toIndexPath];
		}
	}
}

#pragma mark CKFeedDataSourceDelegate

- (void)objectControllerDidBeginUpdating:(id)controller{
	[self.tableView beginUpdates];
}

- (void)objectControllerDidEndUpdating:(id)controller{
	[self.tableView endUpdates];
}

- (void)objectController:(id)controller insertObject:(id)object atIndexPath:(NSIndexPath*)indexPath{
	[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)objectController:(id)controller removeObject:(id)object atIndexPath:(NSIndexPath*)indexPath{
	[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark UITableView Protocol for Sections

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if([_objectController conformsToProtocol:@protocol(CKObjectController) ]){
		if([_objectController respondsToSelector:@selector(headerTitleForSection:)]){
			return [_objectController headerTitleForSection:section];
		}
	}
	return @"";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	//TODO : ask to _feedDataSource ???
	return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if([_objectController conformsToProtocol:@protocol(CKObjectController) ]){
		if([_objectController respondsToSelector:@selector(headerTitleForSection:)]){
			if( [_objectController headerTitleForSection:section] != nil ){
				return 30;
			}
		}
	}
	return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	//TODO : ask to _feedDataSource ???
	return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	//TODO : ask to _feedDataSource ???
	return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	//TODO : ask to _feedDataSource ???
	return nil;
}


#pragma mark Keyboard Notifications

- (void)keyboardWillShow:(NSNotification *)notification {
	if (_resizeOnKeyboardNotification == NO) return;
	
	NSDictionary *info = [notification userInfo];
	CGRect keyboardRect = CKUIKeyboardInformationBounds(info);
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:CKUIKeyboardInformationAnimationDuration(info)];
	[UIView setAnimationCurve:CKUIKeyboardInformationAnimationCurve(info)];
	CGRect tableViewFrame = self.tableView.frame;
	tableViewFrame.size.height -= keyboardRect.size.height;
	self.tableView.frame = tableViewFrame;
	[UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification {
	if (_resizeOnKeyboardNotification == NO) return;
	
	NSDictionary *info = [notification userInfo];
	CGRect keyboardRect = CKUIKeyboardInformationBounds(info);
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:CKUIKeyboardInformationAnimationDuration(info)];
	[UIView setAnimationCurve:CKUIKeyboardInformationAnimationCurve(info)];
	CGRect tableViewFrame = self.tableView.frame;
	tableViewFrame.size.height += keyboardRect.size.height;
	self.tableView.frame = tableViewFrame;
	[UIView commitAnimations];
}

#pragma mark Paging 

- (void)setCurrentPage:(int)page{
	_currentPage = page;
	NSLog(@"currentPage = %d",_currentPage);
	//TODO : scroll to the right controller ???
}

//Scroll callbacks : update self.currentPage
- (void)updateCurrentPage{
	CGFloat scrollPosition = self.tableView.contentOffset.y;
	CGFloat width = self.tableView.bounds.size.height;
	int page = (width != 0) ? scrollPosition / width : 0;
	if(page < 0) page = 0;
	
	if(_currentPage != page){
		self.currentPage = page;
	}
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView{
	[self updateCurrentPage];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	[self updateCurrentPage];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
	[self updateCurrentPage];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
	[self updateCurrentPage];
}

@end