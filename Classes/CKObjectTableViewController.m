//
//  CKObjectTableViewController.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-03-16.
//  Copyright Wherecloud 2011. All rights reserved.
//

#import "CKObjectTableViewController.h"
#import "CKNSDateAdditions.h"
#import <objc/runtime.h>
#import "CKUIKeyboardInformation.h"
#import <QuartzCore/QuartzCore.h>
#import "CKVersion.h"
#import "CKDocumentController.h"
#import "CKNSObject+bindings.h"
#include "CKSheetController.h"
#import "CKStyleManager.h"
#import "CKUIView+Style.h"
#import "CKUIViewController+Style.h"
#import "CKLocalization.h"
#import "CKNSObject+Invocation.h"

/********************************* CKObjectTableViewController  *********************************
 */

@interface CKObjectTableViewController ()
@property (nonatomic, retain) NSIndexPath* indexPathToReachAfterRotation;
@property (nonatomic, retain) NSIndexPath* selectedIndexPath;
@property (nonatomic, assign, readwrite) int currentPage;
@property (nonatomic, assign, readwrite) int numberOfPages;
@property (nonatomic, retain, readwrite) UISearchBar* searchBar;
@property (nonatomic, retain, readwrite) UISegmentedControl* segmentedControl;
@property (nonatomic, assign) BOOL tableViewHasBeenReloaded;
@property (nonatomic, retain) NSString *bindingContextForTableView;

- (void)updateNumberOfPages;
- (void)adjustView;
- (void)adjustTableView;
- (void)tableViewFrameChanged:(id)value;

- (void)createsAndDisplayEditableButtonsWithType:(CKObjectTableViewControllerEditableType)type animated:(BOOL)animated;

@end



@implementation CKObjectTableViewController
@synthesize currentPage = _currentPage;
@synthesize numberOfPages = _numberOfPages;
@synthesize orientation = _orientation;
@synthesize resizeOnKeyboardNotification = _resizeOnKeyboardNotification;
@synthesize scrolling = _scrolling;
@synthesize indexPathToReachAfterRotation = _indexPathToReachAfterRotation;
@synthesize rowInsertAnimation = _rowInsertAnimation;
@synthesize rowRemoveAnimation = _rowRemoveAnimation;
@synthesize searchEnabled = _searchEnabled;
@synthesize searchBar = _searchBar;
@synthesize liveSearchDelay = _liveSearchDelay;
@synthesize segmentedControl = _segmentedControl;
@synthesize searchScopeDefinition = _searchScopeDefinition;
@synthesize defaultSearchScope = _defaultSearchScope;
@synthesize tableMaximumWidth = _tableMaximumWidth;
@synthesize scrollingPolicy = _scrollingPolicy;
@synthesize editableType = _editableType;
@synthesize searchBlock = _searchBlock;
@synthesize snapPolicy = _snapPolicy;
@synthesize bindingContextForTableView = _bindingContextForTableView;

@synthesize editButton;
@synthesize doneButton;
@dynamic selectedIndexPath;
@dynamic tableViewHasBeenReloaded;

#pragma mark Initialization

- (void)postInit{
	[super postInit];
	_rowInsertAnimation = UITableViewRowAnimationFade;
	_rowRemoveAnimation = UITableViewRowAnimationFade;
	_orientation = CKTableViewOrientationPortrait;
	_resizeOnKeyboardNotification = YES;
	_currentPage = 0;
	_numberOfPages = 0;
	_scrolling = NO;
	_editableType = CKObjectTableViewControllerEditableTypeNone;
	_searchEnabled = NO;
	_liveSearchDelay = 0.5;
	_tableMaximumWidth = 0;
    _scrollingPolicy = CKObjectTableViewControllerScrollingPolicyNone;
    _snapPolicy = CKObjectTableViewControllerSnapPolicyNone;
    
    self.bindingContextForTableView = [NSString stringWithFormat:@"TableVisibility_<%p>",self];
}

- (void)dealloc {
	[NSObject removeAllBindingsForContext:_bindingContextForTableView];
	[_bindingContextForTableView release];
	_bindingContextForTableView = nil;
	[_indexPathToReachAfterRotation release];
	_indexPathToReachAfterRotation = nil;
	[editButton release];
	editButton = nil;
	
	[doneButton release];
	doneButton = nil;
	[_searchBar release];
	_searchBar = nil;
	[_segmentedControl release];
	_segmentedControl = nil;
	[_searchScopeDefinition release];
	_searchScopeDefinition = nil;
	[_defaultSearchScope release];
	_defaultSearchScope = nil;
    [_searchBlock release];
    _searchBlock = nil;
    [super dealloc];
}


#pragma mark UIViewController Implementation

- (void)viewDidLoad{
    [super viewDidLoad];
      
    if(self.tableView.delegate == nil){
        self.tableView.delegate = self;
    }
    if(self.tableView.dataSource == nil){
        self.tableView.dataSource = self;
    }
    
    [self adjustTableView];
}

