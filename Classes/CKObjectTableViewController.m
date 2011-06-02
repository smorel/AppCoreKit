//
//  RootViewController.m
//  FeedView
//
//  Created by Sebastien Morel on 11-03-16.
//  Copyright Wherecloud 2011. All rights reserved.
//

#import "CKObjectTableViewController.h"
#import <CloudKit/CKNSDateAdditions.h>
#import <objc/runtime.h>
#import <CloudKit/CKUIKeyboardInformation.h>
#import <QuartzCore/QuartzCore.h>
#import "CKVersion.h"
#import "CKDocumentController.h"
#import "CKTableViewCellController+StyleManager.h"
#import <CloudKit/CKNSObject+bindings.h>

//

@interface CKObjectTableViewController ()
@property (nonatomic, retain) NSMutableDictionary* headerViewsForSections;
@property (nonatomic, retain) NSIndexPath* indexPathToReachAfterRotation;
@property (nonatomic, retain) UISearchBar* searchBar;

- (void)updateNumberOfPages;
- (void)adjustView;
- (void)adjustTableView;

@end

//

@implementation CKObjectTableViewController
@synthesize currentPage = _currentPage;
@synthesize numberOfPages = _numberOfPages;
@synthesize numberOfObjectsToprefetch = _numberOfObjectsToprefetch;
@synthesize orientation = _orientation;
@synthesize resizeOnKeyboardNotification = _resizeOnKeyboardNotification;
@synthesize moveOnKeyboardNotification = _moveOnKeyboardNotification;
@synthesize scrolling = _scrolling;
@synthesize editable = _editable;
@synthesize headerViewsForSections = _headerViewsForSections;
@synthesize indexPathToReachAfterRotation = _indexPathToReachAfterRotation;
@synthesize rowInsertAnimation = _rowInsertAnimation;
@synthesize rowRemoveAnimation = _rowRemoveAnimation;
@synthesize searchEnabled = _searchEnabled;
@synthesize searchBar = _searchBar;
@synthesize liveSearchDelay = _liveSearchDelay;
@synthesize viewIsOnScreen = _viewIsOnScreen;

@synthesize editButton;
@synthesize doneButton;


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[self.searchBar resignFirstResponder];
	
	if ([searchBar.text isEqualToString:@""] == NO
		&& _delegate && [_delegate respondsToSelector:@selector(objectTableViewController:didSearch:)]) {
		[_delegate objectTableViewController:self didSearch:searchBar.text];
	}
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	if ([searchBar.text isEqualToString:@""] == YES
		&& _delegate && [_delegate respondsToSelector:@selector(objectTableViewController:didSearch:)]) {
		[_delegate objectTableViewController:self didSearch:@""];
	}
}

- (void)delayedSearchWithText:(NSString*)str{
	if (_delegate && [_delegate respondsToSelector:@selector(objectTableViewController:didSearch:)]) {
		[_delegate objectTableViewController:self didSearch:str];
	}
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	if(_liveSearchDelay > 0){
		[self performSelector:@selector(delayedSearchWithText:) withObject:searchBar.text afterDelay:_liveSearchDelay];
	}
}

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
	_moveOnKeyboardNotification = NO;
	_currentPage = 0;
	_numberOfPages = 0;
	_scrolling = NO;
	_editable = NO;
	_searchEnabled = NO;
	_liveSearchDelay = 0.5;
	_viewIsOnScreen = NO;
}

- (void)dealloc {
	//[NSObject removeAllBindingsForContext:[NSString stringWithFormat:@"%p_params",self]];
	[_indexPathToReachAfterRotation release];
	_indexPathToReachAfterRotation = nil;
	[editButton release];
	editButton = nil;
	[doneButton release];
	doneButton = nil;
	[_headerViewsForSections release];
	_headerViewsForSections = nil;
	[_searchBar release];
	_searchBar = nil;
    [super dealloc];
}

- (void)setObjectController:(id)controller{
	[super setObjectController:controller];
	if(_objectController != nil && [_objectController respondsToSelector:@selector(setDisplayFeedSourceCell:)]){
		[_objectController setDisplayFeedSourceCell:YES];
	}
}

