//
//  CKNSObjectPropertyCellController.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-06-09.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKNSObjectPropertyCellController.h"

#import "CKNSNumberPropertyCellController.h"
#import "CKNSStringPropertyCellController.h"
#import "CKNSObject+Bindings.h"
#import "CKLocalization.h"
#import "CKOptionCellController.h"
#import "CKObjectPropertyArrayCollection.h"
#import "CKNSValueTransformer+Additions.h"
#import "CKNSObjectPropertyCellController.h"
#import "CKNSObject+InlineDebugger.h"

#import "CKClassExplorer.h"

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

@interface CKUIButtonWithInfo : UIButton{
	id userInfo;
}
@property(nonatomic,retain)id userInfo;
@end

@implementation CKUIButtonWithInfo
@synthesize userInfo;
- (void)dealloc{
	[userInfo release];
	[super dealloc];
}
@end

@implementation CKNSObjectPropertyCellController

- (void)initTableViewCell:(UITableViewCell*)cell{
	[super initTableViewCell:cell];
}

- (void)setup{
	UITableViewCell* cell = self.tableViewCell;
	
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
		cell.accessoryView = nil;
	}
	else if(value == nil){
		cell.detailTextLabel.text = @"nil";
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		/*if([self.value isKindOfClass:[CKObjectProperty class]]){
			CKObjectProperty* property = (CKObjectProperty*)self.value;
			CKClassPropertyDescriptor* descriptor = [property descriptor];
			CKUIButtonWithInfo* button = [[[CKUIButtonWithInfo alloc]initWithFrame:CGRectMake(0,0,100,40)]autorelease];
			button.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSValue valueWithPointer:descriptor.type],@"class",property,@"property",nil];
			[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
			[button setTitle:@"Create" forState:UIControlStateNormal];
			[button addTarget:self action:@selector(createObject:) forControlEvents:UIControlEventTouchUpInside];
			self.tableViewCell.accessoryView = button;
		}*/
	}
	else{
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ <%p>",[value class],value];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		/*if([self.value isKindOfClass:[CKObjectProperty class]]){
			CKObjectProperty* property = (CKObjectProperty*)self.value;
			CKClassPropertyDescriptor* descriptor = [property descriptor];
			CKUIButtonWithInfo* button = [[[CKUIButtonWithInfo alloc]initWithFrame:CGRectMake(0,0,100,40)]autorelease];
			button.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSValue valueWithPointer:descriptor.type],@"class",property,@"property",nil];
			[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
			[button setTitle:@"Delete" forState:UIControlStateNormal];
			[button addTarget:self action:@selector(deleteObject:) forControlEvents:UIControlEventTouchUpInside];
			self.tableViewCell.accessoryView = button;
		}*/
	}
	
	cell.textLabel.text = title;
}

- (void)setupCell:(UITableViewCell *)cell {
	[self clearBindingsContext];
	[super setupCell:cell];
	[self setup];
	
	if([self.value isKindOfClass:[CKObjectProperty class]]){
		CKObjectProperty* property = (CKObjectProperty*)self.value;
		id value = [property value];
		if(![value isKindOfClass:[CKDocumentCollection class]]
           && ![property.object isKindOfClass:[NSDictionary class]]){
			[self beginBindingsContextByRemovingPreviousBindings];
			[property.object bind:property.keyPath withBlock:^(id value){
				[self setup];
			}];
			[self endBindingsContext];
		}
	}
}

- (void)didSelectRow{
	id thevalue = self.value;
	
	Class contentType = nil;
	Protocol* contentProtocol = nil;
	if([self.value isKindOfClass:[CKObjectProperty class]]){
		CKObjectProperty* property = (CKObjectProperty*)self.value;
		CKClassPropertyDescriptor* descriptor = [property descriptor];
		
		CKObjectPropertyMetaData* metaData = [property metaData];
		contentType = [metaData contentType];
		contentProtocol = [metaData contentProtocol];
		
		//Wrap the array in a virtual collection
		if([NSObject isKindOf:descriptor.type parentType:[NSArray class]]){
			thevalue = [CKObjectPropertyArrayCollection collectionWithArrayProperty:property];
		}		
		else{
			thevalue = [property value];
		}
	}
	
	if([thevalue isKindOfClass:[CKDocumentCollection class]]){
		NSMutableArray* mappings = [NSMutableArray array]; 
        //TODO FIXME : here NSString & NSNumber will not be encapsulated in CKObjectProperty :
        //That means CKNSNumberPropertyCellController, CKNSStringPropertyCellController should be able to manage values that are not CKObjectProperty
		[mappings mapControllerClass:[CKNSNumberPropertyCellController class] withObjectClass:[NSNumber class]];
		[mappings mapControllerClass:[CKNSStringPropertyCellController class] withObjectClass:[NSString class]];
		[mappings mapControllerClass:[CKNSObjectPropertyCellController class] withObjectClass:[NSObject class]];
		CKObjectTableViewController* controller = [[[CKObjectTableViewController alloc]initWithCollection:thevalue mappings:mappings]autorelease];
        controller.style = [[(CKTableViewController*)self.parentController tableView]style];
        controller.name = @"CKInlineDebugger";
		controller.title = self.tableViewCell.textLabel.text;
		if(contentType != nil || contentProtocol != nil){
			CKUIBarButtonItemWithInfo* button = [[[CKUIBarButtonItemWithInfo alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createObject:)]autorelease];
			button.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:self.value,@"property",[NSValue valueWithPointer:contentType],@"class",[NSValue valueWithPointer:contentProtocol],@"protocol",controller,@"controller",nil];
			controller.rightButton = button;
		}
		[self.parentController.navigationController pushViewController:controller animated:YES];
	}
	else{
        CKFormTableViewController* debugger = [[thevalue class]inlineDebuggerForObject:thevalue];
        debugger.title = self.tableViewCell.textLabel.text;
		[self.parentController.navigationController pushViewController:debugger animated:YES];
	}
}

