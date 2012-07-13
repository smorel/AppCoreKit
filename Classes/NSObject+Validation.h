//
//  NSObject+Validation.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import "CKObject.h"


/**
 */
@interface CKObjectValidationResults : NSObject

///-----------------------------------
/// @name Accessing validation result status
///-----------------------------------

/** Return the names of the invalid properties
 */
@property(nonatomic,retain)NSMutableArray* invalidProperties;

/**
 */
- (BOOL)isValid;

@end


/**
 */
@interface NSObject (CKValidation)

///-----------------------------------
/// @name Validating an instance
///-----------------------------------

/** This method iterates on properties and call the predicates defined as extended attributes
 */
- (CKObjectValidationResults*)validate;

@end