- (void)viewDidUnload{
    [_weakViews removeAllObjects];
    [_viewsToControllers removeAllObjects];
    [_viewsToIndexPath removeAllObjects];
    [_indexPathToViews removeAllObjects];
    
    [_searchBar release];
    _searchBar = nil;
    
    [_segmentedControl release];
    _segmentedControl = nil;

    [super viewDidUnload];
}


- (void)viewWillAppear:(BOOL)animated {
    CKUIViewControllerAnimatedBlock oldViewWillAppearEndBlock = [self.viewWillAppearEndBlock copy];
    self.viewWillAppearEndBlock = nil;
    
    
	[self.objectController lock];
	[self updateParams];
    
    /*
    self.tableView.delegate = _storedTableDelegate;
    self.tableView.dataSource = _storedTableDataSource;
    */
    
    [super viewWillAppear:animated];
	[self updateParams];
	
	//apply width constraint
	if(_tableMaximumWidth > 0){
		CGFloat tableWidth = MIN(_tableMaximumWidth, self.view.bounds.size.width);
		CGFloat viewHeight = self.view.bounds.size.height;
		CGFloat viewWidth = self.view.bounds.size.width;
		CGFloat centerX = viewWidth / 2.0f;
		
		self.tableViewContainer.frame = CGRectIntegral(CGRectMake(centerX - tableWidth/2.0f,0 ,tableWidth,viewHeight));
		self.tableViewContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin ;
	}
	
	//Adds searchbars if needed
	CGFloat tableViewOffset = 0;
	if(self.searchEnabled && self.searchDisplayController == nil && _searchBar == nil){
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication]statusBarOrientation];
		BOOL isPortrait = UIInterfaceOrientationIsPortrait(orientation);
		BOOL isIpad = ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad);
        if(!isIpad){
            if(_searchScopeDefinition && isPortrait){
                tableViewOffset = 88;
            }
            else{
                tableViewOffset = 44;
            }
        }
        else{
            BOOL tooSmall = self.view.bounds.size.width <= 320;
            if(_searchScopeDefinition && tooSmall){
                tableViewOffset = 88;
            }
            else{
                tableViewOffset = 44;
            }
        }
		
		self.searchBar = [[[UISearchBar alloc]initWithFrame:CGRectMake(0,0,self.tableView.frame.size.width,tableViewOffset)]autorelease];
		_searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		_searchBar.delegate = self;
		//self.tableView.tableHeaderView = _searchBar;
		[self.view addSubview:_searchBar];
		
		
		if(_searchScopeDefinition){
			_searchBar.showsScopeBar = YES;
			_searchBar.scopeButtonTitles = [_searchScopeDefinition allKeys];
			if(_defaultSearchScope){
				_searchBar.selectedScopeButtonIndex = [[_searchScopeDefinition allKeys]indexOfObject:_defaultSearchScope];
			}
		}
		[[[UISearchDisplayController alloc]initWithSearchBar:_searchBar contentsController:self]autorelease];
	}		
	
	//adds segmented control on top if search disable and found _searchScopeDefinition
	if(self.searchEnabled == NO && _searchScopeDefinition && [_searchScopeDefinition count] > 0 && _segmentedControl == nil){
		self.segmentedControl = [[[UISegmentedControl alloc]initWithItems:[_searchScopeDefinition allKeys]]autorelease];
		if(_defaultSearchScope){
			_segmentedControl.selectedSegmentIndex = [[_searchScopeDefinition allKeys]indexOfObject:_defaultSearchScope];
		}
		_segmentedControl.frame = CGRectMake(0,tableViewOffset,self.tableView.frame.size.width,44);
		_segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		[_segmentedControl addTarget:self
							 action:@selector(segmentedControlChange:)
				   forControlEvents:UIControlEventValueChanged];
		[self.view addSubview:_segmentedControl];
		tableViewOffset += 44;
	}
	
	if(self.tableViewContainer.frame.origin.y < tableViewOffset){
		self.tableViewContainer.frame = CGRectMake(self.tableViewContainer.frame.origin.x,self.tableViewContainer.frame.origin.y + tableViewOffset,
												   self.tableViewContainer.frame.size.width,self.tableViewContainer.frame.size.height - tableViewOffset);
	}
	
    
    NSMutableDictionary* controllerStyle = [self controllerStyle];
    NSMutableDictionary* navControllerStyle = [controllerStyle styleForObject:self.navigationController  propertyName:@"navigationController"];
	NSMutableDictionary* navBarStyle = [navControllerStyle styleForObject:self.navigationController  propertyName:@"navigationBar"];
    
    if(!self.editButton){
        self.editButton = [[[UIBarButtonItem alloc] initWithTitle:_(@"Edit") style:UIBarButtonItemStyleBordered target:self action:@selector(edit:)]autorelease];
    }
    if(!self.doneButton){
        self.doneButton = [[[UIBarButtonItem alloc] initWithTitle:_(@"Done") style:UIBarButtonItemStyleDone target:self action:@selector(edit:)]autorelease];
    }
    
    if(self.editButton){
        NSMutableDictionary* barItemStyle = [navBarStyle styleForObject:self.editButton propertyName:@"editBarButtonItem"];
        [self.editButton applyStyle:barItemStyle];
    }
    if(self.doneButton){
        NSMutableDictionary* barItemStyle = [navBarStyle styleForObject:self.doneButton propertyName:@"doneBarButtonItem"];
        [self.doneButton applyStyle:barItemStyle];
    }
    
	[self createsAndDisplayEditableButtonsWithType:_editableType animated:animated];
	
	if ([CKOSVersion() floatValue] < 3.2) {
		[self.tableView beginUpdates];
		[self.tableView endUpdates];
	}
	
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
	//[self updateVisibleViewsIndexPath];
	
	[self.objectController unlock];
	
	for(int i =0; i< [self numberOfSections];++i){
		[self fetchMoreIfNeededAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
	}
    
    [self tableViewFrameChanged:nil];
    
    if(self.tableView.hidden == NO){
        [self performSelector:@selector(updateViewsVisibility:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.4];
    }
    [NSObject beginBindingsContext:_bindingContextForTableView policy:CKBindingsContextPolicyRemovePreviousBindings];
    [self.tableView bind:@"hidden" target:self action:@selector(tableViewVisibilityChanged:)];
	[self.tableViewContainer bind:@"bounds" target:self action:@selector(tableViewFrameChanged:)];
    [NSObject endBindingsContext];

    if(oldViewWillAppearEndBlock){
        oldViewWillAppearEndBlock(self,animated);
        self.viewWillAppearEndBlock = oldViewWillAppearEndBlock;
    }
}

- (void)tableViewVisibilityChanged:(NSNumber*)hidden{
    if(![hidden boolValue]){
        [self performSelector:@selector(updateViewsVisibility:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.4];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
	self.indexPathToReachAfterRotation = nil;
	
	NSArray *visibleIndexPaths = [self visibleIndexPaths];
	for (NSIndexPath *indexPath in visibleIndexPaths) {
		CGRect f = [self.tableView rectForRowAtIndexPath:indexPath];
		if(f.origin.y >= self.tableView.contentOffset.y){
			self.indexPathToReachAfterRotation = indexPath;
			break;
		}
	}
	
	if(!_indexPathToReachAfterRotation && [visibleIndexPaths count] > 0){
		NSIndexPath *indexPath = [visibleIndexPaths objectAtIndex:0];
		self.indexPathToReachAfterRotation = indexPath;
	}
	 
	[super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sheetWillShow:) name:CKSheetWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sheetWillHide:) name:CKSheetWillHideNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated{
	[super viewDidDisappear:animated];
    /*
    _storedTableDelegate = self.tableView.delegate;
    self.tableView.delegate = nil;
    _storedTableDataSource = self.tableView.dataSource;
    self.tableView.dataSource = nil;
     */
	
	//keyboard notifications
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:CKSheetWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:CKSheetWillHideNotification object:nil];
    
	[NSObject removeAllBindingsForContext:_bindingContextForTableView];
}


- (void)reload{
	if(self.viewIsOnScreen){
		[super reload];
		[self fetchMoreData];
	}
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
				v.center = CGPointMake((NSInteger)(cell.contentView.bounds.size.width / 2.0),(NSInteger)(cell.contentView.bounds.size.height / 2.0));
				v.frame = cell.contentView.bounds;
				//v.autoresizingMask = resizingMasks; //reizing masks break the layout on os 3
			}
		}
	}
}