- (IBAction)edit:(id)sender{
	[self.navigationItem setLeftBarButtonItem:(self.navigationItem.leftBarButtonItem == self.editButton) ? self.doneButton : self.editButton animated:YES];
	[self setEditing: (self.navigationItem.leftBarButtonItem == self.editButton) ? NO : YES animated:YES];
}

- (void)updateParams{
	if(self.params == nil){
		self.params = [NSMutableDictionary dictionary];
	}
	
	[self.params setObject:[NSValue valueWithCGSize:self.view.bounds.size] forKey:CKTableViewAttributeBounds];
	[self.params setObject:[NSNumber numberWithInt:self.interfaceOrientation] forKey:CKTableViewAttributeInterfaceOrientation];
	[self.params setObject:[NSNumber numberWithBool:self.tableView.pagingEnabled] forKey:CKTableViewAttributePagingEnabled];
	[self.params setObject:[NSNumber numberWithInt:self.orientation] forKey:CKTableViewAttributeOrientation];
	[self.params setObject:[NSNumber numberWithDouble:0] forKey:CKTableViewAttributeAnimationDuration];
	[self.params setObject:[NSNumber numberWithBool:self.editable] forKey:CKTableViewAttributeEditable];
	[self.params setObject:[NSValue valueWithNonretainedObject:self] forKey:CKTableViewAttributeParentController];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	if(self.searchEnabled && self.searchDisplayController == nil && _searchBar == nil){
		self.searchBar = [[[UISearchBar alloc]initWithFrame:CGRectMake(0,0,self.tableView.frame.size.width,44)]autorelease];
		_searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		_searchBar.delegate = self;
		//self.tableView.tableHeaderView = _searchBar;
		[self.view addSubview:_searchBar];
		
		if(self.tableViewContainer.frame.origin.y < 44){
			self.tableViewContainer.frame = CGRectMake(self.tableViewContainer.frame.origin.x,self.tableViewContainer.frame.origin.y + 44,
													   self.tableViewContainer.frame.size.width,self.tableViewContainer.frame.size.height - 44);
		}
		
		[[[UISearchDisplayController alloc]initWithSearchBar:_searchBar contentsController:self]autorelease];
	}		
	
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
	[self updateVisibleViewsRotation];
	
	if ([CKOSVersion() floatValue] < 3.2) {
		[self adjustTableView];
	}
	
	if(_indexPathToReachAfterRotation){
		//adjust _indexPathToReachAfterRotation to the nearest valid indexpath
		NSInteger currentRow = _indexPathToReachAfterRotation.row;
		NSInteger currentSection = _indexPathToReachAfterRotation.section;
		NSInteger rowCount = [self numberOfObjectsForSection:currentSection];
		if(currentRow >= rowCount){
			if(rowCount > 0){
				currentRow = rowCount - 1;
			}
			else{
				currentSection = currentSection - 1;
				while(currentSection >= 0){
					NSInteger rowCount = [self numberOfObjectsForSection:currentSection];
					if(rowCount > 0){
						currentRow = rowCount - 1;
						currentSection = currentSection;
						break;
					}
					currentSection--;
				}
			}
		}
		
		if (currentRow >= 0 && currentSection >= 0){
			[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:currentRow inSection:currentSection] atScrollPosition:UITableViewScrollPositionTop animated:NO];
		}
		self.indexPathToReachAfterRotation = nil;
	}
	
	[self updateNumberOfPages];
	[self updateVisibleViewsIndexPath];
	
	_viewIsOnScreen = YES;
}

