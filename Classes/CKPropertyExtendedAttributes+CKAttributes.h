//
//  CKPropertyExtendedAttributes+CKAttributes.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-23.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKPropertyExtendedAttributes.h"

@class CKTableViewCellController;
@class CKProperty;

typedef CKTableViewCellController*(^CKCellControllerCreationBlock)(CKProperty* property);


/**
 */
@interface CKPropertyExtendedAttributes (CKObject)

///-----------------------------------
/// @name Extended attributes
///-----------------------------------

/**
 */
@property (nonatomic, assign) BOOL comparable;

/**
 */
@property (nonatomic, assign) BOOL serializable;

/**
 */
@property (nonatomic, assign) BOOL copiable;

/**
 */
@property (nonatomic, assign) BOOL deepCopy;

/**
 */
@property (nonatomic, assign) BOOL hashable;

/**
 */
@property (nonatomic, assign) BOOL creatable;

/**
 */
@property (nonatomic, retain) NSPredicate* validationPredicate;

/**
 */
@property (nonatomic, assign) Class contentType;

/**
 */
@property (nonatomic, assign) Protocol* contentProtocol;

/**
 */
@property (nonatomic, retain) NSString* dateFormat;

/**
 */
@property (nonatomic, retain) CKEnumDescriptor* enumDescriptor;

@end


/**
 */
@interface CKPropertyExtendedAttributes (CKPropertyGrid)

///-----------------------------------
/// @name Extended attributes
///-----------------------------------

/**
 */
@property (nonatomic, assign) BOOL editable;

/**
 */
@property (nonatomic, retain) NSDictionary* valuesAndLabels;

/**
 */
@property (nonatomic, copy)   CKCellControllerCreationBlock cellControllerCreationBlock;

@end





/**
 */
@interface CKPropertyExtendedAttributes (CKNSNumberPropertyCellController)

///-----------------------------------
/// @name Extended attributes
///-----------------------------------

/**
 */
@property (nonatomic, retain) NSNumber* minimumValue;

/**
 */
@property (nonatomic, retain) NSNumber* maximumValue;

@end





/**
 */
@interface CKPropertyExtendedAttributes (CKNSStringPropertyCellController)

///-----------------------------------
/// @name Extended attributes
///-----------------------------------

/**
 */
@property (nonatomic, assign) NSInteger minimumLength;

/**
 */
@property (nonatomic, assign) NSInteger maximumLength;

@end






/**
 */
@interface CKPropertyExtendedAttributes (CKMultilineNSStringPropertyCellController)

///-----------------------------------
/// @name Extended attributes
///-----------------------------------

/**
 */
@property (nonatomic, assign) BOOL multiLineEnabled;

@end






typedef NSComparisonResult(^CKOptionPropertyCellControllerSortingBlock)(id value1, NSString* label1,id value2, NSString* label2);

/**
 */
@interface CKPropertyExtendedAttributes (CKOptionPropertyCellController)

///-----------------------------------
/// @name Extended attributes
///-----------------------------------

/**
 */
@property (nonatomic, assign) BOOL multiSelectionEnabled;

/**
 */
@property (nonatomic, assign) BOOL presentsOptionsAsPopover;

/**
 */
@property (nonatomic, copy) CKOptionPropertyCellControllerSortingBlock sortingBlock;

@end


/**
 */
@interface CKPropertyExtendedAttributes (CKNSDateViewController)

///-----------------------------------
/// @name Extended attributes
///-----------------------------------

/**
 */
@property (nonatomic, retain) NSDate* minimumDate;

@end
