//
//  CKTableViewCellController+Factory.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKTableViewCellController+Factory.h"
#import "UIView+Name.h"
#import "NSObject+Bindings.h"
#import "CKDebug.h"

@implementation CKTableViewCellController (Factory)

+ (CKTableViewCellController*)cellControllerWithName:(NSString*)name{
    return [CKTableViewCellController cellControllerWithName:name action:nil];
}

+ (CKTableViewCellController*)cellControllerWithName:(NSString*)name 
                                              action:(void(^)(CKTableViewCellController* controller))action{
    return [CKTableViewCellController cellControllerWithName:name value:nil bindings:nil action:action];
}

+ (CKTableViewCellController*)cellControllerWithName:(NSString*)name 
                                               value:(id)value
                                            bindings:(NSDictionary*)bindings{
    return [CKTableViewCellController cellControllerWithName:name value:value bindings:bindings action:nil];
}

+ (CKTableViewCellController*)cellControllerWithName:(NSString*)name 
                                               value:(id)value
                                            bindings:(NSDictionary*)bindings 
                                              action:(void(^)(CKTableViewCellController* controller))action{
    return [CKTableViewCellController cellControllerWithName:name value:value bindings:bindings controlActions:nil action:action];
}

+ (CKTableViewCellController*)cellControllerWithName:(NSString*)name 
                                               value:(id)value
                                            bindings:(NSDictionary*)bindings 
                                      controlActions:(NSDictionary*)controlActions{
    return [CKTableViewCellController cellControllerWithName:name value:value bindings:bindings controlActions:controlActions action:nil];
}

+ (CKTableViewCellController*)cellControllerWithName:(NSString*)name 
                                               value:(id)value
                                            bindings:(NSDictionary*)bindings 
                                      controlActions:(NSDictionary*)controlActions 
                                              action:(void(^)(CKTableViewCellController* controller))action{
    
    CKTableViewCellController* controller = [CKTableViewCellController cellController];
    controller.name = name;
    controller.value = value;
    
    if(value && (bindings || controlActions)){
        [controller setSetupBlock:^(CKTableViewCellController *controller, UITableViewCell *cell) {
            [cell beginBindingsContextByRemovingPreviousBindings];
            
            for(NSString* viewPropertyKeyPath in [bindings allKeys]){
                //Resolve view path and property path
                NSArray* viewPropertyKeyPathComponents = [viewPropertyKeyPath componentsSeparatedByString:@"."];
                
                UIView* view = cell;
                NSInteger i = 0;
                for(NSString* viewKeyPath in viewPropertyKeyPathComponents){
                    UIView* newView = [view viewWithKeyPath:viewKeyPath];
                    if(newView){
                        view = newView;
                        ++i;
                    }else{
                        break;
                    }
                }
                
                NSMutableString* propertyKeyPath = [NSMutableString string];
                for(int j= i; j < [viewPropertyKeyPathComponents count]; ++j){
                    if(j > i){
                        [propertyKeyPath appendString:@"."];
                    }
                    [propertyKeyPath appendString:[viewPropertyKeyPathComponents objectAtIndex:j]];
                }
                
                //bind
                NSString* valueKeyPath = [bindings objectForKey:viewPropertyKeyPath];
                [controller.value bind:valueKeyPath toObject:view withKeyPath:propertyKeyPath];
            }
            
            for(NSString* controlKeyPath in [controlActions allKeys]){
                UIView* control = [cell viewWithKeyPath:controlKeyPath];
                if(control){
                    CKAssert([control isKindOfClass:[UIControl class]],@"ControlKeyPath '%@' points to a non UIControl view",controlKeyPath);
                    void(^actionBlock)(UIControl* control, CKTableViewCellController* controller) = [[controlActions objectForKey:controlKeyPath]copy];
                    
                    __block CKTableViewCellController* bController = controller;
                    __block UIControl* bControl = (UIControl*)control;
                    [(UIControl*)control bindEvent:UIControlEventTouchUpInside withBlock:^{
                        actionBlock(bControl,bController);
                    }];
                }
            }
            
            [cell endBindingsContext];
        }];
    }
    
    if(action){
        controller.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [controller setSelectionBlock:action];
        controller.flags = CKItemViewFlagSelectable;
    }
    return controller;
    
}

@end
