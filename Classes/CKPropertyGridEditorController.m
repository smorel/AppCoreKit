//
//  RXPropertyGridEditorController.m
//  Prescripteur
//
//  Created by Sebastien Morel on 11-05-05.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKPropertyGridEditorController.h"

#import <CloudKit/CKNSNumberPropertyCellController.h>
#import <CloudKit/CKNSStringPropertyCellController.h>
#import <CloudKit/CKNSObject+Bindings.h>
#import <CloudKit/CKLocalization.h>
#import <CloudKit/CKOptionCellController.h>
#import "CKObjectPropertyArrayCollection.h"
#import "CKNSValueTransformer+Additions.h"

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


//PROPERTY GRID CONTROLLER
@interface CKPropertyGridEditorController() 
- (void)setup:(NSArray*)theProperties  inSection:(CKFormSection*)section;
@end

@implementation CKPropertyGridEditorController
@synthesize editorPopover = _editorPopover;

- (void)dealloc{
	[_editorPopover release];
	_editorPopover = nil;
	[super dealloc];
}

- (id)initWithObjectProperties:(NSArray*)theProperties{
	[self init];
	[self setupWithProperties:theProperties];
	return self;
}

- (id)initWithObject:(id)object representation:(NSDictionary*)representation{
	[self init];
	[self setupWithObject:object representation:representation];
	return self;
}

- (id)initWithObject:(id)object{
	[self init];
	[self setupWithObject:object];
	return self;
}

- (void)setupWithObject:(id)object{
	NSArray* propertyDescriptors = [object allPropertyDescriptors];
	NSMutableArray* theProperties = [NSMutableArray array];
	for(CKClassPropertyDescriptor* descriptor in propertyDescriptors){
		CKModelObjectPropertyMetaData* metaData = [CKModelObjectPropertyMetaData propertyMetaDataForObject:object property:descriptor];
		if(metaData.editable){
			CKObjectProperty* property = [[[CKObjectProperty alloc]initWithObject:object keyPath:descriptor.name]autorelease];
			[theProperties insertObject:property atIndex:0];
		}
	}
	[self setupWithProperties:theProperties];
}

- (void)setupWithObject:(id)object representation:(NSDictionary*)representation{
	if(representation == nil){
		return [self setupWithObject:object];
	}
	
	self.sections = [NSMutableArray array];
	for(NSString* sectionName in [representation allKeys]){
		NSArray* propertyNames = [representation objectForKey:sectionName];
		
		NSMutableArray* theProperties = [NSMutableArray array];
		for(NSString* propertyName in propertyNames){
			CKObjectProperty* property = [CKObjectProperty propertyWithObject:object keyPath:propertyName];
			[theProperties addObject:property];
		}
		CKFormSection* section = (sectionName != nil && [sectionName length] > 0) ? [CKFormSection sectionWithHeaderTitle:_(sectionName)] : [CKFormSection section];
		[self setup:theProperties inSection:section];
		[self addSection:section];
	}
	
	[self reload];
}

- (void)setupWithProperties:(NSArray*)properties{
	self.sections = [NSMutableArray array];
	
	CKFormSection* section = [CKFormSection section];
	[self setup:properties inSection:section];
	[self addSection:section];
	
	[self reload];
}

/*
- (void)popoverDateEditorForProperty:(CKObjectProperty*)property withFrame:(CGRect)frame withDirections:(UIPopoverArrowDirection)directions{
	self.editorPopover = [[[RXPopoverDateEditorController alloc]initWithObjectProperty:property]autorelease];
	self.editorPopover.parentController = self;
	[self.editorPopover presentPopoverFromRect:CGRectInset(frame, 15, 15) inView:self.tableView permittedArrowDirections:directions animated:YES];
	[property release];
}
*/

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

