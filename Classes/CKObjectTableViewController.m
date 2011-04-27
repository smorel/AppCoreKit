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
#import <CloudKit/CKNSObject+bindings.h>
#import "CKVersion.h"
#import "CKDocumentController.h"

//

@interface CKObjectTableViewController ()
@property (nonatomic, retain) NSMutableDictionary* cellsToControllers;
@property (nonatomic, retain) NSMutableDictionary* cellsToIndexPath;
@property (nonatomic, retain) NSMutableDictionary* indexPathToCells;
@property (nonatomic, retain) NSMutableArray* weakCells;
@property (nonatomic, retain) NSMutableDictionary* headerViewsForSections;
@property (nonatomic, retain) NSMutableDictionary* controllersForIdentifier;
@property (nonatomic, retain) NSMutableDictionary* params;
@property (nonatomic, retain) NSIndexPath* indexPathToReachAfterRotation;

- (void)updateNumberOfPages;
- (CKTableViewCellController*)controllerForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)notifiesCellControllersForVisibleRows;
- (void)adjustView;
- (void)adjustTableView;
- (void)rotateSubViewsForCell:(UITableViewCell*)cell;
- (NSString*)identifierForClass:(Class)theClass object:(id)object indexPath:(NSIndexPath*)indexPath;
- (void)updateParams;

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
@synthesize numberOfPages = _numberOfPages;
@synthesize numberOfObjectsToprefetch = _numberOfObjectsToprefetch;
@synthesize orientation = _orientation;
@synthesize resizeOnKeyboardNotification = _resizeOnKeyboardNotification;
@synthesize scrolling = _scrolling;
@synthesize editable = _editable;
@synthesize headerViewsForSections = _headerViewsForSections;
@synthesize indexPathToReachAfterRotation = _indexPathToReachAfterRotation;
@synthesize rowInsertAnimation = _rowInsertAnimation;
@synthesize rowRemoveAnimation = _rowRemoveAnimation;
@synthesize controllersForIdentifier = _controllersForIdentifier;
@synthesize params = _params;

@synthesize editButton;
@synthesize doneButton;

- (void)printDebug:(NSString*)txt{
	/*NSLog(@"%@",txt);
	NSLog(@"view frame=%f,%f,%f,%f",self.view.frame.origin.x,self.view.frame.origin.y,self.view.frame.size.width,self.view.frame.size.height);
	NSLog(@"tableView frame=%f,%f,%f,%f",self.tableView.frame.origin.x,self.tableView.frame.origin.y,self.tableView.frame.size.width,self.tableView.frame.size.height);
	NSLog(@"tableView contentOffset=%f,%f",self.tableView.contentOffset.x,self.tableView.contentOffset.y);
	NSLog(@"tableView contentSize=%f,%f",self.tableView.contentSize.width,self.tableView.contentSize.height);
	NSLog(@"interfaceOrientation=%@",UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? @"Portrait" : @"Landscape");
	
	for(NSValue* cellValue in [_cellsToControllers allKeys]){
		UITableViewCell* cell = [cellValue nonretainedObjectValue];
		NSLog(@"cell frame=%f,%f,%f,%f",cell.frame.origin.x,cell.frame.origin.y,cell.frame.size.width,cell.frame.size.height);
	}*/
}

- (void)loadView{
	[super loadView];
	
	//FIXME : the bindings here make the application crash. By commenting it we are not sure all the params are updated correctly ... (TO CHECK)
	
	/*[NSObject beginBindingsContext:[NSString stringWithFormat:@"%p_params",self] policy:CKBindingsContextPolicyRemovePreviousBindings];
	[self.tableView bind:@"frame" target:self action:@selector(updateParams)];
	[self bind:@"interfaceOrientation" target:self action:@selector(updateParams)];
	[self.tableView bind:@"pagingEnabled" target:self action:@selector(updateParams)];
	[self bind:@"orientation" target:self action:@selector(updateParams)];
	[NSObject endBindingsContext];*/
}

- (void)postInit{
	[super postInit];
	_rowInsertAnimation = UITableViewRowAnimationFade;
	_rowRemoveAnimation = UITableViewRowAnimationFade;
	_orientation = CKTableViewOrientationPortrait;
	_resizeOnKeyboardNotification = YES;
	_currentPage = 0;
	_numberOfPages = 0;
	_scrolling = NO;
	_editable = NO;
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
	return self;
}