- (void)adjustView{
    if(self.tableViewContainer == nil)
        return;
    
	if(_orientation == CKTableViewOrientationLandscape) {
		CGRect frame = self.tableViewContainer.frame;
		self.tableViewContainer.transform = CGAffineTransformMakeRotation(-M_PI/2);
		self.tableViewContainer.frame = frame;
	}
}

- (void)adjustTableView{
    if(self.tableViewContainer == nil)
        return;
    
	[self adjustView];
	
	if(_orientation == CKTableViewOrientationLandscape) {
		self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.tableView.frame = CGRectMake(0,0,self.tableViewContainer.bounds.size.width,self.tableViewContainer.bounds.size.height);
	}
	
	NSArray *visibleIndexPaths = [self visibleIndexPaths];
	for (NSIndexPath *indexPath in visibleIndexPaths) {
		CKItemViewController* controller = [self controllerAtIndexPath:indexPath];
		[self rotateSubViewsForCell:(UITableViewCell*)controller.view];
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
	NSArray *visibleIndexPaths = [self visibleIndexPaths];
	for (NSIndexPath *indexPath in visibleIndexPaths) {
		CGRect f = [self.tableView rectForRowAtIndexPath:indexPath];
		if(f.origin.y >= self.tableView.contentOffset.y){
			self.indexPathToReachAfterRotation = indexPath;
			break;
		}
	}
	
	if(!_indexPathToReachAfterRotation && [visibleIndexPaths count] > 0){
		NSIndexPath *indexPath = [visibleIndexPaths objectAtIndex:0];
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
    if(_indexPathToReachAfterRotation){
        BOOL pagingEnable = self.tableView.pagingEnabled;
        self.tableView.pagingEnabled = NO;
        [self.tableView scrollToRowAtIndexPath:_indexPathToReachAfterRotation atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        self.tableView.pagingEnabled = pagingEnable;
    }
	self.indexPathToReachAfterRotation = nil;
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

#pragma mark UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.tableViewHasBeenReloaded ? [self numberOfSections] : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return self.tableViewHasBeenReloaded ? [self numberOfObjectsForSection:section] : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {	CGFloat height = 0;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UIView* view = [self createViewAtIndexPath:indexPath];
	NSAssert([view isKindOfClass:[UITableViewCell class]],@"invalid type for view");
	[self updateNumberOfPages];
	
	return (UITableViewCell*)view;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    CKTableViewCellController* controller = (CKTableViewCellController*) [self controllerAtIndexPath:indexPath];
    return controller.indentationLevel;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
	[self rotateSubViewsForCell:cell];
	[self updateNumberOfPages];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //[self updateVisibleViewsIndexPath];
	if([self willSelectViewAtIndexPath:indexPath]){
        [self selectRowAtIndexPath:indexPath animated:YES];
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
        //[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:self.rowRemoveAnimation];
		[self fetchMoreIfNeededAtIndexPath:indexPath];
	}
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.editableType == CKObjectTableViewControllerEditableTypeNone
       || self.editing == NO)
        return NO;
    
	return [self isViewEditableAtIndexPath:indexPath];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.editableType == CKObjectTableViewControllerEditableTypeNone
       || self.editing == NO)
        return NO;
    
	return [self isViewMovableAtIndexPath:indexPath];
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
	return [self targetIndexPathForMoveFromIndexPath:sourceIndexPath toProposedIndexPath:proposedDestinationIndexPath];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	[self didMoveViewAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
}


#pragma mark UITableView Delegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if([_objectController respondsToSelector:@selector(headerTitleForSection:)]){
        return [_objectController headerTitleForSection:section];
    }
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	CGFloat height = 0;
	UIView* view = [self tableView:self.tableView viewForHeaderInSection:section];
	if(view){
		height = view.frame.size.height;
	}
	
	if(height <= 0){
        if([_objectController respondsToSelector:@selector(headerTitleForSection:)]){
            NSString* title = [_objectController headerTitleForSection:section];
            if( title != nil ){
                return -1;
            }
        }
	}
	return height;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if([_objectController respondsToSelector:@selector(headerViewForSection:)]){
        return [_objectController headerViewForSection:section];
    }

	return nil;
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if([_objectController respondsToSelector:@selector(footerTitleForSection:)]){
        return [_objectController footerTitleForSection:section];
    }
	return nil;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	CGFloat height = 0;
	UIView* view = [self tableView:self.tableView viewForFooterInSection:section];
	if(view){
		height = view.frame.size.height;
	}
	
	if(height <= 0){
        if([_objectController respondsToSelector:@selector(footerTitleForSection:)]){
            NSString* title = [_objectController footerTitleForSection:section];
            if( title != nil ){
                return -1;
            }
        }
	}
	return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if([_objectController respondsToSelector:@selector(footerViewForSection:)]){
        return [_objectController footerViewForSection:section];
    }
	return nil;
}


