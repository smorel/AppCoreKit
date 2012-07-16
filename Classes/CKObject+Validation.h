//
//  CKObject+Validation.h
//  CloudKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import "CKObject.h"


/** TODO
 */
@interface CKObjectValidationResults : NSObject{
}
@property(nonatomic,copy)NSString* modifiedKeyPath;
@property(nonatomic,retain)NSMutableArray* invalidProperties;

- (BOOL)isValid;

@end


/** TODO
 */
@interface NSObject (CKValidation)

- (CKObjectValidationResults*)validate;
- (void)bindValidationWithBlock:(void(^)(CKObjectValidationResults* validationResults))validationBlock;

@end

