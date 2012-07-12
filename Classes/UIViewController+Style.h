//
//  UIViewController+Style.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIView+Style.h"

/**
 */
@interface UIViewController (CKStyle)

- (NSMutableDictionary*)controllerStyle;
- (NSMutableDictionary*)applyStyle;
- (NSMutableDictionary*)applyStyleWithParentStyle:(NSMutableDictionary*)style;

@end