#pragma mark UITableView (CKHeaderViewManagement)

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView*)headerView withTitle:(NSString*)title{
    if([headerView appliedStyle] == nil && [title isKindOfClass:[NSString class]] && [title length] > 0){
        NSMutableDictionary* style = [self controllerStyle];
        [headerView applyStyle:style propertyName:@"sectionHeaderView"];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView*)headerView withTitle:(NSString*)title{
    if([headerView appliedStyle] == nil && [title isKindOfClass:[NSString class]] && [title length] > 0){
        NSMutableDictionary* style = [self controllerStyle];
        [headerView applyStyle:style propertyName:@"sectionFooterView"];
    }
}

#pragma mark CKItemViewContainerController Implementation

- (void)updateVisibleViewsRotation{
	NSArray *visibleIndexPaths = [self visibleIndexPaths];
	for (NSIndexPath *indexPath in visibleIndexPaths) {
		CKItemViewController* controller = [self controllerAtIndexPath:indexPath];
		if([controller respondsToSelector:@selector(rotateView:withParams:animated:)]){
			[controller rotateView:controller.view withParams:self.params animated:YES];
			
			if ([CKOSVersion() floatValue] < 3.2) {
				[self rotateSubViewsForCell:(UITableViewCell*)controller.view];
			}
		}
	}	
}

- (void)onBeginUpdates{
	if(!self.viewIsOnScreen){
        self.tableViewHasBeenReloaded = NO;
		return;
    }
	
	[self.tableView beginUpdates];
    //NSLog(@"onBeginUpdates <%@>",self);
}

- (void)onEndUpdates{
	if(!self.viewIsOnScreen){
        self.tableViewHasBeenReloaded = NO;
		return;
    }
	
    //NSLog(@"onEndUpdates <%@>",self);
	[self.tableView endUpdates];
	
	//bad solution because the contentsize is updated at the end of insert animation ....
	//could be better if we could observe or be notified that the contentSize has changed.
	NSTimeInterval delay = 0.4;
	[self performSelector:@selector(updateNumberOfPages) withObject:nil afterDelay:delay];
}

- (void)onInsertObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths{
	if(!self.viewIsOnScreen){
        self.tableViewHasBeenReloaded = NO;
		return;
    }
    //NSLog(@"onInsertObjects <%@>",self);
	
	[self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:(self.state & CKUIViewControllerStateDidAppear) ? _rowInsertAnimation : UITableViewRowAnimationNone];
	
	//UPDATE STICKY SELECTION INDEX PATH
	if(self.selectedIndexPath){
		int count = 0;
		for(NSIndexPath* indexPath in indexPaths){
			if(indexPath.section == self.selectedIndexPath.section){
				if(indexPath.row <= self.selectedIndexPath.row){
					count++;
				}
			}
		}
		self.selectedIndexPath = [NSIndexPath indexPathForRow:self.selectedIndexPath.row + count inSection:self.selectedIndexPath.section];
	}
}

- (void)onRemoveObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths{
	if(!self.viewIsOnScreen){
        self.tableViewHasBeenReloaded = NO;
		return;
    }
    //NSLog(@"onRemoveObjects <%@>",self);
	
	[self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:(self.state & CKUIViewControllerStateDidAppear) ? _rowRemoveAnimation : UITableViewRowAnimationNone];
	
	//UPDATE STICKY SELECTION INDEX PATH
	if(self.selectedIndexPath){
		int count = 0;
		for(NSIndexPath* indexPath in indexPaths){
			if([indexPath isEqual:self.selectedIndexPath]){
				self.selectedIndexPath = nil;
				break;
			}
			
			if(indexPath.section == self.selectedIndexPath.section){
				if(indexPath.row <= self.selectedIndexPath.row){
					count++;
				}
			}
		}
		
		if(self.selectedIndexPath){
			self.selectedIndexPath = [NSIndexPath indexPathForRow:self.selectedIndexPath.row - count inSection:self.selectedIndexPath.section];
		}
	}
}

- (void)onInsertSectionAtIndex:(NSInteger)index{
	if(!self.viewIsOnScreen){
        self.tableViewHasBeenReloaded = NO;
		return;
    }
    //NSLog(@"onInsertSectionAtIndex <%@>",self);
	[self.tableView insertSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:(self.state & CKUIViewControllerStateDidAppear) ? _rowInsertAnimation : UITableViewRowAnimationNone];
	
	//UPDATE STICKY SELECTION INDEX PATH
	if(self.selectedIndexPath && self.selectedIndexPath.section >= index){
		self.selectedIndexPath = [NSIndexPath indexPathForRow:self.selectedIndexPath.row inSection:self.selectedIndexPath.section + 1];
	}
}

- (void)onRemoveSectionAtIndex:(NSInteger)index{
	if(!self.viewIsOnScreen){
        self.tableViewHasBeenReloaded = NO;
		return;
    }
    //NSLog(@"onRemoveSectionAtIndex <%@>",self);
	[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:(self.state & CKUIViewControllerStateDidAppear) ? _rowRemoveAnimation : UITableViewRowAnimationNone];
	
	//UPDATE STICKY SELECTION INDEX PATH
	if(self.selectedIndexPath && self.selectedIndexPath.section > index){
		self.selectedIndexPath = [NSIndexPath indexPathForRow:self.selectedIndexPath.row inSection:self.selectedIndexPath.section - 1];
	}
}

- (void)setObjectController:(id)controller{
	[super setObjectController:controller];
	if(_objectController != nil && [_objectController respondsToSelector:@selector(setDisplayFeedSourceCell:)]){
		[_objectController setDisplayFeedSourceCell:YES];
	}
}

- (void)updateParams{
	if(self.params == nil){
		self.params = [NSMutableDictionary dictionary];
	}
	
	[self.params setObject:[NSValue valueWithCGSize:self.tableView.bounds.size] forKey:CKTableViewAttributeBounds];
	[self.params setObject:[NSNumber numberWithInt:self.interfaceOrientation] forKey:CKTableViewAttributeInterfaceOrientation];
	[self.params setObject:[NSNumber numberWithBool:self.tableView.pagingEnabled] forKey:CKTableViewAttributePagingEnabled];
	[self.params setObject:[NSNumber numberWithInt:self.orientation] forKey:CKTableViewAttributeOrientation];
	[self.params setObject:[NSNumber numberWithDouble:0] forKey:CKTableViewAttributeAnimationDuration];
	[self.params setObject:[NSNumber numberWithBool:self.editableType != CKObjectTableViewControllerEditableTypeNone] forKey:CKTableViewAttributeEditable];
	[self.params setObject:[NSValue valueWithNonretainedObject:self] forKey:CKTableViewAttributeParentController];
}

- (UIView*)dequeueReusableViewWithIdentifier:(NSString*)identifier{
	return [self.tableView dequeueReusableCellWithIdentifier:identifier];
}

#pragma mark SearchBar Management

- (void)didSearch:(NSString*)text{
        //if we want to implement it in subclass ..
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[self.searchBar resignFirstResponder];
	
	if ([searchBar.text isEqualToString:@""] == NO){
		if(_delegate && [_delegate respondsToSelector:@selector(objectTableViewController:didSearch:)]) {
			[_delegate objectTableViewController:self didSearch:searchBar.text];
		}
        if(_searchBlock){
            _searchBlock(searchBar.text);
        }
		[self didSearch:searchBar.text];
	}
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
	/*[NSObject cancelPreviousPerformRequestsWithTarget:self];
	if ([searchBar.text isEqualToString:@""] == YES){
		if(_delegate && [_delegate respondsToSelector:@selector(objectTableViewController:didSearch:)]) {
			[_delegate objectTableViewController:self didSearch:@""];
		}
        
        if(_searchBlock){
            _searchBlock(searchBar.text);
        }
		[self didSearch:searchBar.text];
	}*/
}

- (void)delayedSearchWithText:(NSString*)str{
	if (_delegate && [_delegate respondsToSelector:@selector(objectTableViewController:didSearch:)]) {
		[_delegate objectTableViewController:self didSearch:str];
	}
    
    if(_searchBlock){
        _searchBlock(str);
    }
	[self didSearch:str];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	if(_liveSearchDelay > 0){
		[self performSelector:@selector(delayedSearchWithText:) withObject:searchBar.text afterDelay:_liveSearchDelay];
	}
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope{
	NSInteger index = selectedScope;
	id key = [[_searchScopeDefinition allKeys]objectAtIndex:index];
	id value = [_searchScopeDefinition objectForKey:key];
	NSAssert([value isKindOfClass:[CKCallback class]],@"invalid object in segmentDefinition");
	CKCallback* callback = (CKCallback*)value;
	[callback execute:self];	
}

- (void)segmentedControlChange:(id)sender{
	NSInteger index = _segmentedControl.selectedSegmentIndex;
	id key = [[_searchScopeDefinition allKeys]objectAtIndex:index];
	id value = [_searchScopeDefinition objectForKey:key];
	NSAssert([value isKindOfClass:[CKCallback class]],@"invalid object in segmentDefinition");
	CKCallback* callback = (CKCallback*)value;
	[callback execute:self];
}



#pragma mark Edit Button Management

- (void)createsAndDisplayEditableButtonsWithType:(CKObjectTableViewControllerEditableType)type animated:(BOOL)animated{
    switch(type){
        case CKObjectTableViewControllerEditableTypeLeft:{
            self.leftButton = self.navigationItem.leftBarButtonItem;
            [self.navigationItem setLeftBarButtonItem:(self.editing) ? self.doneButton : self.editButton animated:animated];
            break;
        }
        case CKObjectTableViewControllerEditableTypeRight:{
            self.rightButton = self.navigationItem.rightBarButtonItem;
            [self.navigationItem setRightBarButtonItem:(self.editing) ? self.doneButton : self.editButton animated:animated];
            break;
        }
        case CKObjectTableViewControllerEditableTypeNone:break;
	}
}

- (void)setEditableType:(CKObjectTableViewControllerEditableType)theEditableType{
    if(theEditableType != _editableType && self.viewIsOnScreen){
        switch(_editableType){
            case CKObjectTableViewControllerEditableTypeLeft:{
                if(self.leftButton){
                    [self.navigationItem setLeftBarButtonItem:self.leftButton animated:YES];
                }
                else{
                    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
                }
                break;
            }
            case CKObjectTableViewControllerEditableTypeRight:{
                if(self.rightButton){
                    [self.navigationItem setRightBarButtonItem:self.rightButton animated:YES];
                }
                else{
                    [self.navigationItem setRightBarButtonItem:nil animated:YES];
                }
                break;
            }
            case CKObjectTableViewControllerEditableTypeNone:break;
        }
        
        if(theEditableType != CKObjectTableViewControllerEditableTypeNone){
            [self createsAndDisplayEditableButtonsWithType:theEditableType animated:YES];
        }
        else if(theEditableType == CKObjectTableViewControllerEditableTypeNone){
            if([self isEditing]){
                [self setEditing:NO animated:YES];
            }
        }
    }
    _editableType = theEditableType;
}

- (void)setEditing:(BOOL)editing{
    [self willChangeValueForKey:@"editing"];
    [super setEditing:editing];
    [self didChangeValueForKey:@"editing"];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated{
    [self willChangeValueForKey:@"editing"];
    [super setEditing:editing animated:animated];
    [self didChangeValueForKey:@"editing"];
}

- (IBAction)edit:(id)sender{
    switch(_editableType){
        case CKObjectTableViewControllerEditableTypeLeft:{
            [self.navigationItem setLeftBarButtonItem:(self.navigationItem.leftBarButtonItem == self.editButton) ? self.doneButton : self.editButton animated:YES];
            [self setEditing: (self.navigationItem.leftBarButtonItem == self.editButton) ? NO : YES animated:YES];
            break;
        }
        case CKObjectTableViewControllerEditableTypeRight:{
            [self.navigationItem setRightBarButtonItem:(self.navigationItem.rightBarButtonItem == self.editButton) ? self.doneButton : self.editButton animated:YES];
            [self setEditing: (self.navigationItem.rightBarButtonItem == self.editButton) ? NO : YES animated:YES];
            break;
        }
        case CKObjectTableViewControllerEditableTypeNone:break;
	}
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}


#pragma mark Keyboard Notifications

- (void)stretchTableDownUsingRect:(CGRect)endFrame animationCurve:(UIViewAnimationCurve)animationCurve duration:(NSTimeInterval)animationDuration{
    if (_resizeOnKeyboardNotification == YES){
        CGRect keyboardFrame = [[self.tableViewContainer window] convertRect:endFrame toView:self.tableViewContainer];
        CGFloat offset = self.tableViewContainer.frame.size.height - keyboardFrame.origin.y;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:animationDuration];
        [UIView setAnimationCurve:animationCurve];
        self.tableView.contentInset =  UIEdgeInsetsMake(self.tableViewInsets.top,0,self.tableViewInsets.bottom + offset, 0);
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0,0,offset, 0);
        [UIView commitAnimations];
    }
}

- (void)stretchBackToPreviousFrameUsingAnimationCurve:(UIViewAnimationCurve)animationCurve duration:(NSTimeInterval)animationDuration{
    if(_modalViewCount <= 0){
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:animationDuration];
        [UIView setAnimationCurve:animationCurve];
        self.tableView.contentInset = UIEdgeInsetsMake(self.tableViewInsets.top,0,self.tableViewInsets.bottom,0);
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
        
        [UIView commitAnimations];
    }
}

