//
//  CKTableViewController.h
//  AppCoreKit
//
//  Created by Fred Brunel.
//  Copyright 2010 WhereCloud Inc. All rights reserved.

#import "CKTableViewController.h"
#import "CKStyleManager.h"
#import "CKStyle+Parsing.h"
#import "CKTableViewCellController+DynamicLayout.h"
#import "CKTableViewCellController+DynamicLayout_Private.h"
#import <QuartzCore/QuartzCore.h>
#import "CKDebug.h"

@interface CKCollectionViewController()

@property (nonatomic, retain) NSMutableDictionary* viewsToControllers;
@property (nonatomic, retain) NSMutableDictionary* viewsToIndexPath;
@property (nonatomic, retain) NSMutableDictionary* indexPathToViews;
@property (nonatomic, retain) NSMutableArray* weakViews;
@property (nonatomic, retain) NSMutableArray* sectionsToControllers;

@property (nonatomic, retain) id objectController;
@property (nonatomic, retain) CKCollectionCellControllerFactory* controllerFactory;

- (void)updateVisibleViewsIndexPath;
- (void)updateVisibleViewsRotation;
- (void)updateViewsVisibility:(BOOL)visible;

@end


@interface CKTableView()
@property (nonatomic,assign) NSInteger numberOfUpdates;
@property(nonatomic,assign) BOOL sizeChangedWhileReloading;
@property(nonatomic,assign) BOOL isLayouting;
@end


@implementation CKTableView
@synthesize numberOfUpdates;
@synthesize sizeChangedWhileReloading;
@synthesize isLayouting;

- (void)postInit{
    self.numberOfUpdates = 0;
    self.sizeChangedWhileReloading = NO;
    self.isLayouting = NO;
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    self = [super initWithFrame:frame style:style];
    [self postInit];
    return self;
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    [self postInit];
    return self; 
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    [self postInit];
    return self;
}

- (id)init{
    self = [super init];
    [self postInit];
    return self;
}

- (void)beginUpdates{
    if(self.numberOfUpdates == 0){
       // NSLog(@"beginUpdates");
        [super beginUpdates];
    }
    self.numberOfUpdates++;
}

- (void)endUpdates{
    self.numberOfUpdates--;
    if(self.numberOfUpdates == 0){
       // NSLog(@"endUpdates");
        [super endUpdates];
    }
}

- (void)layoutSubviews{
    self.isLayouting = YES;

    [super layoutSubviews];
    
    self.isLayouting = NO;
    
    if(self.sizeChangedWhileReloading){
        [CATransaction begin];
        [CATransaction 
         setValue: [NSNumber numberWithBool: YES]
         forKey: kCATransactionDisableActions];
        
        [self beginUpdates];
        [self endUpdates];
        self.sizeChangedWhileReloading = NO;
        
        [CATransaction commit];
    }
}

@end


@interface CKTableViewController ()
@property (nonatomic, retain) NSIndexPath *selectedIndexPath;
@property (nonatomic, assign) BOOL insetsApplied;
@property (nonatomic, assign) BOOL tableViewHasBeenReloaded;
@property (nonatomic, assign) BOOL sizeIsAlreadyInvalidated;
@property (nonatomic, assign) BOOL lockSizeChange;
@property (nonatomic, assign) BOOL isReloading;

- (void)sizeToFit;

@end


@implementation CKTableViewController{
	UIView *_backgroundView;
	UIView *_tableViewContainer;
	CKTableView *_tableView;
	UITableViewStyle _style;
	BOOL _stickySelection;
	NSIndexPath *_selectedIndexPath;
    UIEdgeInsets _tableViewInsets;
}

@synthesize tableView = _tableView;
@synthesize style = _style;
@synthesize stickySelectionEnabled = _stickySelection;
@synthesize selectedIndexPath = _selectedIndexPath;
@synthesize tableViewContainer = _tableViewContainer;
@synthesize tableViewInsets = _tableViewInsets;
@synthesize insetsApplied;
@synthesize tableViewHasBeenReloaded;
@synthesize sizeIsAlreadyInvalidated;
@synthesize lockSizeChange;
@synthesize isReloading;

- (void)postInit {
	[super postInit];
    self.tableViewHasBeenReloaded = NO;
    self.insetsApplied = NO;
	self.style = UITableViewStylePlain;
    self.tableViewInsets = UIEdgeInsetsMake(0,0,0,0);
    self.sizeIsAlreadyInvalidated = NO;
    self.lockSizeChange = NO;
    self.isReloading = NO;
}

- (void)styleExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"UITableViewStyle",
                                                 UITableViewStylePlain,
                                                 UITableViewStyleGrouped);
}