- (void)dealloc {
	[NSObject removeAllBindingsForContext:[NSString stringWithFormat:@"%p_params",self]];
	[_indexPathToReachAfterRotation release];
	_indexPathToReachAfterRotation = nil;
	[_params release];
	_params = nil;
	[_controllersForIdentifier release];
	_controllersForIdentifier = nil;
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
	[editButton release];
	editButton = nil;
	[doneButton release];
	doneButton = nil;
	[_headerViewsForSections release];
	_headerViewsForSections = nil;
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

- (IBAction)edit:(id)sender{
	[self.navigationItem setLeftBarButtonItem:(self.navigationItem.leftBarButtonItem == self.editButton) ? self.doneButton : self.editButton animated:YES];
	[self setEditing: (self.navigationItem.leftBarButtonItem == self.editButton) ? NO : YES animated:YES];
}

- (void)updateParams{
	if(self.params == nil){
		[self.params setObject:[NSValue valueWithCGSize:self.view.bounds.size] forKey:CKTableViewAttributeBounds];
		[self.params setObject:[NSNumber numberWithInt:self.interfaceOrientation] forKey:CKTableViewAttributeInterfaceOrientation];
		[self.params setObject:[NSNumber numberWithBool:self.tableView.pagingEnabled] forKey:CKTableViewAttributePagingEnabled];
		[self.params setObject:[NSNumber numberWithInt:self.orientation] forKey:CKTableViewAttributeOrientation];
		[self.params setObject:[NSNumber numberWithDouble:0] forKey:CKTableViewAttributeAnimationDuration];
		[self.params setObject:[NSNumber numberWithBool:self.editable] forKey:CKTableViewAttributeEditable];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	if([_objectController respondsToSelector:@selector(setDelegate:)]){
		[_objectController performSelector:@selector(setDelegate:) withObject:self];
	}
	
    [super viewWillAppear:animated];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	
	if(_editable){
		self.editButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(edit:)]autorelease];
		self.doneButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(edit:)]autorelease];
		[self.navigationItem setLeftBarButtonItem:(self.editing) ? self.doneButton : self.editButton animated:animated];
	}
	
	if ([CKOSVersion() floatValue] < 3.2) {
		[self.tableView beginUpdates];
		[self.tableView endUpdates];
	}
	
	[self updateParams];
	
	for(NSValue* cellValue in [_cellsToControllers allKeys]){
		CKTableViewCellController* controller = [_cellsToControllers objectForKey:cellValue];
		UITableViewCell* cell = [cellValue nonretainedObjectValue];
		if([controller respondsToSelector:@selector(rotateCell:withParams:animated:)]){
			[controller rotateCell:cell withParams:self.params animated:YES];
			
			if ([CKOSVersion() floatValue] < 3.2) {
				[self rotateSubViewsForCell:cell];
			}
		}
	}	
	
	if ([CKOSVersion() floatValue] < 3.2) {
		[self adjustTableView];
	}
	
	if(_indexPathToReachAfterRotation){
		
		if (_indexPathToReachAfterRotation.row < [self.tableView numberOfRowsInSection:_indexPathToReachAfterRotation.section])
			[self.tableView scrollToRowAtIndexPath:_indexPathToReachAfterRotation atScrollPosition:UITableViewScrollPositionTop animated:NO];
		else 
			[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:_indexPathToReachAfterRotation.section] atScrollPosition:UITableViewScrollPositionTop animated:NO];
		
		self.indexPathToReachAfterRotation = nil;
	}
	
	[self updateNumberOfPages];
	[self printDebug:@"viewWillAppear"];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[self notifiesCellControllersForVisibleRows];
	[self printDebug:@"viewDidAppear"];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	if([_objectController respondsToSelector:@selector(setDelegate:)]){
		[_objectController performSelector:@selector(setDelegate:) withObject:nil];
	}
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	self.indexPathToReachAfterRotation = nil;
	
	NSArray *visibleCells = [self.tableView visibleCells];
	
	//NSArray* visible = [self.tableView indexPathsForVisibleRows];
	//for(NSIndexPath* indexPath in visible){
	for (UITableViewCell *cell in visibleCells) {
		NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
		CGRect f = [self.tableView rectForRowAtIndexPath:indexPath];
		if(f.origin.y >= self.tableView.contentOffset.y){
			self.indexPathToReachAfterRotation = indexPath;
			break;
		}
	}
	
	if(!_indexPathToReachAfterRotation && [visibleCells count] > 0){
		NSIndexPath *indexPath = [self.tableView indexPathForCell:[visibleCells objectAtIndex:0]];
		self.indexPathToReachAfterRotation = indexPath;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)notifiesCellControllersForVisibleRows {
	NSArray *visibleCells = [self.tableView visibleCells];
	for (UITableViewCell *cell in visibleCells) {
		NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
		[[self controllerForRowAtIndexPath:indexPath] cellDidAppear:cell];
	}
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath interfaceOrientation:(UIInterfaceOrientation)interfaceOrientation size:(CGSize)size{
	CGFloat height = 0;
	//if([_objectController conformsToProtocol:@protocol(CKObjectController)]){
		if([_objectController respondsToSelector:@selector(objectAtIndexPath:)]){
			id object = [_objectController objectAtIndexPath:indexPath];
			
			Class controllerClass = [_controllerFactory controllerClassForIndexPath:indexPath];
			if(controllerClass && [controllerClass respondsToSelector:@selector(rowSizeForObject:withParams:)]){
				NSValue* v = (NSValue*) [controllerClass performSelector:@selector(rowSizeForObject:withParams:) withObject:object withObject:self.params];
				CGSize size = [v CGSizeValue];
				//NSLog(@"Size for row : %d,%d =%f,%f",indexPath.row,indexPath.section,size.width,size.height);
				height = (_orientation == CKTableViewOrientationLandscape) ? size.width : size.height;
			}
		}
	//}
	
	NSIndexPath* toReach = [[_indexPathToReachAfterRotation copy]autorelease];
	if(_indexPathToReachAfterRotation && [_indexPathToReachAfterRotation isEqual:indexPath]){
		//that means the view is rotating and needs to be updated with the future cells size
		self.indexPathToReachAfterRotation = nil;
		CGFloat offset = 0;
		if(toReach.row > 0){
			CGRect r = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:toReach.row-1 inSection:toReach.section]];
			offset = r.origin.y + r.size.height;
		}
		else{
			CGRect r = [self.tableView rectForHeaderInSection:toReach.section];
			offset = r.origin.y + r.size.height;
		}
		self.indexPathToReachAfterRotation = toReach;
		self.tableView.contentOffset = CGPointMake(0,offset);
	}
	
	//NSLog(@"Height for row : %d,%d =%f",indexPath.row,indexPath.section,height);
	
	return (height < 0) ? 0 : ((height == 0) ? self.tableView.rowHeight : height);
}

