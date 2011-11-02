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


@interface CKTableViewController ()
@property (nonatomic, retain) NSIndexPath *selectedIndexPath;
@property (nonatomic, assign) BOOL insetsApplied;
@property (nonatomic, assign) BOOL tableViewHasBeenReloaded;
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

- (void)postInit {
	[super postInit];
    self.tableViewHasBeenReloaded = NO;
    self.insetsApplied = NO;
	self.style = UITableViewStylePlain;
    self.tableViewInsets = UIEdgeInsetsMake(0,0,0,0);
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
	self.tableView = nil;
	self.tableViewContainer = nil;
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
		UIView *theView = [[[UITableView alloc] initWithFrame:theViewFrame] autorelease];
		theView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		self.view = theView;
	}
	//self.view.clipsToBounds = YES;
	
	if ([self.view isKindOfClass:[UITableView class]] == NO && self.tableViewContainer == nil) {
        UITableView* theTableView = (UITableView*)self.view;
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
		if ([self.view isKindOfClass:[UITableView class]]) {
			// TODO: Assert - Should not be allowed
			self.tableView = (UITableView *)self.view;
		} else {
			CGRect theViewFrame = self.view.bounds;
			UITableView *theTableView = [[[UITableView alloc] initWithFrame:theViewFrame style:self.style] autorelease];
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
	self.tableView = nil;
	self.tableViewContainer = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    [self sizeToFit];
    
    if(self.tableViewHasBeenReloaded == NO){
        self.tableViewHasBeenReloaded = YES;
        NSLog(@"tableView reloadData <%@>",self);
        [self.tableView reloadData];
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
	[self.tableView reloadData];
	if (self.stickySelection == YES && [self isValidIndexPath:self.selectedIndexPath]) {
		[self.tableView selectRowAtIndexPath:_selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
	}
}

#pragma mark Setters

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	[self.tableView setEditing:editing animated:animated];
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
	NSIndexPath* indexPath =  [self.tableView indexPathForCell:(UITableViewCell*)view];
    /*if(!indexPath){
        indexPath = [super indexPathForView:view];
    }*/
    if(!indexPath){
        int i =3;
    }
    return indexPath;
}

/* implemented in parent controller now.
- (UIView*)viewAtIndexPath:(NSIndexPath *)indexPath{
	return [self.tableView cellForRowAtIndexPath:indexPath];
}
 */

@end