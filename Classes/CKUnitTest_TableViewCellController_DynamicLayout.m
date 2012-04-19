//
//  CKUnitTest_TableViewCellController_DynamicLayout.m
//  CloudKit
//
//  Created by Sebastien Morel on 12-04-19.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKUnitTest_TableViewCellController_DynamicLayout.h"
#import "CKFormTableViewController.h"
#import "CKObject.h"
#import "CKNSObject+CKSingleton.h"

@interface CKUnitTest_TableViewCellController_DynamicLayout_Object : CKObject
@property (nonatomic,retain) NSString* string;
@property (nonatomic,retain) NSString* multiline;
@property (nonatomic,assign) NSInteger integer;
@property (nonatomic,assign) CGFloat cgfloat;
@property (nonatomic,assign) BOOL boolean;
@end

@implementation CKUnitTest_TableViewCellController_DynamicLayout_Object
@synthesize string,integer,cgfloat,boolean,multiline;

- (void)multilineExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.multiLineEnabled = YES;
}

@end

@implementation CKUnitTest_TableViewCellController_DynamicLayout

+ (CKEnumDescriptor*)cellStylesEnumDescriptor{
    CKTableViewCellController* controller = [CKTableViewCellController sharedInstance];
    CKProperty* cellStyleProperty = [CKProperty propertyWithObject:controller keyPath:@"cellStyle"];
    return [[cellStyleProperty extendedAttributes]enumDescriptor];
}

+ (CKUIViewController*)viewController{
    CKFormTableViewController* form = [CKFormTableViewController controller];
    
    CKFormSection* section = [CKFormSection section];
    
    CKEnumDescriptor* cellStylesEnumDescriptor = [CKUnitTest_TableViewCellController_DynamicLayout cellStylesEnumDescriptor];
    
    for(int i =1; i <= 5; ++i){
        for(NSString* cellStyleName in [[cellStylesEnumDescriptor valuesAndLabels]allKeys]){
            CKTableViewCellController* cellController = [CKTableViewCellController cellController];
            cellController.text = cellStyleName;
            
            NSMutableString* detail = [NSMutableString string];
            for(int j=0; j < i; ++j){
                [detail appendString:@"ab cabca bcdefg hijk defghijkde abcdef ghijkf ghijk "];
            }
            cellController.detailText = detail;
            
            CKTableViewCellStyle style = [[[cellStylesEnumDescriptor valuesAndLabels]objectForKey:cellStyleName]intValue];
            cellController.cellStyle = style;
            cellController.componentsRatio = 0.5;
            
            [section addCellController:cellController];
        }
    }
    
    /*CKUnitTest_TableViewCellController_DynamicLayout_Object *object = [CKUnitTest_TableViewCellController_DynamicLayout_Object object];
    for(CKClassPropertyDescriptor* descriptor in [object allPropertyDescriptors]){
        CKProperty* property = [CKProperty propertyWithObject:object keyPath:descriptor.name];
        
        for(NSNumber* cellStyleNumber in cellStyles){
            
            CKTableViewCellController* controller = [CKTableViewCellController cellControllerWithProperty:property];
            if(controller){//as some properties can be not editable.
                CKTableViewCellController* readOnlyController = [CKTableViewCellController cellControllerWithProperty:property readOnly:YES];
                
                CKTableViewCellStyle style = [cellStyleNumber intValue];
                controller.cellStyle = readOnlyController.cellStyle = style;
                
                [section addCellController:controller];
                [section addCellController:readOnlyController];
            }
        }
    }*/
    
    [form addSections:[NSArray arrayWithObject:section]];
    
    form.viewDidAppearBlock = ^(CKUIViewController* controller, BOOL animated){
        
    };
    
    form.viewWillDisappearBlock = ^(CKUIViewController* controller, BOOL animated){
        
    };
    
    return form;
}

@end
