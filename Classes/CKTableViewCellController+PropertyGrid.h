//
//  CKTableViewCellController+PropertyGrid.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-07-29.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKTableViewCellController.h"
#import "CKProperty.h"

/** TODO
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