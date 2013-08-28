//
//  CKTableViewCellController+Factory.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKTableViewCellController.h"

/**
 */
@interface CKTableViewCellController (Factory)

/**
 */
+ (CKTableViewCellController*)cellControllerWithName:(NSString*)name;

/**
 action is triggered when the user tap on the table view cell.
 */
+ (CKTableViewCellController*)cellControllerWithName:(NSString*)name 
                                      action:(void(^)(CKTableViewCellController* controller))action;

/**
 bindings should be a dictionary of keyPath from tableViewCell to the target view property as a key, and a keypath for the value's property to bind with.
 */
+ (CKTableViewCellController*)cellControllerWithName:(NSString*)name 
                                              value:(id)value
                                            bindings:(NSDictionary*)bindings;
/**
 action is triggered when the user tap on the table view cell.
 bindings should be a dictionary of keyPath from tableViewCell to the target view property as a key, and a keypath for the value's property to bind with.
 */
+ (CKTableViewCellController*)cellControllerWithName:(NSString*)name 
                                               value:(id)value
                                            bindings:(NSDictionary*)dictionary 
                                      action:(void(^)(CKTableViewCellController* controller))action;
/**
 bindings should be a dictionary of keyPath from tableViewCell to the target view property as a key, and a keypath for the value's property to bind with.
 controlActions should be a dictionary of keyPath from tableViewCell to the target control as a key, and a block with the following signature as a value :
     void(^actionBlock)(UIControl* control, CKTableViewCellController* controller)
 */
+ (CKTableViewCellController*)cellControllerWithName:(NSString*)name 
                                               value:(id)value
                                            bindings:(NSDictionary*)bindings 
                                      controlActions:(NSDictionary*)controlActions;


/**
 action is triggered when the user tap on the table view cell.
 bindings should be a dictionary of keyPath from tableViewCell to the target view property as a key, and a keypath for the value's property to bind with.
 controlActions should be a dictionary of keyPath from tableViewCell to the target control as a key, and a block with the following signature as a value :
     void(^actionBlock)(UIControl* control, CKTableViewCellController* controller)
 */
+ (CKTableViewCellController*)cellControllerWithName:(NSString*)name 
                                               value:(id)value
                                            bindings:(NSDictionary*)bindings 
                                      controlActions:(NSDictionary*)controlActions 
                                      action:(void(^)(CKTableViewCellController* controller))action;



/**
 */
+ (CKTableViewCellController*)cellControllerWithName:(NSString*)name
                                               setup:(void(^)(CKTableViewCellController* controller, UITableViewCell *cell))setup;

/**
 action is triggered when the user tap on the table view cell.
 setup allow you to add additional management of the view using the controller's value. setup is already in a binding context,
 do not call [cell beginBindingContextByRemovingPreviousBindings] in setup or this will break the bindings we set for you in this method.
 */
+ (CKTableViewCellController*)cellControllerWithName:(NSString*)name
                                               setup:(void(^)(CKTableViewCellController* controller, UITableViewCell *cell))setup
                                              action:(void(^)(CKTableViewCellController* controller))action;

/**
 bindings should be a dictionary of keyPath from tableViewCell to the target view property as a key, and a keypath for the value's property to bind with.
 setup allow you to add additional management of the view using the controller's value. setup is already in a binding context,
 do not call [cell beginBindingContextByRemovingPreviousBindings] in setup or this will break the bindings we set for you in this method.
 */
+ (CKTableViewCellController*)cellControllerWithName:(NSString*)name
                                               value:(id)value
                                            bindings:(NSDictionary*)bindings
                                               setup:(void(^)(CKTableViewCellController* controller, UITableViewCell *cell))setup;
/**
 action is triggered when the user tap on the table view cell.
 bindings should be a dictionary of keyPath from tableViewCell to the target view property as a key, and a keypath for the value's property to bind with.
 setup allow you to add additional management of the view using the controller's value. setup is already in a binding context,
 do not call [cell beginBindingContextByRemovingPreviousBindings] in setup or this will break the bindings we set for you in this method.
 */
+ (CKTableViewCellController*)cellControllerWithName:(NSString*)name
                                               value:(id)value
                                            bindings:(NSDictionary*)dictionary
                                               setup:(void(^)(CKTableViewCellController* controller, UITableViewCell *cell))setup
                                              action:(void(^)(CKTableViewCellController* controller))action;
/**
 bindings should be a dictionary of keyPath from tableViewCell to the target view property as a key, and a keypath for the value's property to bind with.
 controlActions should be a dictionary of keyPath from tableViewCell to the target control as a key, and a block with the following signature as a value :
 void(^actionBlock)(UIControl* control, CKTableViewCellController* controller)
 setup allow you to add additional management of the view using the controller's value. setup is already in a binding context,
 do not call [cell beginBindingContextByRemovingPreviousBindings] in setup or this will break the bindings we set for you in this method.
 */
+ (CKTableViewCellController*)cellControllerWithName:(NSString*)name
                                               value:(id)value
                                            bindings:(NSDictionary*)bindings
                                      controlActions:(NSDictionary*)controlActions
                                               setup:(void(^)(CKTableViewCellController* controller, UITableViewCell *cell))setup;


/**
 action is triggered when the user tap on the table view cell.
 bindings should be a dictionary of keyPath from tableViewCell to the target view property as a key, and a keypath for the value's property to bind with.
 controlActions should be a dictionary of keyPath from tableViewCell to the target control as a key, and a block with the following signature as a value :
 void(^actionBlock)(UIControl* control, CKTableViewCellController* controller)
 setup allow you to add additional management of the view using the controller's value. setup is already in a binding context,
 do not call [cell beginBindingContextByRemovingPreviousBindings] in setup or this will break the bindings we set for you in this method.
 */
+ (CKTableViewCellController*)cellControllerWithName:(NSString*)name
                                               value:(id)value
                                            bindings:(NSDictionary*)bindings
                                      controlActions:(NSDictionary*)controlActions
                                               setup:(void(^)(CKTableViewCellController* controller, UITableViewCell *cell))setup
                                              action:(void(^)(CKTableViewCellController* controller))action;

@end