- (void)createObject:(id)sender{
	[self clearBindingsContext];
	
	id userInfos = nil;
	if([sender isKindOfClass:[CKUIButtonWithInfo class]]){
		CKUIButtonWithInfo* button = (CKUIButtonWithInfo*)sender;
		userInfos = button.userInfo;
	}
	else if([sender isKindOfClass:[CKUIBarButtonItemWithInfo class]]){
		CKUIBarButtonItemWithInfo* button = (CKUIBarButtonItemWithInfo*)sender;
		userInfos = button.userInfo;
	}
	
	Class type = [[userInfos objectForKey:@"class"]pointerValue];
	Protocol* protocol = [[userInfos objectForKey:@"protocol"]pointerValue];
	
	CKClassExplorer* controller = protocol ? [[[CKClassExplorer alloc]initWithProtocol:protocol]autorelease] : [[[CKClassExplorer alloc]initWithBaseClass:type]autorelease];
	controller.userInfo = userInfos;
	controller.delegate = self;
	[self.parentController.navigationController pushViewController:controller animated:YES];
}

- (void)deleteObject:(id)sender{
	CKUIButtonWithInfo* button = (CKUIButtonWithInfo*)sender;
	
	CKObjectProperty* property = [ button.userInfo objectForKey:@"property"];
	[property setValue:nil];
}

- (void)itemViewContainerController:(CKItemViewContainerController*)controller didSelectViewAtIndexPath:(NSIndexPath*)indexPath withObject:(id)object{
	CKClassExplorer* classExplorer = (CKClassExplorer*)controller;
	
	
	id instance = nil;
	if([object isKindOfClass:[NSString class]]){
		NSString* className = (NSString*)object;
		Class type = NSClassFromString(className);
		if([NSObject isKindOf:type parentType:[UIView class]]){
			instance = [[[type alloc]initWithFrame:CGRectMake(0,0,100,100)]autorelease];
		}
		else{
			instance = [[[type alloc]init]autorelease];
		}
	}
	else if([object isKindOfClass:[NSObject class]]){
		instance = object;
	}
	
	CKObjectProperty* property = [classExplorer.userInfo objectForKey:@"property"];
	if([NSObject isKindOf:property.descriptor.type parentType:[CKDocumentCollection class]]){
		CKDocumentCollection* collection = (CKDocumentCollection*)[property value];
		[collection addObjectsFromArray:[NSArray arrayWithObject:instance]];
	}
	else{
		[property setValue:instance];
	}
	
	[controller.navigationController popViewControllerAnimated:NO];
	
	//push the new object
	NSString* title = [[instance class]description];
	CKClassPropertyDescriptor* nameDescriptor = [instance propertyDescriptorForKeyPath:@"modelName"];
	if(nameDescriptor != nil && [NSObject isKindOf:nameDescriptor.type parentType:[NSString class]]){
		title = [instance valueForKeyPath:@"modelName"];
	}
	
    CKFormTableViewController* debugger = [[instance class]inlineDebuggerForObject:instance];
	debugger.title = title;
    
	/*
	 NSIndexPath* indexPath = [controller indexPathForObject:object];
	 [controller.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
	 */
}

- (void)rotateCell:(UITableViewCell*)cell withParams:(NSDictionary*)params animated:(BOOL)animated{
	[super rotateCell:cell withParams:params animated:animated];
}

+ (CKItemViewFlags)flagsForObject:(id)object withParams:(NSDictionary*)params{
	id value = object;
	if([object isKindOfClass:[CKObjectProperty class]]){
		CKObjectProperty* property = (CKObjectProperty*)object;
		value = [property value];
	}
	
	if(value == nil){
		return CKItemViewFlagNone;
	}
	
	if([object isKindOfClass:[CKObjectProperty class]]){
		return CKItemViewFlagSelectable;
	}
	
	//TODO prendre en compte le readonly pour create/remove
	return CKItemViewFlagSelectable | CKItemViewFlagRemovable;
}

@end
