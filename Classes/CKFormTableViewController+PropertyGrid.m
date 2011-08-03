//
//  CKFormTableViewController+PropertyGrid.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-07-29.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKFormTableViewController+PropertyGrid.h"
#import "CKObjectProperty.h"
#import "CKLocalization.h"

#import "CKNSNumberPropertyCellController.h"
#import "CKNSStringPropertyCellController.h"
#import "CKNSObject+Bindings.h"
#import "CKOptionCellController.h"
#import "CKObjectPropertyArrayCollection.h"
#import "CKNSValueTransformer+Additions.h"
#import "CKNSObjectPropertyCellController.h"
#import "CKUIColorPropertyCellController.h"
#import "CKNSDatePropertyCellController.h"
#import "CKCGPropertyCellControllers.h"
#import "CKUIImagePropertyCellController.h"

#import "CKNSObject+Introspection.h"
#import "CKNSNotificationCenter+Edition.h"

@interface CKFormTableViewController(CKPropertyGridPrivate)
- (void)setup:(NSArray*)properties inSection:(CKFormSection*)section;
- (NSArray*)propertyNamesForObject:(id)object withFilter:(NSString*)filter;
@end

@implementation CKFormTableViewController(CKPropertyGridPrivate)

- (NSArray*)propertyNamesForObject:(id)object withFilter:(NSString*)filter{
	NSString* lowerCaseFilter = [filter lowercaseString];
    
    NSArray* propertyDescriptors = [object allPropertyDescriptors];
	NSMutableArray* theProperties = [NSMutableArray array];
	for(CKClassPropertyDescriptor* descriptor in propertyDescriptors){
		NSString* lowerCaseProperty = [descriptor.name lowercaseString];
		BOOL useProperty = YES;
		if(filter != nil){
			NSRange range = [lowerCaseProperty rangeOfString:lowerCaseFilter];
			useProperty = (range.location != NSNotFound);
		}
		if(useProperty){
			CKModelObjectPropertyMetaData* metaData = [CKModelObjectPropertyMetaData propertyMetaDataForObject:object property:descriptor];
			if(metaData.editable){
				[theProperties insertObject:descriptor.name atIndex:0];
			}
		}
	}
    return theProperties;
}

