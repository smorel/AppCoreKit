//
//  NSObject+InlineDebugger.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import "NSObject+InlineDebugger.h"
#import "UIView+Style.h"
#import "CKCascadingTree.h"
#import "CKLocalization.h"
#import "CKArrayProxyCollection.h"
#import "CKConfiguration.h"

#import "NSObject+Invocation.h"
#import "CKReusableViewController+Property.h"
#import "CKSection+Property.h"

@implementation NSObject (CKInlineDebugger)

+ (CKSection*)sectionWithDictionary:(NSMutableDictionary*)dico keys:(NSArray*)keys title:(NSString*)title{
    NSMutableArray* controllers = [NSMutableArray array];
    for(id key in keys){
        CKProperty* property = [[[CKProperty alloc]initWithDictionary:dico key:key]autorelease];
        CKReusableViewController* controller = [CKReusableViewController controllerWithProperty:property];
        [controllers addObject:controller];
    }
    CKSection* section = [CKSection sectionWithControllers:controllers];
    [section setHeaderTitle:title];
    return section;
}

+ (CKTableViewController*)inlineDebuggerForStylesheet:(NSMutableDictionary*)stylesheet withObject:(id)object{
    if([stylesheet isEmpty]){
        CKTableViewController* debugger = [[[CKTableViewController alloc]init]autorelease];
        debugger.title = @"Applied Style";
        debugger.name = @"CKInlineDebugger";
        debugger.viewDidLoadBlock = ^(UIViewController* controller){
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
        
        
        CKTableViewController* debugger = [[[CKTableViewController alloc]init]autorelease];
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
        
        [debugger addSections:sections animated:NO];
        
        return debugger;
    }
    
    return nil;
}

+ (CKReusableViewController*)cellControllerForStylesheetInObject:(id)object{
    NSMutableDictionary* styleSheet = nil;
    styleSheet = [object appliedStyle];

    if(styleSheet){
        NSString* title = [[[object appliedStylePath]componentsSeparatedByString:@"/"]componentsJoinedByString:@"\n"];
        CKStandardContentViewController* controller = [CKStandardContentViewController controllerWithTitle:nil subtitle:title action:^(CKStandardContentViewController* controller){
            CKTableViewController* debugger = [[object class]inlineDebuggerForStylesheet:styleSheet withObject:object];
            [controller.navigationController pushViewController:debugger animated:YES];
        }];
        controller.name = @"StyleSheetCell";
        return controller;
    }
    
    return nil;
}


+ (CKTableViewController*)inlineDebuggerForObject:(id)object{
    CKTableViewController* debugger = [[[CKTableViewController alloc]init]autorelease];
    debugger.name = @"CKInlineDebugger";
    //  debugger.searchEnabled = YES;
    
    //IDENTIFICATION SECTION
    CKSection* sectionIdentification = [CKSection sectionWithObject:object properties:[NSArray arrayWithObjects:@"name",@"tag",nil] headerTitle:@"Identification"];
    [sectionIdentification insertController:[CKStandardContentViewController controllerWithTitle:@"class" subtitle:[[object class]description] action:nil] atIndex:0 animated:NO];
    
    //SECTION FOR STYLESHEET
    NSMutableDictionary* styleSheet = nil;
    styleSheet = [object appliedStyle];
    
    CKSection* styleSection = styleSheet ? [CKSection sectionWithControllers: @[[[object class]cellControllerForStylesheetInObject:object]] ] : nil;
    [styleSection setHeaderTitle:@"StyleSheet"];
    
    //SECTION FOR CLASS HIERARCHY
    CKReusableViewControllerFactory* factory = [CKReusableViewControllerFactory factory];
    [factory registerFactoryWithPredicate:[NSPredicate predicateWithValue:YES] factory:^CKReusableViewController *(id object, NSIndexPath *indexPath) {
        return [CKStandardContentViewController controllerWithTitle:[object description] action:nil];
    }];
    
    NSArray* inheritingClasses = [[NSObject superClassesForClass:[object class]]retain];//release in the debugger dealloc block.
    CKCollectionSection* inheritingClassesSection = [CKCollectionSection sectionWithCollection:[CKArrayProxyCollection collectionWithArrayProperty:[CKProperty propertyWithObject:inheritingClasses]]
                                                                                                           factory:factory ];
    inheritingClassesSection.name = @"ClassHierarchy";
    [inheritingClassesSection setHeaderTitle:@"Class Hierarchy"];
    
    
    //PROPERTIES SECTION
    CKSection* objectSection = [CKSection sectionWithObject:object propertyFilter:nil headerTitle:@"Properties"];
    
    if(styleSection){
        [debugger addSections:[NSArray arrayWithObjects:sectionIdentification,styleSection,inheritingClassesSection,objectSection,nil] animated:NO];
    }
    else{
        [debugger addSections:[NSArray arrayWithObjects:sectionIdentification,inheritingClassesSection,objectSection,nil] animated:NO];
    }
    
    //Setup filter callback
    __block CKTableViewController* bController = debugger;
    __block CKSection* propertiesSection = [objectSection retain];
   /* debugger.searchBlock = ^(NSString* filter){
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
    };*/
    
    debugger.deallocBlock = ^(UIViewController* controller){
        [propertiesSection release];
        [inheritingClasses release];
    };
        
    return debugger;
}

@end
