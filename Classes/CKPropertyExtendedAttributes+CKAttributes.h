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

@interface CKPropertyExtendedAttributes (CKObject)

@property (nonatomic, assign) BOOL comparable;
@property (nonatomic, assign) BOOL serializable;
@property (nonatomic, assign) BOOL copiable;
@property (nonatomic, assign) BOOL deepCopy;
@property (nonatomic, assign) BOOL hashable;
@property (nonatomic, assign) BOOL creatable;
@property (nonatomic, retain) NSPredicate* validationPredicate;

@property (nonatomic, assign) Class contentType;
@property (nonatomic, assign) Protocol* contentProtocol;
@property (nonatomic, retain) NSString* dateFormat;
@property (nonatomic, retain) CKEnumDescriptor* enumDescriptor;

@end


@interface CKPropertyExtendedAttributes (CKPropertyGrid)

@property (nonatomic, assign) BOOL editable;
@property (nonatomic, retain) NSDictionary* valuesAndLabels;
@property (nonatomic, copy)   CKCellControllerCreationBlock cellControllerCreationBlock;

@end

@interface CKPropertyExtendedAttributes (CKNSNumberPropertyCellController)

@property (nonatomic, retain) NSNumber* minimumValue;
@property (nonatomic, retain) NSNumber* maximumValue;

@end


@interface CKPropertyExtendedAttributes (CKNSStringPropertyCellController)

@property (nonatomic, assign) NSInteger minimumLength;
@property (nonatomic, assign) NSInteger maximumLength;

@end