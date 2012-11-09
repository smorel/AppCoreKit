//
//  NSObject+InlineDebugger.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import "NSObject+InlineDebugger.h"
#import "CKTableViewCellController+BlockBasedInterface.h"
#import "UIView+Style.h"
#import "CKCascadingTree.h"
#import "CKLocalization.h"
#import "CKArrayProxyCollection.h"
#import "CKConfiguration.h"

#import "NSObject+Invocation.h"

@implementation NSObject (CKInlineDebugger)

+ (CKFormSection*)sectionWithDictionary:(NSMutableDictionary*)dico keys:(NSArray*)keys title:(NSString*)title{
    NSMutableArray* cellControllers = [NSMutableArray array];
    for(id key in keys){
        CKProperty* property = [[[CKProperty alloc]initWithDictionary:dico key:key]autorelease];
        CKTableViewCellController* cellController = [CKTableViewCellController cellControllerWithProperty:property];
        [cellControllers addObject:cellController];
    }
    return [CKFormSection sectionWithCellControllers:cellControllers headerTitle:title];
}

+ (CKFormTableViewController*)inlineDebuggerForStylesheet:(NSMutableDictionary*)stylesheet withObject:(id)object{
    if([stylesheet isEmpty]){
        CKFormTableViewController* debugger = [[[CKFormTableViewController alloc]initWithStyle:UITableViewStylePlain]autorelease];
        debugger.title = @"Applied Style";
        debugger.name = @"CKInlineDebugger";
        debugger.viewDidLoadBlock = ^(CKViewController* controller){
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

+ (CKTableViewCellController*)cellControllerForStylesheetInObject:(id)object{
    NSMutableDictionary* styleSheet = nil;
    if([[CKConfiguration sharedInstance]resourcesLiveUpdateEnabled]){
        styleSheet = [object debugAppliedStyle];
    }
    else{
        styleSheet = [object appliedStyle];
    }
    if(styleSheet){
        NSString* title = [[[object appliedStylePath]componentsSeparatedByString:@"/"]componentsJoinedByString:@"\n"];
        CKTableViewCellController* cellController = [CKTableViewCellController cellControllerWithTitle:nil subtitle:title action:^(CKTableViewCellController* controller){
            CKFormTableViewController* debugger = [[object class]inlineDebuggerForStylesheet:styleSheet withObject:object]; 
            [controller.containerController.navigationController pushViewController:debugger animated:YES];
        }];
        cellController.name = @"StyleSheetCell";
        return cellController;
    }
    
    return nil;
}

+ (CKCollectionCellControllerFactoryItem*)factoryItemForClass{
    return [CKCollectionCellControllerFactoryItem itemForObjectWithPredicate:[NSPredicate predicateWithValue:YES] withControllerCreationBlock:^CKCollectionCellController *(id object, NSIndexPath *indexPath) {
        CKTableViewCellController* controller = [CKTableViewCellController cellController];
        controller.selectionStyle = UITableViewCellSelectionStyleNone;
        controller.text = [object description];
        return controller;
    }];
}

+ (CKFormTableViewController*)inlineDebuggerForObject:(id)object{
    CKFormTableViewController* debugger = [[[CKFormTableViewController alloc]initWithStyle:UITableViewStylePlain]autorelease];
    debugger.name = @"CKInlineDebugger";
    debugger.searchEnabled = YES;
    
    //IDENTIFICATION SECTION
    CKFormSection* sectionIdentification = [CKFormSection sectionWithObject:object properties:[NSArray arrayWithObjects:@"name",@"tag",nil] headerTitle:@"Identification"];
    [sectionIdentification insertCellController:[CKTableViewCellController cellControllerWithTitle:@"class" subtitle:[[object class]description] action:nil] atIndex:0];
    
    //SECTION FOR STYLESHEET
    NSMutableDictionary* styleSheet = nil;
    if([[CKConfiguration sharedInstance]resourcesLiveUpdateEnabled]){
        styleSheet = [object debugAppliedStyle];
    }
    else{
        styleSheet = [object appliedStyle];
    }
    CKFormSection* styleSection = styleSheet ? [CKFormSection sectionWithCellControllers:
                                                           [NSArray arrayWithObject:[[object class]cellControllerForStylesheetInObject:object]] headerTitle:@"StyleSheet"] : nil;
    
    //SECTION FOR CLASS HIERARCHY
    CKCollectionCellControllerFactory* factory = [CKCollectionCellControllerFactory factory];
    [factory addItem:[NSObject factoryItemForClass]];
    
    NSArray* inheritingClasses = [[NSObject superClassesForClass:[object class]]retain];//release in the debugger dealloc block.
    CKFormBindedCollectionSection* inheritingClassesSection = [CKFormBindedCollectionSection sectionWithCollection:[CKArrayProxyCollection collectionWithArrayProperty:[CKProperty propertyWithObject:inheritingClasses]] 
                                                                                                           factory:factory 
                                                                                                       headerTitle:@"Class Hierarchy"];
    
    
    //PROPERTIES SECTION
    CKFormSection* objectSection = [CKFormSection sectionWithObject:object propertyFilter:nil headerTitle:@"Properties"];
    
    if(styleSection){
        [debugger addSections:[NSArray arrayWithObjects:sectionIdentification,styleSection,inheritingClassesSection,objectSection,nil]];
    }
    else{
        [debugger addSections:[NSArray arrayWithObjects:sectionIdentification,inheritingClassesSection,objectSection,nil]];
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
            }
            
            [propertiesSection release];
            propertiesSection = [newObjectSection retain];
        }
    };
    
    debugger.deallocBlock = ^(CKViewController* controller){
        [propertiesSection release];
        [inheritingClasses release];
    };
        
    return debugger;
}

@end
