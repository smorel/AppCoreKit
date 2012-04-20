//
//  CKNSObject+InlineDebugger.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-10-17.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import "CKNSObject+InlineDebugger.h"
#import "CKTableViewCellController+CKBlockBasedInterface.h"
#import "CKUIView+Style.h"
#import "CKCascadingTree.h"
#import "CKLocalization.h"
#import "CKArrayProxyCollection.h"

#import "CKNSObject+Invocation.h"

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

+ (CKTableViewCellController*)cellControllerForStylesheetInObject:(id)object{
    NSMutableDictionary* styleSheet = [object appliedStyle];
    if(styleSheet){
        NSString* title = [[[object appliedStylePath]componentsSeparatedByString:@"/"]componentsJoinedByString:@"\n"];
        CKTableViewCellController* cellController = [CKTableViewCellController cellControllerWithTitle:title action:^(CKTableViewCellController* controller){
            CKFormTableViewController* debugger = [[object class]inlineDebuggerForStylesheet:styleSheet withObject:object]; 
            [controller.containerController.navigationController pushViewController:debugger animated:YES];
        }];
        cellController.name = @"StyleSheetCell";
        return cellController;
    }
    
    return nil;
}

+ (CKItemViewControllerFactoryItem*)factoryItemForClass{
    return [CKItemViewControllerFactoryItem itemForObjectWithPredicate:[NSPredicate predicateWithValue:YES] withControllerCreationBlock:^CKItemViewController *(id object, NSIndexPath *indexPath) {
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
    
    CKItemViewControllerFactory* factory = [CKItemViewControllerFactory factory];
    [factory addItem:[NSObject factoryItemForClass]];
    
    NSArray* inheritingClasses = [[NSObject superClassesForClass:[object class]]retain];//release in the debugger dealloc block.
    CKFormBindedCollectionSection* inheritingClassesSection = [CKFormBindedCollectionSection sectionWithCollection:[CKArrayProxyCollection collectionWithArrayProperty:[CKProperty propertyWithObject:inheritingClasses]] 
                                                                                                               factory:factory 
                                                                                                           headerTitle:@"Super Classes"];
    
    
    
    CKFormSection* objectSection = [CKFormSection sectionWithObject:object propertyFilter:nil headerTitle:[[object class]description]];
    
    if([object appliedStyle]){
        CKFormSection* styleSection = [CKFormSection sectionWithCellControllers:
                                       [NSArray arrayWithObject:[[object class]cellControllerForStylesheetInObject:object]] headerTitle:@"StyleSheet"];
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