#pragma mark Orientation Management
- (void)adjustView{
	if(_orientation == CKTableViewOrientationLandscape) {
		CGRect frame = self.view.frame;
		self.view.transform = CGAffineTransformMakeRotation(-M_PI/2);
		self.view.frame = frame;
	}
}


- (void)rotateSubViewsForCell:(UITableViewCell*)cell{
	if(_orientation == CKTableViewOrientationLandscape){
		UIView* view = cell.contentView;
		CGRect frame = view.frame;
		view.transform = CGAffineTransformMakeRotation(M_PI/2);
		
		if ([CKOSVersion() floatValue] < 3.2) {
			view.frame = frame;
			
			for(UIView* v in view.subviews){
				//UIViewAutoresizing resizingMasks = v.autoresizingMask;
				v.autoresizingMask = UIViewAutoresizingNone;
				v.center = CGPointMake(cell.contentView.bounds.size.width / 2,cell.contentView.bounds.size.height / 2);
				v.frame = cell.contentView.bounds;
				//v.autoresizingMask = resizingMasks; //reizing masks break the layout on os 3
			}
		}
	}
}

- (void)adjustTableView{
	[self adjustView];
	
	if(_orientation == CKTableViewOrientationLandscape) {
		self.tableView.autoresizingMask = UIViewAutoresizingNone;
		self.tableView.frame = CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height);
	}
	
	for(NSValue* cellValue in [_cellsToControllers allKeys]){
		UITableViewCell* cell = [cellValue nonretainedObjectValue];
		[self rotateSubViewsForCell:cell];
	}
}

