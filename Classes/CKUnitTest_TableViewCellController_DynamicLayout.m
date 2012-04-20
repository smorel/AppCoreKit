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
//@property (nonatomic,retain) NSString* multiline;
//@property (nonatomic,retain) NSString* string;
@property (nonatomic,assign) NSInteger integer;
@property (nonatomic,assign) CGFloat cgfloat;
//@property (nonatomic,assign) BOOL boolean;
@end

@implementation CKUnitTest_TableViewCellController_DynamicLayout_Object
//@synthesize multiline;
//@synthesize string;
@synthesize integer;
@synthesize cgfloat;
//@synthesize boolean;

- (void)multilineExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.multiLineEnabled = YES;
}

@end

//THIS SHOULD BE REMOVED WHEN NSSTRING CELL WORKS
@interface CKObject(CKUnitTest)
@end

@implementation CKObject(CKUnitTest)

- (void)objectNameExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
	attributes.editable = NO;
}

@end


@implementation CKUnitTest_TableViewCellController_DynamicLayout

+ (CKEnumDescriptor*)cellStylesEnumDescriptor{
    CKTableViewCellController* controller = [CKTableViewCellController sharedInstance];
    CKProperty* cellStyleProperty = [CKProperty propertyWithObject:controller keyPath:@"cellStyle"];
    return [[cellStyleProperty extendedAttributes]enumDescriptor];
}

+ (CKUIViewController*)viewControllerToTestBasicCellControllers{
    CKFormTableViewController* form = [CKFormTableViewController controller];
    
    CKFormSection* section = [CKFormSection section];
    CKEnumDescriptor* cellStylesEnumDescriptor = [CKUnitTest_TableViewCellController_DynamicLayout cellStylesEnumDescriptor];
    for(int i =0; i <= 5; ++i){
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
            cellController.componentsSpace = 30;
            cellController.contentInsets = UIEdgeInsetsMake(5, 5, 40, 30);
            
            [section addCellController:cellController];
        }
    }
    [form addSections:[NSArray arrayWithObject:section]];

    return form;
}


+ (CKUIViewController*)viewControllerToTestPropertyCellControllers{
    CKFormTableViewController* form = [CKFormTableViewController controller];
    
    CKFormSection* section = [CKFormSection section];
    
    CKEnumDescriptor* cellStylesEnumDescriptor = [CKUnitTest_TableViewCellController_DynamicLayout cellStylesEnumDescriptor];

    CKUnitTest_TableViewCellController_DynamicLayout_Object *object = [[CKUnitTest_TableViewCellController_DynamicLayout_Object object]retain];//if not it will get killed !
    for(CKClassPropertyDescriptor* descriptor in [object allPropertyDescriptors]){
        CKProperty* property = [CKProperty propertyWithObject:object keyPath:descriptor.name];
        
        for(NSString* cellStyleName in [[cellStylesEnumDescriptor valuesAndLabels]allKeys]){
            CKTableViewCellStyle style = [[[cellStylesEnumDescriptor valuesAndLabels]objectForKey:cellStyleName]intValue];
            //DEBUG 1 by 1
            if(style == CKTableViewCellStyleSubtitle2
               || style == CKTableViewCellStyleValue3
               || style == CKTableViewCellStylePropertyGrid){
                CKTableViewCellController* controller = [CKTableViewCellController cellControllerWithProperty:property];
                if(controller){//as some properties can be not editable.
                    CKTableViewCellController* readOnlyController = [CKTableViewCellController cellControllerWithProperty:property readOnly:YES];
                    
                    controller.cellStyle = readOnlyController.cellStyle = style;
                    controller.componentsRatio = 0.5;
                    readOnlyController.componentsRatio = 0.5;
                    
                    [section addCellController:controller];
                    [section addCellController:readOnlyController];
                }
            }
        }
    }
    
    [form addSections:[NSArray arrayWithObject:section]];
    
    return form;
}

@end
