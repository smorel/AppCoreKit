//
//  CKNSObject+InlineDebugger.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-10-17.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import "CKNSObject+InlineDebugger.h"

@implementation NSObject (CKInlineDebugger)

+ (CKFormTableViewController*)inlineDebuggerForObject:(id)object{
    CKFormTableViewController* debugger = [[[CKFormTableViewController alloc]init]autorelease];
    debugger.searchEnabled = YES;
    
    CKFormSection* objectSection = [CKFormSection sectionWithObject:object propertyFilter:nil headerTitle:[[object class]description]];
    [debugger addSections:[NSArray arrayWithObject:objectSection]];
    
    //Setup filter callback
    __block CKFormTableViewController* bController = debugger;
    debugger.searchBlock = ^(NSString* filter){
        NSInteger index = [bController indexOfSection:objectSection];
        [bController removeSectionAtIndex:index];
        
        CKFormSection* newObjectSection = [CKFormSection sectionWithObject:object propertyFilter:filter headerTitle:[[object class]description]];
        [bController insertSection:newObjectSection atIndex:index];
    };
        
    return debugger;
}

@end