- (id)initWithStyle:(UITableViewStyle)style { 
	self = [super init];
	if (self) {
		[self postInit];
		self.style = style;
	}
	return self;
}

- (void)dealloc {
	self.selectedIndexPath = nil;
    if(_tableView){
        self.tableView.delegate = nil;
        self.tableView.dataSource = nil;
        [_tableView release];
        _tableView = nil;
    }
	[_tableViewContainer release];
    _tableViewContainer = nil;
	[super dealloc];
}

#pragma mark View Management

- (void)sizeToFit{
    if(!self.insetsApplied){
        //FIXME : We do not take the table view orientation in account here (Portrait, Landscape)
        self.tableView.contentInset = UIEdgeInsetsMake(self.tableViewInsets.top,0,self.tableViewInsets.bottom,0);
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
        
        CGRect frame = self.tableViewContainer.frame;
        self.tableViewContainer.frame = CGRectIntegral(CGRectMake(frame.origin.x + self.tableViewInsets.left,
                                                                  frame.origin.y/* + self.tableInsets.top*/,
                                                                  frame.size.width - (self.tableViewInsets.left + self.tableViewInsets.right),
                                                                  frame.size.height/* - (self.tableInsets.top + self.tableInsets.bottom)*/));
        self.insetsApplied = YES;
    }
}

- (void)viewDidLoad{
    NSMutableDictionary* controllerStyle = [[CKStyleManager defaultManager] styleForObject:self  propertyName:nil];
    if([controllerStyle containsObjectForKey:@"style"]){
        self.style = [controllerStyle enumValueForKey:@"style" 
                                   withEnumDescriptor:CKEnumDefinition(@"UITableViewStyle",
                                                                       UITableViewStylePlain, 
                                                                       UITableViewStyleGrouped)];
    }
    
	if (self.view == nil) {
		CGRect theViewFrame = [[UIScreen mainScreen] applicationFrame];
		UIView *theView = [[[CKTableView alloc] initWithFrame:theViewFrame] autorelease];
		theView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		self.view = theView;
	}
	//self.view.clipsToBounds = YES;
	
	if ([self.view isKindOfClass:[CKTableView class]] == NO && self.tableViewContainer == nil) {
        CKTableView* theTableView = (CKTableView*)self.view;
        CGRect theViewFrame = self.view.bounds;
		UIView *theView = [[[UIView alloc] initWithFrame:theViewFrame] autorelease];
		theView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.view = theView;
        
		UIView *containerView = [[[UIView alloc] initWithFrame:theViewFrame] autorelease];
		containerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        containerView.backgroundColor = [UIColor clearColor];
		self.tableViewContainer = containerView;
        [self.view  addSubview:containerView];
        
		[containerView addSubview:theTableView];
	}
    
	if (self.tableView == nil) {
		if ([self.view isKindOfClass:[CKTableView class]]) {
			// TODO: Assert - Should not be allowed
			self.tableView = (CKTableView *)self.view;
		} else {
			CGRect theViewFrame = self.view.bounds;
			CKTableView *theTableView = [[[CKTableView alloc] initWithFrame:theViewFrame style:self.style] autorelease];
			theTableView.delegate = self;
			theTableView.dataSource = self;
			theTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
			[self.tableViewContainer addSubview:theTableView];
			self.tableView = theTableView;
		}
	}
    
    
    self.insetsApplied = NO;
    self.tableViewHasBeenReloaded = NO;
    
    [super viewDidLoad];
}

- (void)viewDidUnload {
    if(_tableView){
        self.tableView.delegate = nil;
        self.tableView.dataSource = nil;
        [_tableView release];
        _tableView = nil;
    }
	[_tableViewContainer release];
    _tableViewContainer = nil;
    
    [super viewDidUnload];
}


- (void)updateStylesheets{
    [self viewDidUnload];
    [self viewDidLoad];
    [self viewWillAppear:NO];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    [self sizeToFit];
    
    if(self.tableViewHasBeenReloaded == NO){
        self.tableViewHasBeenReloaded = YES;
        [self reload];
    }else{
        
        for(NSInteger section=0;section<[self.sectionsToControllers count];++section){
            NSMutableArray* controllers = [self.sectionsToControllers objectAtIndex:section];
            for(int row =0;row<[controllers count];++row){
                CKTableViewCellController* controller = (CKTableViewCellController*)[controllers objectAtIndex:row];
                [controller setInvalidatedSize:YES];
            }
        }
        
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }
    
	if (self.stickySelectionEnabled == NO){
		NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
		if([self isValidIndexPath:indexPath]){
			[self.tableView deselectRowAtIndexPath:indexPath animated:animated];
		}
	}
	else if (self.selectedIndexPath && [self isValidIndexPath:self.selectedIndexPath]){
		[self.tableView selectRowAtIndexPath:self.selectedIndexPath animated:animated scrollPosition:UITableViewScrollPositionNone];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.tableView flashScrollIndicators];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	if (self.stickySelectionEnabled == NO) [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
	else self.selectedIndexPath = [self.tableView indexPathForSelectedRow];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(onSizeChangeEnd) object:nil];
}