- (void)setup:(NSArray*)properties inSection:(CKFormSection*)section{
    for(CKObjectProperty* property in properties){
		CKModelObjectPropertyMetaData* metaData = [property metaData];
		if(metaData.editable == YES){
            if(metaData.propertyCellControllerClass != nil){
                NSAssert([NSObject isKindOf:metaData.propertyCellControllerClass parentType:[CKTableViewCellController class]],@"invalid propertyCellControllerClass defined for property : %@",property);
                [section addCellDescriptor:[CKFormCellDescriptor cellDescriptorWithValue:property controllerClass:metaData.propertyCellControllerClass]];
            }
			else if(metaData.valuesAndLabels != nil){
				NSDictionary* copyOfValuesAndLabels = [metaData.valuesAndLabels copy];//we copy it as metaData is a reused singleton
                
                NSInteger index = [[copyOfValuesAndLabels allValues]indexOfObject:[property value]];
				CKFormCellDescriptor* descriptor = [section addCellDescriptor:[CKFormCellDescriptor cellDescriptorWithValue:[NSNumber numberWithInt:index] controllerClass:[CKOptionCellController class]]];
                [descriptor setCreateBlock:^(id controller){
					CKOptionCellController* optionCellController = (CKOptionCellController*)controller;
                    optionCellController.cellStyle = CKTableViewCellStylePropertyGrid;
                    return (id)nil;
				}];
				[descriptor setSetupBlock:^(id controller){
					CKOptionCellController* optionCellController = (CKOptionCellController*)controller;
					[optionCellController beginBindingsContextByRemovingPreviousBindings];
                    NSInteger index = [[copyOfValuesAndLabels allValues]indexOfObject:[property value]];
                    optionCellController.value = [NSNumber numberWithInt:index];
					optionCellController.text = _(property.name);
					optionCellController.values = [copyOfValuesAndLabels allValues];
					optionCellController.labels = [copyOfValuesAndLabels allKeys];
					[optionCellController bind:@"currentValue" withBlock:^(id value){
						[property setValue:value];
                        [[NSNotificationCenter defaultCenter]notifyPropertyChange:property];
                        
                        NSInteger index = [[copyOfValuesAndLabels allValues]indexOfObject:[property value]];
                        descriptor.value = [NSNumber numberWithInt:index];
					}];
					[optionCellController endBindingsContext];
					return (id)nil;
				}];
			}
			else if(metaData.enumDefinition != nil){
				NSDictionary* copyOfLabelsAndValues = [metaData.enumDefinition copy];//we copy it as metaData is a reused singleton
				CKFormCellDescriptor* descriptor = [section addCellDescriptor:[CKFormCellDescriptor cellDescriptorWithValue:[property value] controllerClass:[CKOptionCellController class]]];
                [descriptor setCreateBlock:^(id controller){
					CKOptionCellController* optionCellController = (CKOptionCellController*)controller;
                    optionCellController.cellStyle = CKTableViewCellStylePropertyGrid;
                    return (id)nil;
				}];
				[descriptor setSetupBlock:^(id controller){
					CKOptionCellController* optionCellController = (CKOptionCellController*)controller;
					[optionCellController beginBindingsContextByRemovingPreviousBindings];
					optionCellController.multiSelectionEnabled = metaData.multiselectionEnabled;
                    if(optionCellController.multiSelectionEnabled){
                        optionCellController.value = [property value];
                    }
                    else{
                        NSInteger index = [[copyOfLabelsAndValues allValues]indexOfObject:[property value]];
                        optionCellController.value = [NSNumber numberWithInt:index];
                    }
					optionCellController.text = _(property.name);
					optionCellController.values = [copyOfLabelsAndValues allValues];
					NSMutableArray* localizedLabels = [NSMutableArray array];
					for(NSString* str in [copyOfLabelsAndValues allKeys]){
						[localizedLabels addObject:_(str)];
					}
					optionCellController.labels = localizedLabels;
					[optionCellController bind:@"currentValue" withBlock:^(id value){
						if(value == nil || [value isKindOfClass:[NSNull class]]){
							[property setValue:[NSNumber numberWithInt:0]];
							descriptor.value = [NSNumber numberWithInt:0];
						}
						else{
							[property setValue:value];
							if(optionCellController.multiSelectionEnabled){
                                optionCellController.value = [property value];
                            }
                            else{
                                NSInteger index = [[copyOfLabelsAndValues allValues]indexOfObject:[property value]];
                                optionCellController.value = [NSNumber numberWithInt:index];
                            }
						}
                        [[NSNotificationCenter defaultCenter]notifyPropertyChange:property];
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

@end

@implementation CKFormTableViewController(CKPropertyGrid)

- (CKFormSectionBase*)addSectionWithObject:(id)object headerTitle:(NSString*)title{
    return [self addSectionWithObject:object propertyFilter:nil headerTitle:title hidden:NO];
}

- (CKFormSectionBase*)addSectionWithObject:(id)object headerTitle:(NSString*)title hidden:(BOOL)hidden{
    return [self addSectionWithObject:object propertyFilter:nil headerTitle:title hidden:hidden];
}

- (CKFormSectionBase*)addSectionWithObject:(id)object propertyFilter:(NSString*)filter headerTitle:(NSString*)title{
    return [self addSectionWithObject:object propertyFilter:filter headerTitle:title hidden:NO];
}

- (CKFormSectionBase*)addSectionWithObject:(id)object propertyFilter:(NSString*)filter headerTitle:(NSString*)title hidden:(BOOL)hidden{
    return [self addSectionWithObject:object properties:[self propertyNamesForObject:object withFilter:filter] headerTitle:title hidden:hidden];
}

- (CKFormSectionBase*)addSectionWithObject:(id)object properties:(NSArray*)properties headerTitle:(NSString*)title{
    return [self addSectionWithObject:object properties:properties headerTitle:title hidden:NO];
}

- (CKFormSectionBase*)addSectionWithObject:(id)object properties:(NSArray*)properties headerTitle:(NSString*)title hidden:(BOOL)hidden{
    NSMutableArray* theProperties = [NSMutableArray array];
    for(NSString* propertyName in properties){
        CKObjectProperty* property = [CKObjectProperty propertyWithObject:object keyPath:propertyName];
        [theProperties addObject:property];
    }
    
    //TODO footerName
    CKFormSection* section = (title != nil && [title length] > 0) ? [CKFormSection sectionWithHeaderTitle:_(title)] : [CKFormSection section];
    section.hidden = hidden;
    [self setup:theProperties inSection:section];
    [self addSection:section];
    
    return section;
}

@end
