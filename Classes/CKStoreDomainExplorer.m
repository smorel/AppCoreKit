//
//  CKStoreDomainExplorer.m
//  Express
//
//  Created by Oli Kenobi on 10-01-24.
//  Copyright 2010 Kenobi Studios. All rights reserved.
//

#import "CKStoreDomainExplorer.h"
#import <CloudKit/CKStore.h>
#import <CloudKit/CKItem.h>
#import <CloudKit/CKAttribute.h>
#import "CKStoreItemExplorer.h"
#import "CKLocalization.h"

@implementation CKStoreDomainExplorer

@synthesize domain = _domain;
@synthesize items = _items;


- (id)initWithDomain:(NSString *)domain {
    if (self = [super initWithStyle:UITableViewStylePlain]) {
		self.domain = domain;
		self.title = @"Items";
    }
    return self;
}

- (id)initWithItems:(NSMutableArray *)theitems{
	if (self = [super initWithStyle:UITableViewStylePlain]) {
		self.items = theitems;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
//	_items = [[NSMutableArray alloc] init];
	if(_domain && _items == nil){
		CKStore *store = [CKStore storeWithDomainName:_domain];
		self.items = [[NSMutableArray alloc] initWithArray:[store fetchItems]];
	}
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	UIBarButtonItem* clearButton = [[[UIBarButtonItem alloc] initWithTitle:_(@"Clear") style:UIBarButtonItemStylePlain target:self action:@selector(clear:)]autorelease];
	[self.navigationItem setRightBarButtonItem:clearButton animated:NO];
}

- (void)clear:(id)sender{
	CKStore* store = [CKStore storeWithDomainName:_domain];
	[self.items removeAllObjects];
	[store deleteItems:self.items];
	[self.tableView reloadData];
}

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
    return [_items count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }

	CKItem *item = [_items objectAtIndex:indexPath.row];
	CKAttribute* typeAttribute = [item attributeNamed:@"@class" createIfNotFound:NO];
	if(typeAttribute == nil){
		cell.textLabel.text = item.name;
	}
	else{
		cell.textLabel.text = [NSString stringWithFormat:@"[%@] %@",typeAttribute.value,item.name];
	}
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", item.createdAt];

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	CKStoreItemExplorer *itemExplorer = [[CKStoreItemExplorer alloc] initWithItem:[_items objectAtIndex:indexPath.row]];
	[self.navigationController pushViewController:itemExplorer animated:YES];
	[itemExplorer release];
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
	[_domain release];
	[_items release];
    [super dealloc];
}


@end

