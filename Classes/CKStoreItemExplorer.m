//
//  CKStoreItemExplorer.m
//  Express
//
//  Created by Oli Kenobi on 10-01-24.
//  Copyright 2010 Kenobi Studios. All rights reserved.
//

#import "CKStoreItemExplorer.h"
#import "CKStoreDomainExplorer.h"
#import <CloudKit/CKAttribute.h>
#import "CKReference.h"


@implementation CKStoreItemExplorer

@synthesize item = _item;

- (id)initWithItem:(CKItem *)item {
    if (self = [super initWithStyle:UITableViewStylePlain]) {
		self.item = item;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"Attributes";
	
	_attributes = [[NSMutableArray alloc] initWithArray:[_item.attributes allObjects]];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_attributes count] + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	// Retrieve the cell
	UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
	
	// Calculate the heights
	// FIXME: Calculate labels width dynamically ! ONLY WORKS IN PORTRAIT !
	CGFloat labelHeight = [cell.textLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:13] constrainedToSize:CGSizeMake(70, 100000) lineBreakMode:UILineBreakModeWordWrap].height;
	CGFloat detailedLabelHeight = [cell.detailTextLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:17] constrainedToSize:CGSizeMake(240, 100000) lineBreakMode:UILineBreakModeWordWrap].height;
	
	return MAX(labelHeight, detailedLabelHeight)+20;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
	
	if(indexPath.row == 0){
		cell.textLabel.text = @"item address";
		cell.textLabel.numberOfLines = 0;
		cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
		
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%p",self.item];
		cell.detailTextLabel.numberOfLines = 0;
		cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
		
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
	}
	else{
		CKAttribute *attr = [_attributes objectAtIndex:indexPath.row - 1];
		cell.textLabel.text = attr.name;
		cell.textLabel.numberOfLines = 0;
		cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
		
		if(attr.value != nil){
			cell.detailTextLabel.text = attr.value;
			cell.detailTextLabel.numberOfLines = 0;
			cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
			
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		else {
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%d",[attr.References count]];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		}
	}
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	
	
	CKAttribute *attr = [_attributes objectAtIndex:indexPath.row - 1];
	if(attr.value == nil){
		NSMutableArray* items = [NSMutableArray array];
		for(CKReference* ref in attr.References){
			[items addObject:ref.item];
		}
		CKStoreDomainExplorer* controller = [[[CKStoreDomainExplorer alloc]initWithItems:items]autorelease];
		controller.title = attr.name;
		[self.navigationController pushViewController:controller animated:YES];
	}
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


- (void)dealloc {
    [super dealloc];
}


@end

