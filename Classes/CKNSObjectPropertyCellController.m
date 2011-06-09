//
//  CKNSObjectPropertyCellController.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-06-09.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKNSObjectPropertyCellController.h"

#import "CKPropertyGridEditorController.h"

#import "CKNSNumberPropertyCellController.h"
#import "CKNSStringPropertyCellController.h"
#import "CKNSObject+Bindings.h"
#import "CKLocalization.h"
#import "CKOptionCellController.h"
#import "CKObjectPropertyArrayCollection.h"
#import "CKNSValueTransformer+Additions.h"
#import "CKNSObjectPropertyCellController.h"

@interface CKUIBarButtonItemWithInfo : UIBarButtonItem{
	id userInfo;
}
@property(nonatomic,retain)id userInfo;
@end

@implementation CKUIBarButtonItemWithInfo
@synthesize userInfo;
- (void)dealloc{
	[userInfo release];
	[super dealloc];
}
@end


@implementation CKNSObjectPropertyCellController

- (id)init{
	[super init];
	self.cellStyle = CKTableViewCellStyleValue3;
	return self;
}

-(void)dealloc{
	[super dealloc];
}


- (void)initTableViewCell:(UITableViewCell*)cell{
}


- (void)setupCell:(UITableViewCell *)cell {
	[super setupCell:cell];
	
	NSString* title = [[self.value class]description];
	if([self.value isKindOfClass:[CKObjectProperty class]]){
		CKObjectProperty* property = (CKObjectProperty*)self.value;
		title = [property name];
	}
	else{
		CKClassPropertyDescriptor* nameDescriptor = [self.value propertyDescriptorForKeyPath:@"modelName"];
		if(nameDescriptor != nil && [NSObject isKindOf:nameDescriptor.type parentType:[NSString class]]){
			title = [self.value valueForKeyPath:@"modelName"];
		}
	}
	
	id value = self.value;
	if([self.value isKindOfClass:[CKObjectProperty class]]){
		CKObjectProperty* property = (CKObjectProperty*)self.value;
		value = [property value];
	}
	
	if([value isKindOfClass:[CKDocumentCollection class]]
	   || [value isKindOfClass:[NSArray class]]){
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%d",[value count]];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	}
	else if(value == nil){
		cell.detailTextLabel.text = @"nil";
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	else{
		cell.detailTextLabel.text = [value description];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	}
	
	cell.textLabel.text = title;
}

- (void)didSelectRow{
	id value = self.value;
	
	Class contentType = nil;
	if([self.value isKindOfClass:[CKObjectProperty class]]){
		CKObjectProperty* property = (CKObjectProperty*)self.value;
		CKClassPropertyDescriptor* descriptor = [property descriptor];
		
		CKModelObjectPropertyMetaData* metaData = [property metaData];
		contentType = [metaData contentType];
		
		//Wrap the array in a virtual collection
		if([NSObject isKindOf:descriptor.type parentType:[NSArray class]]){
			value = [CKObjectPropertyArrayCollection collectionWithArrayProperty:property];
		}		
		else{
			value = [property value];
		}
	}
	
	if([value isKindOfClass:[CKDocumentCollection class]]){
		NSMutableArray* mappings = [NSMutableArray array]; 
		[mappings mapControllerClass:[CKNSNumberPropertyCellController class] withObjectClass:[NSNumber class]];
		[mappings mapControllerClass:[CKNSStringPropertyCellController class] withObjectClass:[NSString class]];
		[mappings mapControllerClass:[CKNSObjectPropertyCellController class] withObjectClass:[NSObject class]];
		CKObjectTableViewController* controller = [[[CKObjectTableViewController alloc]initWithCollection:value mappings:mappings]autorelease];
		controller.title = self.tableViewCell.textLabel.text;
		if(contentType != nil){
			CKUIBarButtonItemWithInfo* button = [[[CKUIBarButtonItemWithInfo alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createObject:)]autorelease];
			button.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:value,@"collection",[NSValue valueWithPointer:contentType],@"class",controller,@"controller",nil];
			controller.rightButton = button;
		}
		[self.parentController.navigationController pushViewController:controller animated:YES];
	}
	else{
		CKPropertyGridEditorController* propertyGrid = [[[CKPropertyGridEditorController alloc]initWithObject:value]autorelease];
		propertyGrid.title = self.tableViewCell.textLabel.text;
		[self.parentController.navigationController pushViewController:propertyGrid animated:YES];
	}
}

- (void)createObject:(id)sender{
	CKUIBarButtonItemWithInfo* button = (CKUIBarButtonItemWithInfo*)sender;
	CKDocumentCollection* collection = [button.userInfo objectForKey:@"collection"];
	Class type = [[button.userInfo objectForKey:@"class"]pointerValue];
	//CKObjectTableViewController* controller = [button.userInfo objectForKey:@"controller"];
	
	id object = [[[type alloc]init]autorelease];
	[collection addObjectsFromArray:[NSArray arrayWithObject:object]];
	
	/*
	 NSIndexPath* indexPath = [controller indexPathForObject:object];
	 [controller.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
	 */
}

+ (NSValue*)viewSizeForObject:(id)object withParams:(NSDictionary*)params{
	return [NSValue valueWithCGSize:CGSizeMake(100,44)];
}

- (void)rotateCell:(UITableViewCell*)cell withParams:(NSDictionary*)params animated:(BOOL)animated{
	[super rotateCell:cell withParams:params animated:animated];
}

+ (CKItemViewFlags)flagsForObject:(id)object withParams:(NSDictionary*)params{
	return CKItemViewFlagSelectable | CKItemViewFlagRemovable;
}

@end