- (void)setupFactoryItemForStandardObject:(CKObjectViewControllerFactoryItem*)item{
	[item setCreateBlock:^(id controller){
		CKTableViewCellController* tableViewCellController = (CKTableViewCellController*)controller;
		tableViewCellController.cellStyle = CKTableViewCellStyleValue3;
		return (id)nil;
	}];
	[item setSetupBlock:^(id controller){
		CKTableViewCellController* tableViewCellController = (CKTableViewCellController*)controller;
		NSString* title = [[tableViewCellController.value class]description];
		if([tableViewCellController.value isKindOfClass:[CKObjectProperty class]]){
			CKObjectProperty* property = (CKObjectProperty*)tableViewCellController.value;
			title = [property name];
		}
		else{
			CKClassPropertyDescriptor* nameDescriptor = [tableViewCellController.value propertyDescriptorForKeyPath:@"modelName"];
			if(nameDescriptor != nil && [NSObject isKindOf:nameDescriptor.type parentType:[NSString class]]){
				title = [tableViewCellController.value valueForKeyPath:@"modelName"];
			}
		}			
		
		//ALLOW CREATION/REMOVE OF OBJECTS IN CONTAINERS 
		//FOR OBJECTS NOT CONTAINER, WE SHOULD BE ABLE TO REMOVE AKA. SET TO NIL or ADD AKA. set value selecting a type
		
		id value = tableViewCellController.value;
		if([tableViewCellController.value isKindOfClass:[CKObjectProperty class]]){
			CKObjectProperty* property = (CKObjectProperty*)tableViewCellController.value;
			value = [property value];
		}
		
		if([value isKindOfClass:[CKDocumentCollection class]]
		   || [value isKindOfClass:[NSArray class]]){
			tableViewCellController.tableViewCell.detailTextLabel.text = [NSString stringWithFormat:@"%d",[value count]];
			tableViewCellController.tableViewCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			tableViewCellController.tableViewCell.selectionStyle = UITableViewCellSelectionStyleBlue;
		}
		else if(value == nil){
			tableViewCellController.tableViewCell.detailTextLabel.text = @"nil";
			tableViewCellController.tableViewCell.accessoryType = UITableViewCellAccessoryNone;
			tableViewCellController.tableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		else{
			tableViewCellController.tableViewCell.detailTextLabel.text = [value description];
			tableViewCellController.tableViewCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			tableViewCellController.tableViewCell.selectionStyle = UITableViewCellSelectionStyleBlue;
		}
		
		tableViewCellController.tableViewCell.textLabel.text = title;
		return (id)nil;
	}];
	[item setFlags:CKItemViewFlagSelectable];
	[item setSelectionBlock:^(id controller){
		CKTableViewCellController* tableViewCellController = (CKTableViewCellController*)controller;
		
		id value = tableViewCellController.value;
		
		Class contentType = nil;
		if([tableViewCellController.value isKindOfClass:[CKObjectProperty class]]){
			CKObjectProperty* property = (CKObjectProperty*)tableViewCellController.value;
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
			
			CKObjectViewControllerFactoryItem* standard = [mappings mapControllerClass:[CKTableViewCellController class] withObjectClass:[NSObject class]];
			[self setupFactoryItemForStandardObject:standard];
			[standard setFlags:CKItemViewFlagSelectable | CKItemViewFlagRemovable];
			
			CKObjectTableViewController* controller = [[[CKObjectTableViewController alloc]initWithCollection:value mappings:mappings]autorelease];
			controller.title = tableViewCellController.tableViewCell.textLabel.text;
			if(contentType != nil){
				CKUIBarButtonItemWithInfo* button = [[[CKUIBarButtonItemWithInfo alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createObject:)]autorelease];
				button.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:value,@"collection",[NSValue valueWithPointer:contentType],@"class",controller,@"controller",nil];
				controller.rightButton = button;
			}
			[tableViewCellController.parentController.navigationController pushViewController:controller animated:YES];
		}
		else{
			CKPropertyGridEditorController* propertyGrid = [[[CKPropertyGridEditorController alloc]initWithObject:value]autorelease];
			propertyGrid.title = tableViewCellController.tableViewCell.textLabel.text;
			[tableViewCellController.parentController.navigationController pushViewController:propertyGrid animated:YES];
		}
		return (id)nil;
	}];	
}