- (void)setOrientation:(CKTableViewOrientation)orientation {
	_orientation = orientation;
	[self adjustView];
}
   
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
	//stop scrolling
	[self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y) animated:NO];
	
	self.indexPathToReachAfterRotation = nil;
	//NSArray* visible = [self.tableView indexPathsForVisibleRows];
	//for(NSIndexPath* indexPath in visible){
	NSArray *visibleCells = [self.tableView visibleCells];
	for (UITableViewCell *cell in visibleCells) {
		NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
		CGRect f = [self.tableView rectForRowAtIndexPath:indexPath];
		if(f.origin.y >= self.tableView.contentOffset.y){
			self.indexPathToReachAfterRotation = indexPath;
			break;
		}
	}
	if(!_indexPathToReachAfterRotation && [visibleCells count] > 0){
		NSIndexPath *indexPath = [self.tableView indexPathForCell:[visibleCells objectAtIndex:0]];
		self.indexPathToReachAfterRotation = indexPath;
	}
	
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	[self printDebug:@"end of willRotateToInterfaceOrientation"];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration{
	
	if ([CKOSVersion() floatValue] < 3.2) {
		[self adjustTableView];
	}
	[super willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:duration];
	
	if ([CKOSVersion() floatValue] < 3.2) {
		[self.tableView beginUpdates];
		[self.tableView endUpdates];
	}
	
	[self updateParams];
	for(NSValue* cellValue in [_cellsToControllers allKeys]){
		CKTableViewCellController* controller = [_cellsToControllers objectForKey:cellValue];
		UITableViewCell* cell = [cellValue nonretainedObjectValue];
		
		if([controller respondsToSelector:@selector(rotateCell:withParams:animated:)]){
			[self.params setObject:[NSNumber numberWithDouble:duration] forKey:CKTableViewAttributeAnimationDuration];
			[controller rotateCell:cell withParams:self.params animated:YES];
			
			if ([CKOSVersion() floatValue] < 3.2) {
				[self rotateSubViewsForCell:cell];
			}
		}
	}
	[self notifiesCellControllersForVisibleRows];
	[self printDebug:@"end of willAnimateRotationToInterfaceOrientation"];
}
 
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
	self.indexPathToReachAfterRotation = nil;
	[self notifiesCellControllersForVisibleRows];
	[self updateNumberOfPages];
	[self printDebug:@"end of didRotateFromInterfaceOrientation"];
}

