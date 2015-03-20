//
//  UIViewController+Style.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKStyleManager.h"

/**
 */
@interface UIViewController (CKStyle)

- (BOOL)isLayoutDefinedInStylesheet;

/** By specifying a stylesheet filename, this file will get used to initalize the stylemanager for your view controller
    and bypass the following automatic detection.
 
 see. styleManager.
 */
@property(nonatomic, retain) NSString* stylesheetFileName;

/** The style manager associated to this view controller.
 If we find a style file named TheControllerClass.style, we'll create a stylemanager that will load this file
 as the root style file for this controller. This means if you have dependencies on other .style file,
 you'll have to import them in your TheControllerClass.style file to get the inheritance to work properly.
 If we do not find TheControllerClass.style, and your controller is in a container or spitter, it'll use it's containers style manager.
 else we'll get the defaultManager
 */
@property(nonatomic, retain, readonly) CKStyleManager* styleManager;

- (NSMutableDictionary*)controllerStyle;
- (NSMutableDictionary*)applyStyle;
- (NSMutableDictionary*)applyStyleWithParentStyle:(NSMutableDictionary*)style;

@end