- (void)keyboardWillShow:(NSNotification *)notification {
    _modalViewCount = 1;
    NSDictionary *info = [notification userInfo];
    CGRect keyboardEndFrame;
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    [[info objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [self stretchTableDownUsingRect:keyboardEndFrame animationCurve:animationCurve duration:animationDuration];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    if(_modalViewCount == 1){
        _modalViewCount = 0;
    }
    NSDictionary *info = [notification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [self stretchBackToPreviousFrameUsingAnimationCurve:animationCurve duration:animationDuration];
}

- (void)sheetWillShow:(NSNotification *)notification {
    _modalViewCount = 2;
    NSDictionary *info = [notification userInfo];
    CGRect keyboardEndFrame = [[info objectForKey:CKSheetFrameEndUserInfoKey] CGRectValue];
    UIViewAnimationCurve animationCurve = [[info objectForKey:CKSheetAnimationCurveUserInfoKey] intValue];
    NSTimeInterval animationDuration = [[info objectForKey:CKSheetAnimationDurationUserInfoKey] floatValue];
    [self stretchTableDownUsingRect:keyboardEndFrame animationCurve:animationCurve duration:animationDuration];}

- (void)sheetWillHide:(NSNotification *)notification {
    if(_modalViewCount == 2){
        _modalViewCount = 0;
    }
    NSDictionary *info = [notification userInfo];
    UIViewAnimationCurve animationCurve = [[info objectForKey:CKSheetAnimationCurveUserInfoKey] intValue];
    NSTimeInterval animationDuration = [[info objectForKey:CKSheetAnimationDurationUserInfoKey] floatValue];
    BOOL keyboardWillShow = [[info objectForKey:CKSheetKeyboardWillShowInfoKey]boolValue];
    if(!keyboardWillShow){
        [self stretchBackToPreviousFrameUsingAnimationCurve:animationCurve duration:animationDuration];
    }
}

#pragma mark Paging And Snapping

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

- (void)executeScrollingPolicy{
    switch(_scrollingPolicy){
        case CKObjectTableViewControllerScrollingPolicyNone:{
            break;
        }
        case CKObjectTableViewControllerScrollingPolicyResignResponder:{
            [self.view endEditing:YES];
            [[NSNotificationCenter defaultCenter]postNotificationName:CKSheetResignNotification object:nil];
            break;
        }
    }
}

- (NSIndexPath*)snapIndexPath{
    CGFloat offset = self.tableView.contentOffset.y;
    offset += self.tableView.bounds.size.height / 2.0;
    
    if(offset < 0){ offset = 0; }
    if(offset > self.tableView.contentSize.height){ offset = self.tableView.contentSize.height; }
    
    for(NSIndexPath* indexPath in self.visibleIndexPaths){
        UIView* v = [self viewAtIndexPath:indexPath];
        CGRect rect = v.frame;
        if(rect.origin.y <= offset && rect.origin.y + rect.size.height >= offset){
            return indexPath;
        }
    }
    
    return nil;
}

- (void)executeSnapPolicy{
    switch(_snapPolicy){
        case CKObjectTableViewControllerSnapPolicyNone:{
            break;
        }
        case CKObjectTableViewControllerSnapPolicyCenter:{
            NSIndexPath* indexPath = [self snapIndexPath];
            if(indexPath != nil){
                NSIndexPath * indexPath2 = [self tableView:self.tableView willSelectRowAtIndexPath:indexPath];
                if(indexPath2){
                    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath2];
                }
            }
            break;
        }
    }
}

- (void)tableViewFrameChanged:(id)value{
    switch(_snapPolicy){
        case CKObjectTableViewControllerSnapPolicyNone:{
            break;
        }
        case CKObjectTableViewControllerSnapPolicyCenter:{
                //FIXME : we do not take self.tableViewInsets in account here
            self.tableView.contentInset = UIEdgeInsetsMake(self.tableView.bounds.size.height / 2.0,0,self.tableView.bounds.size.height / 2.0,0);
            self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
            
            if (self.selectedIndexPath && [self isValidIndexPath:self.selectedIndexPath]
                && self.snapPolicy == CKObjectTableViewControllerSnapPolicyCenter){
                [self selectRowAtIndexPath:self.selectedIndexPath animated:(self.state == CKUIViewControllerStateDidAppear) ? YES : NO];
            }
            
            break;
        }
    }
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView{
	[self updateCurrentPage];
	[self updateViewsVisibility:YES];
	[self fetchMoreData];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	[self updateCurrentPage];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
	[self updateCurrentPage];
	[self fetchMoreData];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self executeScrollingPolicy];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if (decelerate || scrollView.decelerating)
		return;
    
	[self updateViewsVisibility:YES];
    [self executeSnapPolicy];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	[self updateCurrentPage];
	[self updateViewsVisibility:YES];
	[self fetchMoreData];
    [self executeSnapPolicy];
}

- (void)scrollToRowAtIndexPath:(NSIndexPath*)indexPath animated:(BOOL)animated{
    if([self isValidIndexPath:indexPath]){
        if(self.snapPolicy == CKObjectTableViewControllerSnapPolicyCenter){
            CGRect r = [self.tableView rectForRowAtIndexPath:indexPath];
            CGFloat offset = r.origin.y + (r.size.height / 2.0);
            offset -= self.tableView.contentInset.top;
            [self.tableView setContentOffset:CGPointMake(0,offset) animated:animated];
        }
        else{
            [self.tableView scrollToRowAtIndexPath:indexPath 
                                  atScrollPosition:UITableViewScrollPositionMiddle 
                                          animated:YES];
        }
    }
}

- (void)selectRowAtIndexPath:(NSIndexPath*)indexPath animated:(BOOL)animated{
    if([self isValidIndexPath:indexPath]){
        if(self.snapPolicy == CKObjectTableViewControllerSnapPolicyCenter){
            CGRect r = [self.tableView rectForRowAtIndexPath:indexPath];
            CGFloat offset = r.origin.y + (r.size.height / 2.0);
            offset -= self.tableView.contentInset.top;
            [self.tableView selectRowAtIndexPath:indexPath
                                        animated:NO
                                  scrollPosition:UITableViewScrollPositionNone];
            [self.tableView setContentOffset:CGPointMake(0,offset) animated:animated];
        }
        else{
            [self.tableView selectRowAtIndexPath:indexPath
                                        animated:NO
                                  scrollPosition:UITableViewScrollPositionNone];
        }
        self.selectedIndexPath = indexPath;
    }
}


@end

/********************************* Header Management  *********************************
 */

@interface UITableView (CKHeaderViewManagement)
@end

@implementation UITableView (CKHeaderViewManagement)

/* IOS 4.3 and before : 
 When the views are added for section footer, they have no subviews (UITableHeaderFooterViewLabel)
 Applying style in this delegate will then not apply anything on the label ...
 */
- (void)didAddSubview:(UIView *)subview{
    if([[[subview class]description]isEqualToString:@"UITableHeaderFooterView"]){
        if(self.delegate && [self.delegate respondsToSelector:@selector(tableView:willDisplayHeaderView:withTitle:)]){
            BOOL header = [[subview valueForKey:@"sectionHeader"]boolValue];
            NSString* title = nil;
            if([subview respondsToSelector:@selector(text)]){
                title = [subview performSelector:@selector(text)];
            }
            
            id theDelegate = self.delegate;
            if(header){
                [theDelegate performSelector:@selector(tableView:willDisplayHeaderView:withTitle:) 
                                 withObjects:[NSArray arrayWithObjects:self,subview,title,nil]];
            }
            else{
                [theDelegate performSelector:@selector(tableView:willDisplayFooterView:withTitle:) 
                                 withObjects:[NSArray arrayWithObjects:self,subview,title,nil]];
            }
        }
    }
    [super didAddSubview:subview];
}

@end



/********************************* DEPRECATED *********************************
 */

@implementation CKObjectTableViewController (DEPRECATED_IN_CLOUDKIT_VERSION_1_7_AND_LATER)
@dynamic editable;

- (BOOL)editable{
    return _editableType != CKObjectTableViewControllerEditableTypeNone;
}

- (void)setEditable:(BOOL)editable{
    if(_editableType == CKObjectTableViewControllerEditableTypeNone){
        _editableType = CKObjectTableViewControllerEditableTypeLeft;
    }
}

@end