- (void)setup:(NSArray*)properties inSection:(CKFormSection*)section{
	for(CKObjectProperty* property in properties){
		CKModelObjectPropertyMetaData* metaData = [property metaData];
		if(metaData.editable == YES /*&& [property descriptor].isReadOnly == NO*/){
			if(metaData.valuesAndLabels != nil){
				NSDictionary* copyOfValuesAndLabels = [metaData.valuesAndLabels copy];//we copy it as metaData is a reused singleton
				CKFormCellDescriptor* descriptor = [section addCellDescriptor:[CKFormCellDescriptor cellDescriptorWithValue:[property value] controllerClass:[CKOptionCellController class]]];
				[descriptor.params setObject:[CKCallback callbackWithBlock:^(id controller){
					CKOptionCellController* optionCellController = (CKOptionCellController*)controller;
					optionCellController.value = [property value];
					optionCellController.text = _(property.name);
					optionCellController.values = [copyOfValuesAndLabels allValues];
					optionCellController.labels = [copyOfValuesAndLabels allKeys];
					[optionCellController beginBindingsContextByRemovingPreviousBindings];
					[optionCellController bind:@"value" withBlock:^(id value){
						[property setValue:value];
						descriptor.value = value;
					}];
					[optionCellController endBindingsContext];
					
					return (id)nil;
				}] forKey:CKObjectViewControllerFactoryItemSetup];
			}
			else if(metaData.enumDefinition != nil){
				NSDictionary* copyOfLabelsAndValues = [metaData.enumDefinition copy];//we copy it as metaData is a reused singleton
				CKFormCellDescriptor* descriptor = [section addCellDescriptor:[CKFormCellDescriptor cellDescriptorWithValue:[property value] controllerClass:[CKOptionCellController class]]];
				[descriptor.params setObject:[CKCallback callbackWithBlock:^(id controller){
					CKOptionCellController* optionCellController = (CKOptionCellController*)controller;
					optionCellController.multiSelectionEnabled = YES;
					optionCellController.value = [property value];
					optionCellController.text = _(property.name);
					optionCellController.values = [copyOfLabelsAndValues allValues];
					NSMutableArray* localizedLabels = [NSMutableArray array];
					for(NSString* str in [copyOfLabelsAndValues allKeys]){
						[localizedLabels addObject:_(str)];
					}
					optionCellController.labels = localizedLabels;
					[optionCellController beginBindingsContextByRemovingPreviousBindings];
					[optionCellController bind:@"value" withBlock:^(id value){
						[property setValue:value];
						descriptor.value = value;
					}];
					[optionCellController endBindingsContext];
					
					return (id)nil;
				}] forKey:CKObjectViewControllerFactoryItemSetup];
			}
			else{
				CKClassPropertyDescriptor* descriptor = [property descriptor];
				switch(descriptor.propertyType){
					case CKClassPropertyDescriptorTypeChar:
					case CKClassPropertyDescriptorTypeInt:
					case CKClassPropertyDescriptorTypeShort:
					case CKClassPropertyDescriptorTypeLong:
					case CKClassPropertyDescriptorTypeLongLong:
					case CKClassPropertyDescriptorTypeUnsignedChar:
					case CKClassPropertyDescriptorTypeUnsignedInt:
					case CKClassPropertyDescriptorTypeUnsignedShort:
					case CKClassPropertyDescriptorTypeUnsignedLong:
					case CKClassPropertyDescriptorTypeUnsignedLongLong:
					case CKClassPropertyDescriptorTypeFloat:
					case CKClassPropertyDescriptorTypeDouble:
					case CKClassPropertyDescriptorTypeCppBool:
					case CKClassPropertyDescriptorTypeVoid:
					case CKClassPropertyDescriptorTypeCharString:{
						[section addCellDescriptor:[CKFormCellDescriptor cellDescriptorWithValue:property controllerClass:[CKNSNumberPropertyCellController class]]];
						break;
					}
					case CKClassPropertyDescriptorTypeObject:{
						if([NSObject isKindOf:descriptor.type parentType:[NSString class]]){
							[section addCellDescriptor:[CKFormCellDescriptor cellDescriptorWithValue:property controllerClass:[CKNSStringPropertyCellController class]]];
						}
						else if([NSObject isKindOf:descriptor.type parentType:[NSNumber class]]){
							[section addCellDescriptor:[CKFormCellDescriptor cellDescriptorWithValue:property controllerClass:[CKNSNumberPropertyCellController class]]];
						}
						else /*if([NSObject isKindOf:descriptor.type parentType:[CKDocumentCollection class]])*/{
							CKFormCellDescriptor* descriptor = [section addCellDescriptor:[CKFormCellDescriptor cellDescriptorWithValue:property controllerClass:[CKTableViewCellController class]]];
							[self setupFactoryItemForStandardObject:descriptor];
						}
						/*
						else if([NSObject isKindOf:descriptor.type parentType:[NSDate class]]){
							CKFormCellDescriptor* descriptor = [section addCellDescriptor:[CKFormCellDescriptor cellDescriptorWithValue:property controllerClass:[CKTableViewCellController class]]];
							
							[descriptor.params setObject:[CKCallback callbackWithBlock:^(id controller){
								CKTableViewCellController* tableViewCellController = (CKTableViewCellController*)controller;
								[tableViewCellController beginBindingsContextByRemovingPreviousBindings];
								[property.object bind:property.keyPath toObject:tableViewCellController.tableViewCell.detailTextLabel withKeyPath:@"text"];
								[NSObject endBindingsContext];
								
								tableViewCellController.tableViewCell.textLabel.text = _(property.name);
								if(tableViewCellController.tableViewCell.detailTextLabel.text == nil || [tableViewCellController.tableViewCell.detailTextLabel.text length] < 1){
									tableViewCellController.tableViewCell.detailTextLabel.text = @" ";//Force to create detailTextLabel
								}
								return (id)nil;
							}] forKey:CKObjectViewControllerFactoryItemSetup];
							
							[descriptor.params setObject:[CKCallback callbackWithBlock:^(id controller){
								CKTableViewCellController* tableViewCellController = (CKTableViewCellController*)controller;
								[self popoverDateEditorForProperty:property withFrame:tableViewCellController.tableViewCell.frame withDirections:UIPopoverArrowDirectionRight];
								return (id)nil;
							}] forKey:CKObjectViewControllerFactoryItemSelection];
							
						}*/
						break;
					}
				}
			}
		}
	}
}

@end
