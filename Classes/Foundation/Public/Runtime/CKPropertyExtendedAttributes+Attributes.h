//
//  CKPropertyExtendedAttributes+CKAttributes.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
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


/** textInputView can be UITextField or UITextView
 */
typedef BOOL(^CKInputTextFormatterBlock)(id textInputView,NSRange range, NSString* replacementString);


/**
 */
@interface CKPropertyExtendedAttributes (CKTextInputPropertyCellController)

///-----------------------------------
/// @name Extended attributes
///-----------------------------------

/**
 */
@property (nonatomic, copy) CKInputTextFormatterBlock textInputFormatterBlock;

/**
 */
@property (nonatomic, assign) NSInteger minimumLength;

/**
 */
@property (nonatomic, assign) NSInteger maximumLength;

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

/**
 */
@property (nonatomic, retain) NSNumber* placeholderValue;

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

typedef NS_ENUM(NSInteger, CKOptionPropertyCellControllerPresentationStyle){
    CKOptionPropertyCellControllerPresentationStyleDefault,
    CKOptionPropertyCellControllerPresentationStylePush,
    CKOptionPropertyCellControllerPresentationStylePopover,
    CKOptionPropertyCellControllerPresentationStyleModal
};

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
@property (nonatomic, assign) CKOptionPropertyCellControllerPresentationStyle presentationStyle;

/**
 */
@property (nonatomic, copy) CKOptionPropertyCellControllerSortingBlock sortingBlock;

/**
 */
@property (nonatomic, copy) CKTableViewCellController*(^optionCellControllerCreationBlock)(NSString* label, id value);

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

/**
 */
@property (nonatomic, retain) NSDate* maximumDate;

@end