#pragma mark UITableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	//if([_objectController conformsToProtocol:@protocol(CKObjectController)]){
		if([_objectController respondsToSelector:@selector(numberOfSections)]){
			return [_objectController numberOfSections];
		}
	//}
	return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	//if([_objectController conformsToProtocol:@protocol(CKObjectController)]){
		if([_objectController respondsToSelector:@selector(numberOfObjectsForSection:)]){
			return [_objectController numberOfObjectsForSection:section];
		}
	//}
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
	CGFloat height = [self heightForRowAtIndexPath:indexPath interfaceOrientation:self.interfaceOrientation size:self.view.bounds.size];
	return height;
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
		int numberOfRows = [self tableView:self.tableView numberOfRowsInSection:indexPath.section];
		if(_numberOfObjectsToprefetch + indexPath.row > numberOfRows){
			[_objectController fetchRange:NSMakeRange(numberOfRows, _numberOfObjectsToprefetch) forSection:indexPath.section];
		}
	}
}
- (void)releaseCell:(id)sender target:(id)target{
	NSIndexPath* previousPath = [_cellsToIndexPath objectForKey:[NSValue valueWithNonretainedObject:target]];
	[_indexPathToCells removeObjectForKey:previousPath];
	
	[_cellsToControllers removeObjectForKey:[NSValue valueWithNonretainedObject:target]];
	[_weakCells removeObject:sender];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	//if([_objectController conformsToProtocol:@protocol(CKObjectController)]){
		if([_objectController respondsToSelector:@selector(objectAtIndexPath:)]){
			id object = [_objectController objectAtIndexPath:indexPath];
			
			Class controllerClass = [_controllerFactory controllerClassForIndexPath:indexPath];
			if(controllerClass){
				NSString* identifier = [self identifierForClass:controllerClass object:object indexPath:indexPath];
				
				//NSLog(@"dequeuing cell for identifier:%@ adress=%p",identifier,identifier);
				UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
				CKTableViewCellController* controller = nil;
				if(cell == nil){
					//NSLog(@"creating cell for identifier:%@ adress=%p",identifier,identifier);
					controller = [[[controllerClass alloc]init]autorelease];
					[controller performSelector:@selector(setParentController:) withObject:self];
					[controller performSelector:@selector(setIndexPath:) withObject:indexPath];
					[controller setValue:object];
					
					cell = [controller loadCell];
					//NSLog(@"reuseIdentifier : %@ adress=%p",cell.reuseIdentifier,cell.reuseIdentifier);
					cell.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
					
					//Register cell to controller
					if(_cellsToControllers == nil){
						self.cellsToControllers = [NSMutableDictionary dictionary];
					}
					
					if(_weakCells == nil){
						self.weakCells = [NSMutableArray array];
					}
					
					MAZeroingWeakRef* cellRef = [[MAZeroingWeakRef alloc]initWithTarget:cell];
					[cellRef setDelegate:self action:@selector(releaseCell:target:)];
					[_weakCells addObject:cellRef];
					[_cellsToControllers setObject:controller forKey:[NSValue valueWithNonretainedObject:cell]];
					[cellRef release];
				}
				else{
					//NSLog(@"reusing cell for identifier:%@ adress=%p",identifier,identifier);
					NSIndexPath* previousPath = [_cellsToIndexPath objectForKey:[NSValue valueWithNonretainedObject:cell]];
					[_indexPathToCells removeObjectForKey:previousPath];
					
					NSAssert(_cellsToControllers != nil,@"Should have been created");
					controller = (CKTableViewCellController*)[_cellsToControllers objectForKey:[NSValue valueWithNonretainedObject:cell]];
				}
				
				NSAssert(cell != nil,@"The cell has not been created");
				
				/*if(self.editing){
					[self setEditing:YES animated:NO];
				}*/
				
				[controller performSelector:@selector(setParentController:) withObject:self];
				[controller performSelector:@selector(setIndexPath:) withObject:indexPath];
				[controller performSelector:@selector(setTableViewCell:) withObject:cell];
				
				
				if(_cellsToIndexPath == nil){
					self.cellsToIndexPath = [NSMutableDictionary dictionary];
				}
				[_cellsToIndexPath setObject:indexPath forKey:[NSValue valueWithNonretainedObject:cell]];
				if(_indexPathToCells == nil){
					self.indexPathToCells = [NSMutableDictionary dictionary];
				}
				[_indexPathToCells setObject:[NSValue valueWithNonretainedObject:cell] forKey:indexPath];
				
				[_controllerFactory initializeController:controller atIndexPath:indexPath];
				[controller setValue:object];
				[controller setupCell:cell];	
				
				[self fetchMoreIfNeededAtIndexPath:indexPath];
				[self updateNumberOfPages];
				
				if(controller && [controller respondsToSelector:@selector(rotateCell:withParams:animated:)]){
					[controller rotateCell:cell withParams:self.params animated:NO];
				}	
				
				//NSLog(@"cellForRowAtIndexPath:%d,%d",indexPath.row,indexPath.section);
				
				return cell;
			}
		}
	//}
	
	return nil;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
	//CKTableViewCellController* controller = [self controllerForRowAtIndexPath:indexPath];
	[self rotateSubViewsForCell:cell];
	[self updateNumberOfPages];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	CKTableViewCellFlags flags = [self flagsForRowAtIndexPath:indexPath];
	CKTableViewCellController* controller = [self controllerForRowAtIndexPath:indexPath];
	BOOL bo = flags & CKTableViewCellFlagSelectable;
	if(controller && bo){
		[controller willSelectRow];
	}
	return (bo) ? indexPath : nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	CKTableViewCellController* controller = [self controllerForRowAtIndexPath:indexPath];
	if(controller != nil){
		[controller didSelectRow];
	}
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	CKTableViewCellFlags flags = [self flagsForRowAtIndexPath:indexPath];
	BOOL bo = flags & CKTableViewCellFlagRemovable;
	return bo ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete){
		//if([_objectController conformsToProtocol:@protocol(CKObjectController)]){
			if([_objectController respondsToSelector:@selector(removeObjectAtIndexPath:)]){
				[_objectController removeObjectAtIndexPath:indexPath];
				[self fetchMoreIfNeededAtIndexPath:indexPath];
			}
		//}
	}
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	CKTableViewCellFlags flags = [self flagsForRowAtIndexPath:indexPath];
	BOOL bo = flags & CKTableViewCellFlagEditable;
	return bo;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	CKTableViewCellFlags flags = [self flagsForRowAtIndexPath:indexPath];
	BOOL bo = flags & CKTableViewCellFlagMovable;
	return bo;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
	//if([_objectController conformsToProtocol:@protocol(CKObjectController)]){
		if([_objectController respondsToSelector:@selector(targetIndexPathForMoveFromRowAtIndexPath:toProposedIndexPath:)]){
			return [_objectController targetIndexPathForMoveFromRowAtIndexPath:sourceIndexPath toProposedIndexPath:proposedDestinationIndexPath];
		}
	//}
	return [NSIndexPath indexPathForRow:0 inSection:-1];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	//if([_objectController conformsToProtocol:@protocol(CKObjectController)]){
		if([_objectController respondsToSelector:@selector(moveObjectFromIndexPath:toIndexPath:)]){
			[_objectController moveObjectFromIndexPath:fromIndexPath toIndexPath:toIndexPath];
		}
	//}
}

