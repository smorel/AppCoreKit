//
//  CKFormTableViewController+Options.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-12.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKFormTableViewController+Options.h"
#import "CKOptionCellController.h"
#import "CKNSObject+Bindings.h"
#import "CKLocalization.h"
#import "CKNSNotificationCenter+Edition.h"


@implementation CKFormCellDescriptor (CKOptions)

+ (CKFormCellDescriptor*)cellDescriptorWithObject:(id)object keyPath:(NSString*)keyPath enumDescriptor:(CKEnumDescriptor*)enumDescriptor multiSelectionEnabled:(BOOL)multiSelectionEnabled{
    return [CKFormCellDescriptor cellDescriptorWithObject:object keyPath:keyPath enumDescriptor:enumDescriptor multiSelectionEnabled:multiSelectionEnabled readOnly:NO];
}

+ (CKFormCellDescriptor*)cellDescriptorWithObject:(id)object keyPath:(NSString*)keyPath valuesAndLabels:(NSDictionary*)valuesAndLabels{
    return [CKFormCellDescriptor cellDescriptorWithObject:object keyPath:keyPath valuesAndLabels:valuesAndLabels readOnly:NO];
    
}

+ (CKFormCellDescriptor*)cellDescriptorWithObject:(id)object keyPath:(NSString*)keyPath enumDescriptor:(CKEnumDescriptor*)enumDescriptor multiSelectionEnabled:(BOOL)multiSelectionEnabled readOnly:(BOOL)readOnly{
    return [CKFormCellDescriptor cellDescriptorWithProperty:[CKObjectProperty propertyWithObject:object keyPath:keyPath] enumDescriptor:enumDescriptor multiSelectionEnabled:multiSelectionEnabled readOnly:readOnly];
    
}

+ (CKFormCellDescriptor*)cellDescriptorWithObject:(id)object keyPath:(NSString*)keyPath valuesAndLabels:(NSDictionary*)valuesAndLabels readOnly:(BOOL)readOnly{
    return [CKFormCellDescriptor cellDescriptorWithProperty:[CKObjectProperty propertyWithObject:object keyPath:keyPath] valuesAndLabels:valuesAndLabels readOnly:readOnly];
}


+ (CKFormCellDescriptor*)cellDescriptorWithProperty:(CKObjectProperty*)property enumDescriptor:(CKEnumDescriptor*)enumDescriptor multiSelectionEnabled:(BOOL)multiSelectionEnabled{
    return [CKFormCellDescriptor cellDescriptorWithProperty:property enumDescriptor:enumDescriptor multiSelectionEnabled:multiSelectionEnabled readOnly:NO];
    
}

+ (CKFormCellDescriptor*)cellDescriptorWithProperty:(CKObjectProperty*)property valuesAndLabels:(NSDictionary*)valuesAndLabels{
    return [CKFormCellDescriptor cellDescriptorWithProperty:property valuesAndLabels:valuesAndLabels readOnly:NO];
    
}

+ (CKFormCellDescriptor*)cellDescriptorWithProperty:(CKObjectProperty*)theproperty enumDescriptor:(CKEnumDescriptor*)enumDescriptor multiSelectionEnabled:(BOOL)multiSelectionEnabled readOnly:(BOOL)readOnly{
    CKFormCellDescriptor* cellDescriptor = [CKFormCellDescriptor cellDescriptorWithValue:[theproperty value] controllerClass:[CKOptionCellController class]];
    [cellDescriptor setSetupBlock:^(id controller){
        CKOptionCellController* optionCellController = (CKOptionCellController*)controller;
        //init optionCellController
        NSMutableArray* localizedLabels = [NSMutableArray array];
        for(NSString* str in [enumDescriptor.valuesAndLabels allKeys]){
            [localizedLabels addObject:_(str)];
        }
        optionCellController.labels = localizedLabels;
        optionCellController.values = [enumDescriptor.valuesAndLabels allValues];
        
        CKObjectProperty* property = theproperty;
        [optionCellController beginBindingsContextByRemovingPreviousBindings];
        optionCellController.multiSelectionEnabled = multiSelectionEnabled;
        if(optionCellController.multiSelectionEnabled){
            optionCellController.value = [property value];
        }
        else{
            NSInteger index = [optionCellController.values indexOfObject:[property value]];
            optionCellController.value = [NSNumber numberWithInt:index];
        }
        optionCellController.text = _(property.name);
        [optionCellController bind:@"currentValue" withBlock:^(id value){
            if(value == nil || [value isKindOfClass:[NSNull class]]){
                [property setValue:[NSNumber numberWithInt:0]];
                cellDescriptor.value = [NSNumber numberWithInt:0];
            }
            else{
                [property setValue:value];
                if(optionCellController.multiSelectionEnabled){
                    optionCellController.value = [property value];
                }
                else{
                    NSInteger index = [optionCellController.values indexOfObject:[property value]];
                    optionCellController.value = [NSNumber numberWithInt:index];
                }
            }
            [[NSNotificationCenter defaultCenter]notifyPropertyChange:property];
        }];
        [optionCellController endBindingsContext];
        
        return (id)nil;
    }];
    return cellDescriptor;
}

+ (CKFormCellDescriptor*)cellDescriptorWithProperty:(CKObjectProperty*)theproperty valuesAndLabels:(NSDictionary*)valuesAndLabels readOnly:(BOOL)readOnly{
    
    CKFormCellDescriptor* cellDescriptor = [CKFormCellDescriptor cellDescriptorWithValue:theproperty controllerClass:[CKOptionCellController class]];
    [cellDescriptor setSetupBlock:^(id controller){
        CKOptionCellController* optionCellController = (CKOptionCellController*)controller;
        //init optionCellController
        optionCellController.values = [valuesAndLabels allValues];
        optionCellController.labels = [valuesAndLabels allKeys];
        
        CKObjectProperty* property = (CKObjectProperty*)optionCellController.value;
        
        NSInteger index = [optionCellController.values indexOfObject:[theproperty value]];
        optionCellController.value = [NSNumber numberWithInt:index];
        
        [optionCellController beginBindingsContextByRemovingPreviousBindings];
        optionCellController.value = [NSNumber numberWithInt:index];
        optionCellController.text = _(property.name);
        [optionCellController bind:@"currentValue" withBlock:^(id value){
            [property setValue:value];
            [[NSNotificationCenter defaultCenter]notifyPropertyChange:property];
            /*
            NSInteger index = [optionCellController.values indexOfObject:[property value]];
            cellDescriptor.value = [NSNumber numberWithInt:index];
             */
        }];
        [optionCellController endBindingsContext];
        return (id)nil;
    }];
    return cellDescriptor;
}


@end
