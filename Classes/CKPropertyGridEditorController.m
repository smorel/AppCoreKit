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
#import "CKUIImagePropertyCellController.h"

#import "CKCallback.h"


//PROPERTY GRID CONTROLLER
@interface CKPropertyGridEditorController() 
@property (nonatomic, retain) id object;
- (void)setup:(NSArray*)theProperties  inSection:(CKFormSection*)section;
@end

@implementation CKPropertyGridEditorController
@synthesize editorPopover = _editorPopover;
@synthesize object = _object;

- (void)postInit{
    [super postInit];
    self.searchEnabled = YES;
	self.liveSearchDelay = 0.5;
}

- (void)dealloc{
	[_editorPopover release];
	_editorPopover = nil;
	[_object release];
	_object = nil;
	[super dealloc];
}

- (id)initWithObjectProperties:(NSArray*)theProperties{
	[self initWithStyle:UITableViewStyleGrouped];
	[self setupWithProperties:theProperties];
	return self;
}

- (id)initWithObject:(id)object{
	[self initWithStyle:UITableViewStyleGrouped];
	[self setupWithObject:object];
	return self;
}

- (void)setupWithObject:(id)theobject{
	[self setupWithObject:theobject withFilter:nil];
}

- (void)setupWithObject:(id)theobject withFilter:(NSString*)filter{
	NSString* lowerCaseFilter = [filter lowercaseString];
	
	self.object = theobject;
	NSArray* propertyDescriptors = [_object allPropertyDescriptors];
	NSMutableArray* theProperties = [NSMutableArray array];
	for(CKClassPropertyDescriptor* descriptor in propertyDescriptors){
		NSString* lowerCaseProperty = [descriptor.name lowercaseString];
		BOOL useProperty = YES;
		if(filter != nil){
			NSRange range = [lowerCaseProperty rangeOfString:lowerCaseFilter];
			useProperty = (range.location != NSNotFound);
		}
		if(useProperty){
			CKObjectPropertyMetaData* metaData = [CKObjectPropertyMetaData propertyMetaDataForObject:_object property:descriptor];
			if(metaData.editable){
				CKObjectProperty* property = [[[CKObjectProperty alloc]initWithObject:theobject keyPath:descriptor.name]autorelease];
				[theProperties insertObject:property atIndex:0];
			}
		}
	}
	[self setupWithProperties:theProperties];
}

- (void)setupWithProperties:(NSArray*)properties{
	[self clear];
	
	CKFormSection* section = [CKFormSection section];
	[self setup:properties inSection:section];
	[self addSection:section];
	[self reload];
}

- (void)setup:(NSArray*)properties inSection:(CKFormSection*)section{
	for(CKObjectProperty* property in properties){
		CKObjectPropertyMetaData* metaData = [property metaData];
		if(metaData.editable == YES /*&& [property descriptor].isReadOnly == NO*/){
			if(metaData.valuesAndLabels != nil){
				NSDictionary* copyOfValuesAndLabels = [metaData.valuesAndLabels copy];//we copy it as metaData is a reused singleton
				CKFormCellDescriptor* descriptor = [section addCellDescriptor:[CKFormCellDescriptor cellDescriptorWithValue:[property value] controllerClass:[CKOptionCellController class]]];
                [descriptor setCreateBlock:^(id controller){
					CKOptionCellController* optionCellController = (CKOptionCellController*)controller;
                    optionCellController.cellStyle = CKTableViewCellStylePropertyGrid;
                    return (id)nil;
				}];
				[descriptor setSetupBlock:^(id controller){
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
				}];
			}
			else if(metaData.enumDescriptor != nil){
				NSDictionary* copyOfLabelsAndValues = [metaData.enumDescriptor.valuesAndLabels copy];//we copy it as metaData is a reused singleton
				CKFormCellDescriptor* descriptor = [section addCellDescriptor:[CKFormCellDescriptor cellDescriptorWithValue:[property value] controllerClass:[CKOptionCellController class]]];
                [descriptor setCreateBlock:^(id controller){
					CKOptionCellController* optionCellController = (CKOptionCellController*)controller;
                    optionCellController.cellStyle = CKTableViewCellStylePropertyGrid;
                    return (id)nil;
				}];
				[descriptor setSetupBlock:^(id controller){
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
				}];
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
						else if([NSObject isKindOf:descriptor.type parentType:[UIImage class]]){
							[section addCellDescriptor:[CKFormCellDescriptor cellDescriptorWithValue:property controllerClass:[CKUIImagePropertyCellController class]]];
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

- (void)didSearch:(NSString*)text{
	if(_object){
		if([text length] < 1){
			[self setupWithObject:_object];
		}
		else{
			[self setupWithObject:_object withFilter:text];
		}
	}
}

@end