- (void)viewWillDisappear:(BOOL)animated {

	self.indexPathToReachAfterRotation = nil;
	
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
	 
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
	if(_frameBeforeKeyboardNotification.size.width != 0
	   && _frameBeforeKeyboardNotification.size.height != 0){
		self.tableViewContainer.frame = _frameBeforeKeyboardNotification;
		_frameBeforeKeyboardNotification = CGRectMake(0,0,0,0);
	}
	
	[super viewDidDisappear:animated];
	_viewIsOnScreen = NO;
	
	//keyboard notifications
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark Orientation Management

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

- (void)adjustView{
	if(_orientation == CKTableViewOrientationLandscape) {
		CGRect frame = self.view.frame;
		self.view.transform = CGAffineTransformMakeRotation(-M_PI/2);
		self.view.frame = frame;
	}
}

- (void)adjustTableView{
	[self adjustView];
	
	if(_orientation == CKTableViewOrientationLandscape) {
		self.tableView.autoresizingMask = UIViewAutoresizingNone;
		self.tableView.frame = CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height);
	}
	
	NSArray *visibleViews = [self visibleViews];
	for (UIView *view in visibleViews) {
		[self rotateSubViewsForCell:(UITableViewCell*)view];
	}
}

- (void)setOrientation:(CKTableViewOrientation)orientation {
	_orientation = orientation;
	[self adjustView];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
	//stop scrolling
	[self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y) animated:NO];
	
	self.indexPathToReachAfterRotation = nil;
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
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration{
	
	if ([CKOSVersion() floatValue] < 3.2) {
		[self adjustTableView];
	}
	[super willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:duration];
}
 
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
	self.indexPathToReachAfterRotation = nil;
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

#pragma mark UITableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [self numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return [self numberOfObjectsForSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat height = 0;
	CGSize thesize = [self sizeForViewAtIndexPath:indexPath];
	height = (_orientation == CKTableViewOrientationLandscape) ? thesize.width : thesize.height;
	
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

- (void)fetchMoreIfNeededAtIndexPath:(NSIndexPath*)indexPath{
	int numberOfRows = [self tableView:self.tableView numberOfRowsInSection:indexPath.section];
	if(_numberOfObjectsToprefetch + indexPath.row > numberOfRows){
		[self fetchObjectsInRange:NSMakeRange(numberOfRows, _numberOfObjectsToprefetch) forSection:indexPath.section];
	}
}

- (UIView*)dequeueReusableViewWithIdentifier:(NSString*)identifier{
	return [self.tableView dequeueReusableCellWithIdentifier:identifier];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UIView* view = [self createViewAtIndexPath:indexPath];
	if([view isKindOfClass:[UITableViewCell class]] == NO){
		int i =3;
	}
	NSAssert([view isKindOfClass:[UITableViewCell class]],@"invalid type for view");
	
	[self fetchMoreIfNeededAtIndexPath:indexPath];
	[self updateNumberOfPages];
	
	return (UITableViewCell*)view;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
	[self rotateSubViewsForCell:cell];
	[self updateNumberOfPages];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if([self willSelectViewAtIndexPath:indexPath]){
		return indexPath;
	}
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.searchBar resignFirstResponder];
	[self didSelectViewAtIndexPath:indexPath];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	CKItemViewFlags flags = [self flagsForViewAtIndexPath:indexPath];
	BOOL bo = flags & CKItemViewFlagRemovable;
	return bo ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
	[self didSelectAccessoryViewAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete){
		[self didRemoveViewAtIndexPath:indexPath];
		[self fetchMoreIfNeededAtIndexPath:indexPath];
	}
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return [self isViewEditableAtIndexPath:indexPath];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	return [self isViewMovableAtIndexPath:indexPath];
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
	return [self targetIndexPathForMoveFromIndexPath:sourceIndexPath toProposedIndexPath:proposedDestinationIndexPath];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	[self didMoveViewAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
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
	_frameBeforeKeyboardNotification = self.tableViewContainer.frame;
	
	if (_resizeOnKeyboardNotification == YES){
		NSDictionary *info = [notification userInfo];
		CGRect keyboardRect = CKUIKeyboardInformationBounds(info);
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDuration:CKUIKeyboardInformationAnimationDuration(info)];
		[UIView setAnimationCurve:CKUIKeyboardInformationAnimationCurve(info)];
		CGRect tableViewFrame = self.tableViewContainer.frame;
		tableViewFrame.size.height -= keyboardRect.size.height;
		self.tableViewContainer.frame = tableViewFrame;
		[UIView commitAnimations];
	}
	else if(_moveOnKeyboardNotification == YES){
		NSDictionary *info = [notification userInfo];
		CGRect keyboardRect = CKUIKeyboardInformationBounds(info);
		
		CGFloat totalHeight = self.view.bounds.size.height;
		CGFloat tableCenter = self.tableViewContainer.bounds.size.height / 2 + self.tableViewContainer.frame.origin.y;
		
		CGFloat ratio = tableCenter / totalHeight;
		
		CGFloat newY = ((totalHeight - keyboardRect.size.height) * ratio) - self.tableViewContainer.bounds.size.height / 2;
		if((newY + self.tableViewContainer.bounds.size.height / 2.0f) > (totalHeight - keyboardRect.size.height)){
			newY = (totalHeight - keyboardRect.size.height) - (self.tableViewContainer.bounds.size.height / 2.0f);
		}
		
		if(newY < 10){
			newY = 10;
		}
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDuration:CKUIKeyboardInformationAnimationDuration(info)];
		[UIView setAnimationCurve:CKUIKeyboardInformationAnimationCurve(info)];
		CGRect tableViewFrame = self.tableViewContainer.frame;
		tableViewFrame.origin.y = newY;
		self.tableViewContainer.frame = tableViewFrame;
		[UIView commitAnimations];
	}
}

