//
//  IFGenericTableViewController.m
//  Thunderbird
//
//	Created by Craig Hockenberry on 1/29/09.
//	Copyright 2009 The Iconfactory. All rights reserved.
//
//  Based on work created by Matt Gallagher on 27/12/08.
//  Copyright 2008 Matt Gallagher. All rights reserved.
//	For more information: http://cocoawithlove.com/2008/12/heterogeneous-cells-in.html
//

#import "IFGenericTableViewController.h"
#import "IFCellController.h"
#import "IFTextViewTableView.h"


// NOTE: this code requires iPhone SDK 2.2. If you need to use it with SDK 2.1, you can enable
// it here. The table view resizing isn't very smooth, but at least it works :-)
#define FIRMWARE_21_COMPATIBILITY 0

@implementation IFGenericTableViewController

@synthesize tableView = _tableView;
@synthesize model;

#if FIRMWARE_21_COMPATIBILITY
- (void)awakeFromNib
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShown:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHidden:) name:UIKeyboardWillHideNotification object:nil];

	[super awakeFromNib];
}
#endif

- (id)init {
    if (self = [super init]) {
		_style = UITableViewStyleGrouped;
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style {
    if (self = [super init]) {
		_style = style;
    }
    return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	_tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:_style];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | 
	UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
	UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	[self.view addSubview:_tableView];
}


//
// constructTableGroups
//
// Creates/updates cell data. This method should only be invoked directly if
// a "reloadData" needs to be avoided. Otherwise, updateAndReload should be used.
//
- (void)constructTableGroups
{
	tableGroups = [[NSMutableArray array] retain];

	tableHeaders = [[NSMutableArray array] retain];
	tableFooters = [[NSMutableArray array] retain];
}

//
// clearTableGroups
//
// Releases the table group data (it will be recreated when next needed)
//
- (void)clearTableGroups
{
	[tableHeaders release];
	tableHeaders = nil;
	[tableFooters release];
	tableFooters = nil;
	
	[tableGroups release];
	tableGroups = nil;
}

//
// updateAndReload
//
// Performs all work needed to refresh the data and the associated display
//
- (void)updateAndReload
{
	[self clearTableGroups];
	[self constructTableGroups];
	[_tableView reloadData];
}

//
// numberOfSectionsInTableView:
//
// Return the number of sections for the table.
//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if (!tableGroups)
	{
		[self constructTableGroups];
	}
	
	return [tableGroups count];
}

//
// tableView:numberOfRowsInSection:
//
// Returns the number of rows in a given section.
//
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (!tableGroups)
	{
		[self constructTableGroups];
	}
	
	return [[tableGroups objectAtIndex:section] count];
}

//
// tableView:cellForRowAtIndexPath:
//
// Returns the cell for a given indexPath.
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (!tableGroups)
	{
		[self constructTableGroups];
	}
	
	return
		[[[tableGroups objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]
			tableView:(UITableView *)tableView
			cellForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!tableGroups) {
		[self constructTableGroups];
	}
	
	NSObject<IFCellController> *cellData =
	[[tableGroups objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	if ([cellData respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
		return [cellData tableView:tableView heightForRowAtIndexPath:indexPath];
	}
	return 44.0f;
}


//
// tableView:didSelectRowAtIndexPath:
//
// Handle row selection
//
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!tableGroups) {
		[self constructTableGroups];
	}
	
	NSObject<IFCellController> *cellData =
	[[tableGroups objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	if ([cellData respondsToSelector:@selector(tableView:willSelectRowAtIndexPath:)]) {
		return [cellData tableView:tableView willSelectRowAtIndexPath:indexPath];
	}
	return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (!tableGroups)
	{
		[self constructTableGroups];
	}
	
	NSObject<IFCellController> *cellData =
		[[tableGroups objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	if ([cellData respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)])
	{
		[cellData tableView:tableView didSelectRowAtIndexPath:indexPath];
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (!tableGroups)
	{
		[self constructTableGroups];
	}
	
	NSString *title = nil;
	if (tableHeaders)
	{
		id object = [tableHeaders objectAtIndex:section];
		if ([object isKindOfClass:[NSString class]])
		{
			if ([object length] > 0)
			{
				title = object;
			}
		}
	}
	
	return title;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	if (!tableGroups)
	{
		[self constructTableGroups];
	}
	
	NSString *title = nil;
	if (tableFooters)
	{
		id object = [tableFooters objectAtIndex:section];
		if ([object isKindOfClass:[NSString class]])
		{
			if ([object length] > 0)
			{
				title = object;
			}
		}
	}

	return title;
}

//
// didReceiveMemoryWarning
//
// Release any cache data.
//
- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	
	[self clearTableGroups];
}

//
// dealloc
//
// Release instance memory
//
- (void)dealloc
{
#if FIRMWARE_21_COMPATIBILITY
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
#endif

	self.model = nil;

	[_tableView release];
	[self clearTableGroups];
	[super dealloc];
}

- (void)validate:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)loadView
{
#if 0
	// NOTE: This code circumvents the normal loading of the UITableView and replaces it with an instance
	// of IFTextViewTableView (which includes a workaround for the hit testing problems in a UITextField.)
	// Check the header file for IFTextViewTableView to see why this is important.
	//
	// Since there is no style accessor on UITableViewController (to obtain the value passed in with the
	// initWithStyle: method), the value is hard coded for this use case. Too bad.

	self.view = [[[IFTextViewTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped] autorelease];
	[(IFTextViewTableView *)self.view setDelegate:self];
	[(IFTextViewTableView *)self.view setDataSource:self];
	[self.view setAutoresizesSubviews:YES];
	[self.view setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
#else
	[super loadView];
#endif
}

- (void)viewWillAppear:(BOOL)animated
{
	// rows (such as choices) that were updated in child view controllers need to be updated
	[_tableView reloadData];
	
	[super viewWillAppear:animated];
}

#if FIRMWARE_21_COMPATIBILITY

- (void)keyboardShown:(NSNotification *)notification
{
	CGRect keyboardBounds;
	[[[notification userInfo] valueForKey:UIKeyboardBoundsUserInfoKey] getValue:&keyboardBounds];
	
	CGRect tableViewFrame = [_tableView frame];
	tableViewFrame.size.height -= keyboardBounds.size.height;

	[_tableView setFrame:tableViewFrame];
}

- (void)keyboardHidden:(NSNotification *)notification
{
	CGRect keyboardBounds;
	[[[notification userInfo] valueForKey:UIKeyboardBoundsUserInfoKey] getValue:&keyboardBounds];
	
	CGRect tableViewFrame = [_tableView frame];
	tableViewFrame.size.height += keyboardBounds.size.height;

	[_tableView setFrame:tableViewFrame];
}

#endif


// Section Methods

- (void)addSection:(NSArray *)rows withHeaderText:(NSString *)headerText andFooterText:(NSString *)footerText {
	if (!tableGroups) [self constructTableGroups];

	if (!rows) rows = [NSArray array];
	[tableGroups addObject:rows];
	
	if (!headerText) [tableHeaders addObject:[NSNull null]];
	else [tableHeaders addObject:headerText];
	
	if (!footerText) [tableFooters addObject:[NSNull null]];
	else [tableFooters addObject:footerText];
}

@end