#pragma mark CKFeedDataSourceDelegate

- (void)objectControllerReloadData:(id)controller{
	[self.tableView reloadData];
	
	//bad solution because the contentsize is updated at the end of insert animation ....
	//could be better if we could observe or be notified that the contentSize has changed.
	NSTimeInterval delay = 0.4;
	[self performSelector:@selector(notifiesCellControllersForVisibleRows) withObject:nil afterDelay:delay];
}

- (void)objectControllerDidBeginUpdating:(id)controller{
	[self.tableView beginUpdates];
//	NSLog(@"beginUpdates");
}

- (void)objectControllerDidEndUpdating:(id)controller{
//	NSLog(@"endUpdates");
	[self.tableView endUpdates];
	
	//bad solution because the contentsize is updated at the end of insert animation ....
	//could be better if we could observe or be notified that the contentSize has changed.
	NSTimeInterval delay = 0.4;
	[self performSelector:@selector(updateNumberOfPages) withObject:nil afterDelay:delay];
	[self performSelector:@selector(notifiesCellControllersForVisibleRows) withObject:nil afterDelay:delay];
}

- (void)objectController:(id)controller insertObject:(id)object atIndexPath:(NSIndexPath*)indexPath{
	[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:_rowInsertAnimation];
}

- (void)objectController:(id)controller removeObject:(id)object atIndexPath:(NSIndexPath*)indexPath{
	[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:_rowRemoveAnimation];
}

#pragma mark UITableView Protocol for Sections

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	//if([_objectController conformsToProtocol:@protocol(CKObjectController) ]){
		if([_objectController respondsToSelector:@selector(headerTitleForSection:)]){
			return [_objectController headerTitleForSection:section];
		}
	//}
	return @"";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	//TODO : ask to _feedDataSource ???
	return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	CGFloat height = 0;
	UIView* view = [self tableView:self.tableView viewForHeaderInSection:section];
	if(view){
		height = view.frame.size.height;
	}
	
	if(height <= 0){
		//if([_objectController conformsToProtocol:@protocol(CKObjectController) ]){
			if([_objectController respondsToSelector:@selector(headerTitleForSection:)]){
				if( [_objectController headerTitleForSection:section] != nil ){
					height = 30;
				}
			}
		//}
	}
	return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	//TODO : ask to _feedDataSource ???
	return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
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
	//NSLog(@"currentPage = %d",_currentPage);
	//TODO : scroll to the right controller ???
}

- (void)setNumberOfPages:(int)pages{
	_numberOfPages = pages;
	//NSLog(@"number of pages = %d",_numberOfPages);
	//TODO : scroll to the right controller ???
}

//Scroll callbacks : update self.currentPage
- (void)updateCurrentPage{
	CGFloat scrollPosition = self.tableView.contentOffset.y;
	CGFloat height = self.tableView.bounds.size.height;
	int page = (height != 0) ? scrollPosition / height : 0;
	if(page < 0) 
		page = 0;
	
	if(_currentPage != page){
		self.currentPage = page;
	}
}

- (void)updateNumberOfPages{
	CGFloat totalSize = self.tableView.contentSize.height;
	CGFloat height = self.tableView.bounds.size.height;
	int pages = (height != 0) ? totalSize / height : 0;
	if(pages < 0) 
		pages = 0;
	
	if(_numberOfPages != pages){
		self.numberOfPages = pages;
	}
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView{
	[self updateCurrentPage];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	[self updateCurrentPage];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
	[self updateCurrentPage];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if (decelerate || scrollView.decelerating)
		return;
	[self notifiesCellControllersForVisibleRows];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	[self updateCurrentPage];
	[self notifiesCellControllersForVisibleRows];
}

@end