- (void)keyboardWillHide:(NSNotification *)notification {
	if(_frameBeforeKeyboardNotification.size.width != 0
	   && _frameBeforeKeyboardNotification.size.height != 0){
		NSDictionary *info = [notification userInfo];
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDuration:CKUIKeyboardInformationAnimationDuration(info)];
		[UIView setAnimationCurve:CKUIKeyboardInformationAnimationCurve(info)];
		self.tableViewContainer.frame = _frameBeforeKeyboardNotification;
		[UIView commitAnimations];
		
		_frameBeforeKeyboardNotification = CGRectMake(0,0,0,0);
	}
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
	[self updateViewsVisibility:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	[self updateCurrentPage];
	[self updateViewsVisibility:YES];
}

#pragma mark CKItemViewContainerController Implementation

- (NSArray*)visibleViews{
	return [self.tableView visibleCells];
}

- (NSIndexPath*)indexPathForView:(UIView*)view{
	NSAssert([view isKindOfClass:[UITableViewCell class]],@"invalid view type");
	return [self.tableView indexPathForCell:(UITableViewCell*)view];
}

- (UIView*)viewAtIndexPath:(NSIndexPath *)indexPath{
	return [self.tableView cellForRowAtIndexPath:indexPath];
}

- (void)updateVisibleViewsRotation{
	NSArray *visibleViews = [self visibleViews];
	for (UIView *view in visibleViews) {
		NSIndexPath *indexPath = [self indexPathForView:view];
		CKItemViewController* controller = [self controllerAtIndexPath:indexPath];
		if([controller respondsToSelector:@selector(rotateView:withParams:animated:)]){
			[controller rotateView:view withParams:self.params animated:YES];
			
			if ([CKOSVersion() floatValue] < 3.2) {
				[self rotateSubViewsForCell:(UITableViewCell*)view];
			}
		}
	}	
}

- (void)onReload{
	if(!_viewIsOnScreen)
		return;
	
	[self.tableView reloadData];
}

- (void)onBeginUpdates{
	if(!_viewIsOnScreen)
		return;
	
	[self.tableView beginUpdates];
}

- (void)onEndUpdates{
	if(!_viewIsOnScreen)
		return;
	
	[self.tableView endUpdates];
	
	//bad solution because the contentsize is updated at the end of insert animation ....
	//could be better if we could observe or be notified that the contentSize has changed.
	NSTimeInterval delay = 0.4;
	[self performSelector:@selector(updateNumberOfPages) withObject:nil afterDelay:delay];
}

- (void)onInsertObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths{
	if(!_viewIsOnScreen)
		return;
	
	[self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:_rowInsertAnimation];
}

- (void)onRemoveObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths{
	if(!_viewIsOnScreen)
		return;
	
	[self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:_rowRemoveAnimation];
}

@end