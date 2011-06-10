//
//  RXPropertyGridEditorController.m
//  Prescripteur
//
//  Created by Sebastien Morel on 11-05-05.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKPropertyGridEditorController.h"

#import "CKNSNumberPropertyCellController.h"
#import "CKNSStringPropertyCellController.h"
#import "CKNSObject+Bindings.h"
#import "CKLocalization.h"
#import "CKOptionCellController.h"
#import "CKObjectPropertyArrayCollection.h"
#import "CKNSValueTransformer+Additions.h"
#import "CKNSObjectPropertyCellController.h"
#import "CKUIColorPropertyCellController.h"
#import "CKNSDatePropertyCellController.h"
#import "CKCGPropertyCellControllers.h"

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

- (void)setup:(NSArray*)properties inSection:(CKFormSection*)section{
	for(CKObjectProperty* property in properties){
		CKModelObjectPropertyMetaData* metaData = [property metaData];
		if(metaData.editable == YES /*&& [property descriptor].isReadOnly == NO*/){
			if(metaData.valuesAndLabels != nil){
				NSDictionary* copyOfValuesAndLabels = [metaData.valuesAndLabels copy];//we copy it as metaData is a reused singleton
				CKFormCellDescriptor* descriptor = [section addCellDescriptor:[CKFormCellDescriptor cellDescriptorWithValue:[property value] controllerClass:[CKOptionCellController class]]];
				[descriptor.params setObject:[CKCallback callbackWithBlock:^(id controller){
					CKOptionCellController* optionCellController = (CKOptionCellController*)controller;
					[optionCellController beginBindingsContextByRemovingPreviousBindings];
					optionCellController.value = [property value];
					optionCellController.text = _(property.name);
					optionCellController.values = [copyOfValuesAndLabels allValues];
					optionCellController.labels = [copyOfValuesAndLabels allKeys];
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
					[optionCellController beginBindingsContextByRemovingPreviousBindings];
					optionCellController.multiSelectionEnabled = YES;
					optionCellController.value = [property value];
					optionCellController.text = _(property.name);
					optionCellController.values = [copyOfLabelsAndValues allValues];
					NSMutableArray* localizedLabels = [NSMutableArray array];
					for(NSString* str in [copyOfLabelsAndValues allKeys]){
						[localizedLabels addObject:_(str)];
					}
					optionCellController.labels = localizedLabels;
					[optionCellController bind:@"value" withBlock:^(id value){
						if(value == nil || [value isKindOfClass:[NSNull class]]){
							[property setValue:[NSNumber numberWithInt:0]];
							descriptor.value = [NSNumber numberWithInt:0];
						}
						else{
							[property setValue:value];
							descriptor.value = value;
						}
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
						else if([NSObject isKindOf:descriptor.type parentType:[UIColor class]]){
							[section addCellDescriptor:[CKFormCellDescriptor cellDescriptorWithValue:property controllerClass:[CKUIColorPropertyCellController class]]];
						}
						else if([NSObject isKindOf:descriptor.type parentType:[NSDate class]]){
							[section addCellDescriptor:[CKFormCellDescriptor cellDescriptorWithValue:property controllerClass:[CKNSDatePropertyCellController class]]];
						}
						else{
							[section addCellDescriptor:[CKFormCellDescriptor cellDescriptorWithValue:property controllerClass:[CKNSObjectPropertyCellController class]]];
						}
						break;
					}
					case CKClassPropertyDescriptorTypeStruct:
					{
						NSString* controllerClassName = [NSString stringWithFormat:@"CK%@PropertyCellController",descriptor.className];
						Class controllerClass = NSClassFromString(controllerClassName);
						if(controllerClass){
							[section addCellDescriptor:[CKFormCellDescriptor cellDescriptorWithValue:property controllerClass:controllerClass]];
						}
						break;
					}
				}
			}
		}
	}
}

@end
