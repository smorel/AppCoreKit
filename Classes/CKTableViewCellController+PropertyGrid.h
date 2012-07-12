//
//  CKTableViewCellController+PropertyGrid.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKTableViewCellController.h"
#import "CKProperty.h"

/**
 */
@interface CKTableViewCellController(CKPropertyGrid)

///-----------------------------------
/// @name Creating initialized TableViewCell Controllers
///-----------------------------------

/**
 */
+ (CKTableViewCellController*)cellControllerWithObject:(id)object keyPath:(NSString*)keyPath;

/**
 */
+ (CKTableViewCellController*)cellControllerWithObject:(id)object keyPath:(NSString*)keyPath readOnly:(BOOL)readOnly;

/**
 */
+ (CKTableViewCellController*)cellControllerWithProperty:(CKProperty*)property;

/**
 */
+ (CKTableViewCellController*)cellControllerWithProperty:(CKProperty*)property readOnly:(BOOL)readOnly;

@end