#pragma mark Selection

- (void)clearSelection:(BOOL)animated {
	if (self.selectedIndexPath) [self.tableView deselectRowAtIndexPath:self.selectedIndexPath animated:animated];
	self.selectedIndexPath = nil;
}

- (void)reload {
    [super reload];//didReload gets called by super class
	if (self.stickySelectionEnabled == YES && [self isValidIndexPath:self.selectedIndexPath]) {
		[self.tableView selectRowAtIndexPath:_selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
	}
}

- (void)didReload{
	if(!self.isViewDisplayed){
        self.tableViewHasBeenReloaded = NO;
		return;
    }
	
    self.isReloading = YES;
	[self.tableView reloadData];
    self.isReloading = NO;
}

- (void)setObjectController:(id)controller{
    [super setObjectController:controller];
    
    //This force a reload for the next viewWillAppear call.
    if(![self isViewDisplayed]){
        self.tableViewHasBeenReloaded = NO;
    }
}

#pragma mark Setters

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    //Invalidate all controller's size !
    for(int i =0; i< [self numberOfSections];++i){
        for(int j=0;j<[self numberOfObjectsForSection:i];++j){
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:j inSection:i];
            CKTableViewCellController* controller = (CKTableViewCellController*)[self controllerAtIndexPath:indexPath];
            controller.invalidatedSize = YES;
        }
    }
    
	[super setEditing:editing animated:animated];
	[self.tableView setEditing:editing animated:animated];
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

#pragma mark UITableView Delegate

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	self.selectedIndexPath = indexPath;
}

#pragma mark CKCollectionViewController Implementation

- (NSArray*)visibleIndexPaths{
    if(self.tableViewHasBeenReloaded == NO)
        return nil;
	return [self.tableView indexPathsForVisibleRows];
}

- (NSIndexPath*)indexPathForView:(UIView*)view{
	NSAssert([view isKindOfClass:[UITableViewCell class]],@"invalid view type");
    if([view superview] == nil)
        return nil;
    
    /* Using indexPathForRowAtPoint because indexPathForCell sometimes deletes UITableViewCell and is catched by weaks refs.
     it could happend while iterating on the weakRefs array and then crash !
     calling indexPathForRowAtPoint has the exact same behaviour but do not kill any cells !
     //NSIndexPath* indexPath =  [self.tableView indexPathForCell:(UITableViewCell*)view];
     */
    
    NSArray* indexPaths = [self.tableView indexPathsForRowsInRect:view.frame];
    if([indexPaths count] <= 0)
        return nil;
    return [indexPaths objectAtIndex:0];
}

/* implemented in parent controller now.
- (UIView*)viewAtIndexPath:(NSIndexPath *)indexPath{
	return [self.tableView cellForRowAtIndexPath:indexPath];
}
 */



/* here we have to be VERY intelligent as several rows can change their size in the "same scope" wich is not really accessible
 
 we should invalidate this if we already are in a beginUpdates scope
 we should delay the endUpdate to handle all the updateSizeForControllerAtIndexPath from several controllers
 if we are in viewWillAppear, we should not call this !
 */


- (void)onSizeChangeEnd{
    if(self.sizeIsAlreadyInvalidated){
        [[self tableView]endUpdates];
    }
    self.sizeIsAlreadyInvalidated = NO;
}

- (void)updateSizeForControllerAtIndexPath:(NSIndexPath *)index{
    if(self.state != CKViewControllerStateDidAppear || self.tableView.isLayouting || self.lockSizeChange){
        self.tableView.sizeChangedWhileReloading = YES;
        return;
    }
    
    if(self.sizeIsAlreadyInvalidated == NO){
        [[self tableView]beginUpdates];
        //[self.tableView setNeedsLayout];
    }
    self.sizeIsAlreadyInvalidated = YES;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(onSizeChangeEnd) object:nil];
    [self performSelector:@selector(onSizeChangeEnd) withObject:nil afterDelay:0.1];
}

- (UIView*)createViewAtIndexPath:(NSIndexPath*)indexPath{
    self.lockSizeChange = YES;
    UIView* view = [super createViewAtIndexPath:indexPath];
    self.lockSizeChange = NO;
    return view;
}

@end