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

+ (CKTableViewCellController*)cellControllerWithName:(NSString*)name 
                                              action:(void(^)(CKTableViewCellController* controller))action{
    return [[self class] cellControllerWithName:name value:nil bindings:nil action:action];
}

+ (CKTableViewCellController*)cellControllerWithName:(NSString*)name 
                                               value:(id)value
                                            bindings:(NSDictionary*)bindings{
    return [[self class] cellControllerWithName:name value:value bindings:bindings action:nil];
}

+ (CKTableViewCellController*)cellControllerWithName:(NSString*)name 
                                               value:(id)value
                                            bindings:(NSDictionary*)bindings 
                                              action:(void(^)(CKTableViewCellController* controller))action{
    return [[self class] cellControllerWithName:name value:value bindings:bindings controlActions:nil action:action];
}

+ (CKTableViewCellController*)cellControllerWithName:(NSString*)name 
                                               value:(id)value
                                            bindings:(NSDictionary*)bindings 
                                      controlActions:(NSDictionary*)controlActions{
    return [[self class] cellControllerWithName:name value:value bindings:bindings controlActions:controlActions action:nil];
}

+ (CKTableViewCellController*)cellControllerWithName:(NSString*)name 
                                               value:(id)value
                                            bindings:(NSDictionary*)bindings 
                                      controlActions:(NSDictionary*)controlActions 
                                              action:(void(^)(CKTableViewCellController* controller))action{
    return [[self class] cellControllerWithName:name value:value bindings:bindings controlActions:controlActions setup:nil action:action];
}

+ (CKTableViewCellController*)cellControllerWithName:(NSString*)name
                                               setup:(void(^)(CKTableViewCellController* controller, UITableViewCell *cell))setup{
    return [[self class] cellControllerWithName:name setup:setup action:nil];
}

+ (CKTableViewCellController*)cellControllerWithName:(NSString*)name
                                               setup:(void(^)(CKTableViewCellController* controller, UITableViewCell *cell))setup
                                              action:(void(^)(CKTableViewCellController* controller))action{
    return [[self class] cellControllerWithName:name value:nil bindings:nil setup:setup action:action];
}

+ (CKTableViewCellController*)cellControllerWithName:(NSString*)name
                                               value:(id)value
                                            bindings:(NSDictionary*)bindings
                                               setup:(void(^)(CKTableViewCellController* controller, UITableViewCell *cell))setup{
    return [[self class] cellControllerWithName:name value:value bindings:bindings setup:setup action:nil];
}

+ (CKTableViewCellController*)cellControllerWithName:(NSString*)name
                                               value:(id)value
                                            bindings:(NSDictionary*)bindings
                                               setup:(void(^)(CKTableViewCellController* controller, UITableViewCell *cell))setup
                                              action:(void(^)(CKTableViewCellController* controller))action{
    return [[self class] cellControllerWithName:name value:value bindings:bindings controlActions:nil setup:setup action:action];
}

+ (CKTableViewCellController*)cellControllerWithName:(NSString*)name
                                               value:(id)value
                                            bindings:(NSDictionary*)bindings
                                      controlActions:(NSDictionary*)controlActions
                                               setup:(void(^)(CKTableViewCellController* controller, UITableViewCell *cell))setup{
    return [[self class] cellControllerWithName:name value:value bindings:bindings controlActions:controlActions setup:setup action:nil];
}

+ (CKTableViewCellController*)cellControllerWithName:(NSString*)name
                                               value:(id)value
                                            bindings:(NSDictionary*)bindings
                                      controlActions:(NSDictionary*)controlActions
                                               setup:(void(^)(CKTableViewCellController* controller, UITableViewCell *cell))setup
                                              action:(void(^)(CKTableViewCellController* controller))action{
    
    //We have to copy controlActions here as we are on the right stack. if not the block will get copied in controller's setup block and crash if local data are referenced in the block.
    
    NSMutableDictionary* copiedControlActions = nil;
    if(controlActions){
        copiedControlActions = [NSMutableDictionary dictionaryWithCapacity:[controlActions count]];
        for(NSString* key in [controlActions allKeys]){
            void(^actionBlock)(UIControl* control, CKTableViewCellController* controller) = [controlActions objectForKey:key];
            [copiedControlActions setObject:[actionBlock copy] forKey:key];
        }
    }
    
    CKTableViewCellController* controller = [[self class] cellController];
    controller.name = name;
    controller.value = value;
    
    if(value && (bindings || copiedControlActions)){
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
                for(NSInteger j= i; j < [viewPropertyKeyPathComponents count]; ++j){
                    if(j > i){
                        [propertyKeyPath appendString:@"."];
                    }
                    [propertyKeyPath appendString:[viewPropertyKeyPathComponents objectAtIndex:j]];
                }
                
                //bind
                NSString* valueKeyPath = [bindings objectForKey:viewPropertyKeyPath];
                [controller.value bind:valueKeyPath toObject:view withKeyPath:propertyKeyPath];
            }
            
            for(NSString* controlKeyPath in [copiedControlActions allKeys]){
                UIView* control = [cell viewWithKeyPath:controlKeyPath];
                if(control){
                    CKAssert([control isKindOfClass:[UIControl class]],@"ControlKeyPath '%@' points to a non UIControl view",controlKeyPath);
                    void(^actionBlock)(UIControl* control, CKTableViewCellController* controller) = [copiedControlActions objectForKey:controlKeyPath];
                    
                    __block CKTableViewCellController* bController = controller;
                    __block UIControl* bControl = (UIControl*)control;
                    [(UIControl*)control bindEvent:UIControlEventTouchUpInside withBlock:^{
                        actionBlock(bControl,bController);
                    }];
                }
            }
            
            if(setup){
                setup(controller,cell);
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
