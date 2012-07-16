//
//  CKNSObject+InlineDebugger.m
//  CloudKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import "CKNSObject+InlineDebugger.h"
#import "CKUIView+Style.h"
#import "CKCascadingTree.h"
#import "CKLocalization.h"
#import "CKObjectPropertyArrayCollection.h"

#import "CKNSObject+Invocation.h"

@implementation NSObject (CKInlineDebugger)

+ (CKFormSection*)sectionWithDictionary:(NSMutableDictionary*)dico keys:(NSArray*)keys title:(NSString*)title{
    NSMutableArray* cells = [NSMutableArray array];
    for(id key in keys){
        CKObjectProperty* property = [[[CKObjectProperty alloc]initWithDictionary:dico key:key]autorelease];
        CKFormCellDescriptor* cell = [CKFormCellDescriptor cellDescriptorWithProperty:property];
        [cells addObject:cell];
    }
    return [CKFormSection sectionWithCellDescriptors:cells headerTitle:title];
}

+ (CKFormTableViewController*)inlineDebuggerForStylesheet:(NSMutableDictionary*)stylesheet withObject:(id)object{
    if([stylesheet isEmpty]){
        CKFormTableViewController* debugger = [[[CKFormTableViewController alloc]initWithStyle:UITableViewStylePlain]autorelease];
        debugger.title = @"Applied Style";
        debugger.name = @"CKInlineDebugger";
        debugger.viewDidLoadBlock = ^(CKUIViewController* controller){
            UILabel* label = [[[UILabel alloc]initWithFrame:CGRectInset(controller.view.bounds,10,10)]autorelease];
            label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            label.numberOfLines = 0;
            label.lineBreakMode = UILineBreakModeTailTruncation;
            
            NSArray* components = [[object appliedStylePath]componentsSeparatedByString:@"/"];
            NSMutableString* splittedPath = [NSMutableString string];
            int i =0;
            for(NSString* str in components){
                for(int j =0; j< i; ++j){
                    [splittedPath appendString:@"  "];
                }
                if(i > 0){
                    [splittedPath appendString:@"->"];
                }
                [splittedPath appendFormat:@"%@\n",str];
                ++i;
            }
            label.text = [NSString stringWithFormat:@"The style for this object is empty.\nPlease check in your stylesheet files if you have style defined for the object from path : \n\n %@",splittedPath];
            [controller.view addSubview:label];
        };
        return debugger;
    }
    else{
        NSMutableArray* appliedKeys = [NSMutableArray array];
        NSMutableArray* ignoredKeys = [NSMutableArray array];
        NSMutableArray* templatesKeys = [NSMutableArray array];
        NSMutableArray* subStylesKeys = [NSMutableArray array];
        
        NSMutableSet* keyWords = [NSMutableSet set];
        [[object class]updateReservedKeyWords:keyWords];
        
        NSMutableSet* cascadingTreeKeyWords = [NSMutableSet set];
        [NSObject updateReservedKeyWords:cascadingTreeKeyWords];
        [cascadingTreeKeyWords addObject:@"@class"];
        
        [keyWords minusSet:cascadingTreeKeyWords];
        
        for(id key in [stylesheet allKeys]){
            if(![cascadingTreeKeyWords containsObject:key]){
                CKClassPropertyDescriptor* descriptor = [object propertyDescriptorForKeyPath:key];
                if(descriptor || [keyWords containsObject:key]){
                    [appliedKeys addObject:key];
                }
                else if([key hasPrefix:@"$"]){
                    [templatesKeys addObject:key];
                }
                else if([[stylesheet objectForKey:key]isKindOfClass:[NSDictionary class]]){
                    [subStylesKeys addObject:key];
                }
                else{
                    [ignoredKeys addObject:key];
                }
            }
        }
        
        
        CKFormTableViewController* debugger = [[[CKFormTableViewController alloc]initWithStyle:UITableViewStylePlain]autorelease];
        debugger.title = @"Applied Style";
        debugger.name = @"CKInlineDebugger";
        
        NSMutableArray* sections = [NSMutableArray array];
        if([appliedKeys count] > 0){
            [sections addObject:[NSObject sectionWithDictionary:stylesheet keys:appliedKeys title:_(@"appliedKeys")]];
        }
        if([ignoredKeys count] > 0){
            [sections addObject:[NSObject sectionWithDictionary:stylesheet keys:ignoredKeys title:_(@"ignoredKeys")]];
        }
        if([templatesKeys count] > 0){
            [sections addObject:[NSObject sectionWithDictionary:stylesheet keys:templatesKeys title:_(@"templatesKeys")]];
        }
        if([subStylesKeys count] > 0){
            [sections addObject:[NSObject sectionWithDictionary:stylesheet keys:subStylesKeys title:_(@"subStylesKeys")]];
        }
        
        [debugger addSections:sections];
        
        return debugger;
    }
    
    return nil;
}

