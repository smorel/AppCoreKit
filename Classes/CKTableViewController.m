//
//  CKTableViewController.h
//  CloudKit
//
//  Created by Fred Brunel on 10-02-15.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//
//  Initial code created by Jonathan Wight on 2/25/09.
//  Copyright 2009 toxicsoftware.com. All rights reserved.

#import "CKTableViewController.h"
#import "CKStyleManager.h"
#import "CKStyle+Parsing.h"
#import "CKTableViewCellController+CKDynamicLayout.h"
#import <QuartzCore/QuartzCore.h>

@interface CKTableView()
@property (nonatomic,assign) NSInteger numberOfUpdates;
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
@end


@implementation CKTableViewController

@synthesize backgroundView = _backgroundView;
@synthesize tableView = _tableView;
@synthesize style = _style;
@synthesize stickySelection = _stickySelection;
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
	self.backgroundView = nil;
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
    if([controllerStyle containsObjectForKey:@"tableViewStyle"]){
        self.style = [controllerStyle enumValueForKey:@"tableViewStyle" 
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

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    [self sizeToFit];
    
    if(self.tableViewHasBeenReloaded == NO){
        self.tableViewHasBeenReloaded = YES;
        [self reload];
    }
    
	if (self.stickySelection == NO){
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
	if (self.stickySelection == NO) [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
	else self.selectedIndexPath = [self.tableView indexPathForSelectedRow];
}

#pragma mark Selection

- (void)clearSelection:(BOOL)animated {
	if (self.selectedIndexPath) [self.tableView deselectRowAtIndexPath:self.selectedIndexPath animated:animated];
	self.selectedIndexPath = nil;
}

- (void)reload {
    [super reload];//onReload gets called by super class
	if (self.stickySelection == YES && [self isValidIndexPath:self.selectedIndexPath]) {
		[self.tableView selectRowAtIndexPath:_selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
	}
}

- (void)onReload{
	if(!self.viewIsOnScreen){
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
    if(![self viewIsOnScreen]){
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

- (void)setBackgroundView:(UIView *)backgroundView {
	[_backgroundView removeFromSuperview];
	[_backgroundView release];
	if (backgroundView) {
		_backgroundView = [backgroundView retain];
		[self.view insertSubview:backgroundView belowSubview:self.tableView];
		self.tableView.backgroundColor = [UIColor clearColor];
	}
	else _backgroundView = nil;
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

#pragma mark CKItemViewContainerController Implementation

- (NSArray*)visibleIndexPaths{
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
 we should delay the endUpdate to handle all the onSizeChangeAtIndexPath from several controllers
 if we are in viewWillAppear, we should not call this !
 */


- (void)onSizeChangeEnd{
    if(self.sizeIsAlreadyInvalidated){
        [[self tableView]endUpdates];
    }
    self.sizeIsAlreadyInvalidated = NO;
}

- (void)onSizeChangeAtIndexPath:(NSIndexPath *)index{
    if(self.tableView.isLayouting || self.lockSizeChange){
        self.tableView.sizeChangedWhileReloading = YES;
        return;
    }
    
    if(self.sizeIsAlreadyInvalidated == NO){
        [[self tableView]beginUpdates];
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