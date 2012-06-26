//
//  UIView+CKName.h
//  CloudKit
//
//  Created by Sebastien Morel on 12-06-26.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 */
@interface UIView (CKName)

///-----------------------------------
/// @name Identifying view at runtime
///-----------------------------------

/**
 */
@property (nonatomic,copy) NSString* name;

///-----------------------------------
/// @name Querying view hierarchy
///-----------------------------------

/**
 */
- (id)viewWithKeyPath:(NSString*)keyPath;

@end