+ (CKFormCellDescriptor*)cellDescriptorForStylesheetInObject:(id)object{
    NSMutableDictionary* styleSheet = [object appliedStyle];
    if(styleSheet){
        NSString* title = [[[object appliedStylePath]componentsSeparatedByString:@"/"]componentsJoinedByString:@"\n"];
        CKFormCellDescriptor* controllerCell = [CKFormCellDescriptor cellDescriptorWithTitle:title action:^(CKTableViewCellController* controller){
        }];
        [controllerCell setCreateBlock:^id(id value) {
            CKTableViewCellController* controller = (CKTableViewCellController*)value;
            controller.name = @"StyleSheetCell";
            return (id)nil;
        }];
        [controllerCell setSelectionBlock:^id(id value) {
            CKTableViewCellController* controller = (CKTableViewCellController*)value;
            CKFormTableViewController* debugger = [[object class]inlineDebuggerForStylesheet:styleSheet withObject:object]; 
            [controller.parentController.navigationController pushViewController:debugger animated:YES];
            return (id)nil;
        }];
        return controllerCell;
    }
    
    return nil;
}

+ (CKItemViewControllerFactoryItem*)factoryItemForClass{
    CKItemViewControllerFactoryItem* item = [[[CKItemViewControllerFactoryItem alloc]init]autorelease];
    item.controllerClass = [CKTableViewCellController class];
    [item setFilterBlock:^id(id value) {
        return [NSNumber numberWithBool:YES]; //everything ! 
    }];
    [item setSetupBlock:^id(id value) {
        CKTableViewCellController* controller = (CKTableViewCellController*)value;
        controller.tableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
        controller.tableViewCell.textLabel.text = [controller.value description];
        return (id)nil;
    }];
    return item;
}

+ (CKFormTableViewController*)inlineDebuggerForObject:(id)object{
    CKFormTableViewController* debugger = [[[CKFormTableViewController alloc]initWithStyle:UITableViewStylePlain]autorelease];
    debugger.name = @"CKInlineDebugger";
    debugger.searchEnabled = YES;
    
    CKItemViewControllerFactory* factory = [CKItemViewControllerFactory factory];
    [factory addItem:[NSObject factoryItemForClass]];
    
    NSArray* inheritingClasses = [[NSObject superClassesForClass:[object class]]retain];//release in the debugger dealloc block.
    CKFormDocumentCollectionSection* inheritingClassesSection = [CKFormDocumentCollectionSection sectionWithCollection:[CKObjectPropertyArrayCollection collectionWithArrayProperty:[CKObjectProperty propertyWithObject:inheritingClasses]] 
                                                                                                               factory:factory 
                                                                                                           headerTitle:@"Super Classes"];
    
    
    
    CKFormSection* objectSection = [CKFormSection sectionWithObject:object propertyFilter:nil headerTitle:[[object class]description]];
    
    if([object appliedStyle]){
        CKFormSection* styleSection = [CKFormSection sectionWithCellDescriptors:
                                       [NSArray arrayWithObject:[[object class]cellDescriptorForStylesheetInObject:object]] headerTitle:@"StyleSheet"];
        [debugger addSections:[NSArray arrayWithObjects:styleSection,inheritingClassesSection,objectSection,nil]];
    }
    else{
        [debugger addSections:[NSArray arrayWithObjects:inheritingClassesSection,objectSection,nil]];
    }
    
    //Setup filter callback
    __block CKFormTableViewController* bController = debugger;
    __block CKFormSection* propertiesSection = [objectSection retain];
    debugger.searchBlock = ^(NSString* filter){
        NSInteger index = [bController indexOfSection:propertiesSection];
        if(index != NSNotFound){
            [bController removeSectionAtIndex:index];
            
            CKFormSection* newObjectSection = [CKFormSection sectionWithObject:object propertyFilter:filter headerTitle:[[object class]description]];
            [bController insertSection:newObjectSection atIndex:index];
            
            if([filter length] > 0 && [newObjectSection count] > 0){
                [bController.view endEditing:YES];
                
                [bController.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index] 
                                      atScrollPosition:UITableViewScrollPositionTop
                                              animated:YES];
            }
            
            [propertiesSection release];
            propertiesSection = [newObjectSection retain];
        }
    };
    
    debugger.deallocBlock = ^(CKUIViewController* controller){
        [propertiesSection release];
        [inheritingClasses release];
    };
        
    return debugger;
}

@end
