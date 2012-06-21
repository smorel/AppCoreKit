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
@property (nonatomic,retain) NSString* multiline;
@property (nonatomic,retain) NSString* string;
@property (nonatomic,assign) NSInteger integer;
@property (nonatomic,assign) CGFloat cgfloatwiwjehriwuheriuweir;
@property (nonatomic,assign) BOOL booleanwerkhwvebqrrkbqkjwerbkjqwjbkerj;
@property (nonatomic,assign) BOOL bo;
@property (nonatomic,retain) CKObject* object;
@end

@implementation CKUnitTest_TableViewCellController_DynamicLayout_Object
@synthesize multiline;
@synthesize string;
@synthesize integer;
@synthesize cgfloatwiwjehriwuheriuweir;
@synthesize booleanwerkhwvebqrrkbqkjwerbkjqwjbkerj;
@synthesize bo;
@synthesize object;

- (void)postInit{
    [super postInit];
    self.object = [CKObject object];
}

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
            cellController.accessoryType = UITableViewCellAccessoryCheckmark;
            
            [section addCellController:cellController];
        }
    }
    [form addSections:[NSArray arrayWithObject:section]];
    
    return form;
}


+ (CKUIViewController*)viewControllerToTestPropertyCellControllers{
    CKFormTableViewController* form = [CKFormTableViewController controller];
    form.editableType = CKTableCollectionViewControllerEditingTypeRight;
    
    CKFormSection* section = [CKFormSection section];
    
    CKEnumDescriptor* cellStylesEnumDescriptor = [CKUnitTest_TableViewCellController_DynamicLayout cellStylesEnumDescriptor];
    
    CKUnitTest_TableViewCellController_DynamicLayout_Object *object = [[CKUnitTest_TableViewCellController_DynamicLayout_Object object]retain];//if not it will get killed !
    
    //Editable cells
    for(NSString* cellStyleName in [[cellStylesEnumDescriptor valuesAndLabels]allKeys]){
        CKTableViewCellStyle style = [[[cellStylesEnumDescriptor valuesAndLabels]objectForKey:cellStyleName]intValue];
        if(style == CKTableViewCellStyleIPadForm
           || style == CKTableViewCellStyleIPhoneForm
           || style == CKTableViewCellStyleSubtitle2){
            
            for(CKClassPropertyDescriptor* descriptor in [object allPropertyDescriptors]){
                CKProperty* property = [CKProperty propertyWithObject:object keyPath:descriptor.name];
                
                CKTableViewCellController* controller = [CKTableViewCellController cellControllerWithProperty:property];
                if(controller){//as some properties can be not editable.
                    controller.cellStyle = style;
                    controller.componentsRatio = 0.5;
                    controller.flags = CKItemViewFlagRemovable;
                    [section addCellController:controller];
                }
            }
        }
    }
    
    //Readonly cellds
    for(NSString* cellStyleName in [[cellStylesEnumDescriptor valuesAndLabels]allKeys]){
        CKTableViewCellStyle style = [[[cellStylesEnumDescriptor valuesAndLabels]objectForKey:cellStyleName]intValue];
        if(style == CKTableViewCellStyleIPadForm
           || style == CKTableViewCellStyleIPhoneForm
           || style == CKTableViewCellStyleSubtitle2){
            
            for(CKClassPropertyDescriptor* descriptor in [object allPropertyDescriptors]){
                CKProperty* property = [CKProperty propertyWithObject:object keyPath:descriptor.name];
                
                CKTableViewCellController* controller = [CKTableViewCellController cellControllerWithProperty:property readOnly:YES];
                if(controller){//as some properties can be not editable.
                    controller.cellStyle = style;
                    controller.componentsRatio = 0.5;
                    [section addCellController:controller];
                }
            }
        }
    }
    
    [form addSections:[NSArray arrayWithObject:section]];
    [object release];
    
    return form;
}

@end
